import 'dart:async';
import 'dart:io';

import 'package:flutter_logs/flutter_logs.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class AppLogger {
  // 1. Singleton pattern implementation
  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() {
    return _instance;
  }

  AppLogger._internal();

  // Store the log file name
  String? _logFileName;
  String? _saveLogPath;
  Logger? _logger;
  final String _tag = "AppLogger";

  // 2. Initialize the logger
  Future<void> initialize({
    String logFileName = "app_log",
    String saveLogPath = "AppLogs",
    int limitLogByte = 10 * 1024 * 1024,
  }) async {
    _logFileName = logFileName;
    _saveLogPath = saveLogPath;
    // Setup Logger
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
        // Should each log print contain a timestamp
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
    // Setip Flutter Logs
    await FlutterLogs.initLogs(
      logLevelsEnabled: [
        LogLevel.INFO,
        LogLevel.WARNING,
        LogLevel.ERROR,
        LogLevel.SEVERE,
      ],
      timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
      directoryStructure: DirectoryStructure.FOR_DATE,
      logTypesEnabled: [_logFileName!],
      logFileExtension: LogFileExtension.LOG,
      logsWriteDirectoryName: _saveLogPath!,
      logsExportDirectoryName: "$_saveLogPath/Exported",
      debugFileOperations: true,
      isDebuggable: true,
      enabled: true,
    );
    //Clear Log when exceed 10 mb
    await _autoClearLogsIfExceedsLimit(maxSizeBytes: limitLogByte);
    // [IMPORTANT] The first log line must never be called before 'FlutterLogs.initLogs'
    info("setUpLogs", "setUpLogs: Setting up logs..");
  }

  // 3. Public logging methods
  void debug(String functionName, String message) {
    if (_logFileName != null && _logger != null) {
      _logger!.d(message);
      FlutterLogs.logInfo(_tag, functionName, message);
    }
  }

  void info(String functionName, String message) {
    if (_logFileName != null && _logger != null) {
      _logger!.i(message);
      FlutterLogs.logInfo(_tag, functionName, message);
    }
  }

  void warning(String functionName, String message) {
    if (_logFileName != null && _logger != null) {
      _logger!.w(message);
      FlutterLogs.logWarn(_tag, functionName, message);
    }
  }

  void error(String functionName, String message) {
    if (_logFileName != null && _logger != null) {
      _logger!.e(message);
      FlutterLogs.logError(_tag, functionName, message);
    }
  }

  void severe(String functionName, String message) {
    if (_logFileName != null && _logger != null) {
      _logger!.d(message);
      info(functionName, message);
    }
  }

  // 4. Export logs functionality
  Future<String> exportLogs() async {
    final Completer<String> completer = Completer<String>();

    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        final filePath = call.arguments.toString();
        info("exportLogs", "logsExported: $filePath");
        completer.complete(filePath);
      }
    });

    await FlutterLogs.exportLogs();
    return completer.future;
  }

  // 5. Share logs functionality
  Future<void> shareLogs() async {
    try {
      final String exportedPath = await _getLogFilePath();
      if (exportedPath.isNotEmpty) {
        final File file = File(exportedPath);
        if (await file.exists()) {
          final params = ShareParams(files: [XFile(exportedPath)]);
          await SharePlus.instance.share(params);
        } else {
          // Log file doesn't exist
          error("shareLogs", "Exported log file not found at $exportedPath");
        }
      }
    } catch (e) {
      error("shareLogs", "Error sharing logs: $e");
    }
  }

  // New function to open the log file with an external app
  Future<void> openLogExternally() async {
    final String logFilePath = await _getLogFilePath();

    if (logFilePath.isNotEmpty) {
      final file = File(logFilePath);
      if (await file.exists()) {
        final OpenResult result = await OpenFilex.open(logFilePath);

        if (result.type != ResultType.done) {
          // You can log this error or show a message to the user
          error(
            "openLogsExternally",
            "Could not open log file: ${result.message}",
          );
        }
      } else {
        error("openLogsExternally", "Log file not found at path: $logFilePath");
      }
    } else {
      error("openLogsExternally", "No log file path found.");
    }
  }

  // Private helper to get the path to the current log file
  Future<String> _getLogFilePath() async {
    try {
      // ... same method as before
      final directory = await getExternalStorageDirectory();
      info("getLogFilePath", directory?.path ?? "No Directory Found");
      final logsDirectory = Directory('${directory!.path}/$_saveLogPath');

      // This is a simplified approach; you might need to adjust based on flutter_logs' directory structure.
      final List<FileSystemEntity> files = logsDirectory.listSync(
        recursive: true,
      );
      for (var file in files) {
        if (file is File && file.path.endsWith('.log')) {
          // Return the first log file found
          return file.path;
        }
      }
      return '';
    } catch (e) {
      error("getLogFilePath", e.toString());
      // Fallback if no log file is found
      return '';
    }
  }

  Future<int> getTotalLogFiles() async {
    int totalLogFiles = 0;
    try {
      final directory = await getExternalStorageDirectory();
      final logsDirectory = Directory('${directory!.path}/$_saveLogPath');

      if (await logsDirectory.exists()) {
        final files = logsDirectory.listSync(recursive: true);

        for (var file in files) {
          if (file is File && file.path.endsWith('.log')) {
            totalLogFiles++;
          }
        }
      }
    } catch (e) {
      error("getTotalLogFiles", "Error: $e");
    }

    return totalLogFiles;
  }

  Future<int> clearLogFiles() async {
    int deletedCount = 0;
    try {
      final directory = await getExternalStorageDirectory();
      final logsDirectory = Directory('${directory!.path}/$_saveLogPath');

      if (await logsDirectory.exists()) {
        final files = logsDirectory.listSync(recursive: true);

        for (var file in files) {
          if (file is File && file.path.endsWith('.log')) {
            await file.delete();
            deletedCount++;
          }
        }
      }
    } catch (e) {
      error("clearLogFiles", "Error: $e");
    }

    return deletedCount;
  }

  Future<void> clearOldLogFiles({bool keepLatest = true}) async {
    try {
      final directory = await getExternalStorageDirectory();
      final logsDirectory = Directory('${directory!.path}/$_saveLogPath');

      if (!await logsDirectory.exists()) {
        warning("clearOldLogFiles", "Logs directory does not exist.");
        return;
      }

      final files = logsDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();

      if (files.isEmpty) {
        info("clearOldLogFiles", "No log files found to delete.");
        return;
      }

      // Sort files by last modified time, descending (latest first)
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      // Keep only the latest one if required
      final filesToDelete = keepLatest ? files.skip(1) : files;

      int deletedCount = 0;
      for (final file in filesToDelete) {
        await file.delete();
        deletedCount++;
        debug("clearOldLogFiles", "Deleted: ${file.path}");
      }

      info("clearOldLogFiles", "Deleted $deletedCount old log file(s).");
    } catch (e, stacktrace) {
      error("clearOldLogFiles", "Error: $e\n$stacktrace");
    }
  }

  Future<void> _autoClearLogsIfExceedsLimit({
    int maxSizeBytes = 10 * 1024 * 1024,
  }) async {
    try {
      final directory = await getExternalStorageDirectory();
      final logsDirectory = Directory('${directory!.path}/$_saveLogPath');

      if (!await logsDirectory.exists()) {
        warning("clearLogsIfExceedsLimit", "Logs directory does not exist.");
        return;
      }

      final files = logsDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();

      int totalSize = 0;
      for (final file in files) {
        totalSize += await file.length();
      }

      info(
        "clearLogsIfExceedsLimit",
        "Total log size: ${totalSize / (1024 * 1024)} MB",
      );

      if (totalSize > maxSizeBytes) {
        info(
          "clearLogsIfExceedsLimit",
          "Log size exceeds limit. Deleting old logs...",
        );
        await clearOldLogFiles(keepLatest: true);
      } else {
        debug(
          "clearLogsIfExceedsLimit",
          "Log size is within limit. No deletion needed.",
        );
      }
    } catch (e, stacktrace) {
      error("clearLogsIfExceedsLimit", "Error: $e\n$stacktrace");
    }
  }
}
