import 'dart:async';
import 'dart:io';

import 'package:flutter_logs/flutter_logs.dart';
import 'package:logger/logger.dart';
import 'package:offline_logs/app-log/log_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

enum LogEnv { development, staging, production }

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
  LogEnv? _environment;
  final String _tag = "AppLogger";
  bool _autoSave = false;

  // 2. Initialize the logger
  Future<void> initialize({
    String logFileName = "app_log",
    String saveLogPath = "AppLogs",
    int limitLogByte = 10 * 1024 * 1024,
    LogEnv environment = LogEnv.development,
    required bool autoSave,
  }) async {
    _logFileName = logFileName;
    _saveLogPath = saveLogPath;
    _environment = environment;
    _autoSave = autoSave;
    // Setup Logger
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // Number of method calls to be displayed
        errorMethodCount: 8, // Number of method calls if stacktrace is provided
        lineLength: 120, // Width of the output
        colors: true, // Colorful log msgs
        printEmojis: true, // Print an emoji for each log msg
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
    info("setUpLogs", msg: "setUpLogs: Setting up logs..");
  }

  // 3. Public logging methods
  Future<void> debug(
    String functionName, {
    String? tag,
    required dynamic msg,
    bool? saveLog,
  }) async {
    if (_logFileName != null && _logger != null) {
      _logger!.d(msg);
      if (!(saveLog ?? _autoSave)) return;
      await FlutterLogs.logInfo(tag ?? _tag, functionName, msg.toString());
    }
    return;
  }

  Future<void> info(
    String functionName, {
    String? tag,
    required dynamic msg,
    bool? saveLog,
  }) async {
    if (_logFileName != null && _logger != null) {
      _logger!.i(msg);
      if (!(saveLog ?? _autoSave)) return;
      await FlutterLogs.logInfo(tag ?? _tag, functionName, msg.toString());
    }
    return;
  }

  Future<void> warning(
    String functionName, {
    String? tag,
    required dynamic msg,
    bool? saveLog,
  }) async {
    if (_logFileName != null && _logger != null) {
      _logger!.w(msg);
      if (!(saveLog ?? _autoSave)) return;
      await FlutterLogs.logWarn(tag ?? _tag, functionName, msg.toString());
    }
    return;
  }

  Future<void> error(
    String functionName, {
    String? tag,
    required dynamic msg,
    bool? saveLog,
  }) async {
    if (_logFileName != null && _logger != null) {
      _logger!.e(msg);
      if (!(saveLog ?? _autoSave)) return;
      await FlutterLogs.logError(tag ?? _tag, functionName, msg.toString());
    }
    return;
  }

  Future<void> severe({
    String? tag,
    required String functionName,
    dynamic msg,
    bool? saveLog,
  }) async {
    if (_logFileName != null && _logger != null) {
      _logger!.d(msg);
      if (!(saveLog ?? _autoSave)) return;
      await info(functionName, msg: msg);
    }
    return;
  }

  // 4. Export logs functionality
  Future<String> exportLogs() async {
    final Completer<String> completer = Completer<String>();

    FlutterLogs.channel.setMethodCallHandler((call) async {
      if (call.method == 'logsExported') {
        final filePath = call.arguments.toString();
        info("exportLogs", msg: "logsExported: $filePath");
        completer.complete(filePath);
      }
    });

    await FlutterLogs.exportLogs();
    return completer.future;
  }

  // 5. Share logs functionality
  Future<void> shareLogs({bool getLatest = true, String? customPpath}) async {
    try {
      final String exportedPath =
          customPpath ?? await _getLogFilePath(getLatest: getLatest);
      if (exportedPath.isNotEmpty) {
        final File file = File(exportedPath);
        if (await file.exists()) {
          final params = ShareParams(files: [XFile(exportedPath)]);
          await SharePlus.instance.share(params);
        } else {
          // Log file doesn't exist
          error(
            "shareLogs",
            msg: "Exported log file not found at $exportedPath",
          );
        }
      }
    } catch (e) {
      error("shareLogs", msg: "Error sharing logs: $e");
    }
  }

  // New function to open the log file with an external app
  Future<void> openLogExternally({
    bool getLatest = true,
    String? customPpath,
  }) async {
    final String logFilePath =
        customPpath ?? await _getLogFilePath(getLatest: getLatest);

    if (logFilePath.isNotEmpty) {
      final file = File(logFilePath);
      if (await file.exists()) {
        final OpenResult result = await OpenFilex.open(logFilePath);

        if (result.type != ResultType.done) {
          // You can log this error or show a msg to the user
          error(
            "openLogsExternally",
            msg: "Could not open log file: ${result.message}",
          );
        }
      } else {
        error(
          "openLogsExternally",
          msg: "Log file not found at path: $logFilePath",
        );
      }
    } else {
      error("openLogsExternally", msg: "No log file path found.");
    }
  }

  Future<String> readLogAsString({
    bool getLatest = true,
    String? customPpath,
  }) async {
    final String logFilePath =
        customPpath ?? await _getLogFilePath(getLatest: getLatest);

    if (logFilePath.isNotEmpty) {
      final file = File(logFilePath);
      if (await file.exists()) {
        return await file.readAsString();
      } else {
        String errMsg = "Log file not found at path: $logFilePath";
        error("openLogsExternally", msg: errMsg);
        return errMsg;
      }
    } else {
      String errMsg = "No log file path found.";
      error("openLogsExternally", msg: "No log file path found.");
      return errMsg;
    }
  }

  Future<List<LogData>> readLogAsObject({
    bool getLatest = true,
    String? customPpath,
  }) async {
    final String logFilePath =
        customPpath ?? await _getLogFilePath(getLatest: getLatest);

    if (logFilePath.isNotEmpty) {
      final file = File(logFilePath);
      if (await file.exists()) {
        final logString = await file.readAsString();
        return LogData.fromData(logString);
      } else {
        String errMsg = "Log file not found at path: $logFilePath";
        error("openLogsExternally", msg: errMsg);
        return [];
      }
    } else {
      error("openLogsExternally", msg: "No log file path found.");
      return [];
    }
  }

  // Private helper to get the path to the current log file
  Future<String> _getLogFilePath({bool getLatest = true}) async {
    try {
      // ... same method as before
      final directory = await getExternalStorageDirectory();
      // info("getLogFilePath", directory?.path ?? "No Directory Found");
      final logsDirectory = Directory('${directory!.path}/$_saveLogPath');

      // This is a simplified approach; you might need to adjust based on flutter_logs' directory structure.
      final List<FileSystemEntity> files = logsDirectory.listSync(
        recursive: true,
      );

      final sortedFile = getLatest ? files.reversed : files;

      for (var file in sortedFile) {
        if (file is File && file.path.endsWith('.log')) {
          // Return the first log file found
          return file.path;
        }
      }
      return '';
    } catch (e) {
      error("getLogFilePath", msg: e.toString());
      // Fallback if no log file is found
      return '';
    }
  }

  // Helper to get all the path to the current log file
  Future<List<File>> getAllLogFilePath({bool sortedFromLatest = true}) async {
    try {
      // ... same method as before
      final directory = await getExternalStorageDirectory();
      // info("getLogFilePath", directory?.path ?? "No Directory Found");
      final logsDirectory = Directory('${directory!.path}/$_saveLogPath');

      // This is a simplified approach; you might need to adjust based on flutter_logs' directory structure.
      final List<FileSystemEntity> files = logsDirectory.listSync(
        recursive: true,
      );

      final sortedFile = sortedFromLatest ? files.reversed : files;

      List<File> pathList = [];
      for (var file in sortedFile) {
        if (file is File && file.path.endsWith('.log')) {
          pathList.add(file);
        }
      }
      return pathList;
    } catch (e) {
      error("getLogFilePath", msg: e.toString());
      // Fallback if no log file is found
      return [];
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
      error("getTotalLogFiles", msg: "Error: $e");
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
      error("clearLogFiles", msg: "Error: $e");
    }

    return deletedCount;
  }

  Future<void> clearOldLogFiles({bool keepLatest = true}) async {
    try {
      final directory = await getExternalStorageDirectory();
      final logsDirectory = Directory('${directory!.path}/$_saveLogPath');

      if (!await logsDirectory.exists()) {
        warning("clearOldLogFiles", msg: "Logs directory does not exist.");
        return;
      }

      final files = logsDirectory
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();

      if (files.isEmpty) {
        info("clearOldLogFiles", msg: "No log files found to delete.");
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
        debug("clearOldLogFiles", msg: "Deleted: ${file.path}");
      }

      info("clearOldLogFiles", msg: "Deleted $deletedCount old log file(s).");
    } catch (e, stacktrace) {
      error("clearOldLogFiles", msg: "Error: $e\n$stacktrace");
    }
  }

  Future<void> _autoClearLogsIfExceedsLimit({
    int maxSizeBytes = 10 * 1024 * 1024,
  }) async {
    try {
      final directory = await getExternalStorageDirectory();
      final logsDirectory = Directory(
        '${directory!.path}/$_saveLogPath/${_environment!.name}',
      );

      if (!await logsDirectory.exists()) {
        warning(
          "clearLogsIfExceedsLimit",
          msg: "Logs directory does not exist.",
        );
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
        msg: "Total log size: ${totalSize / (1024 * 1024)} MB",
      );

      if (totalSize > maxSizeBytes) {
        info(
          "clearLogsIfExceedsLimit",
          msg: "Log size exceeds limit. Deleting old logs...",
        );
        await clearOldLogFiles(keepLatest: true);
      } else {
        debug(
          "clearLogsIfExceedsLimit",
          msg: "Log size is within limit. No deletion needed.",
        );
      }
    } catch (e, stacktrace) {
      error("clearLogsIfExceedsLimit", msg: "Error: $e\n$stacktrace");
    }
  }
}
