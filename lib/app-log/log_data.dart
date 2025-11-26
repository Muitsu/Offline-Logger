import 'package:flutter/material.dart';

class LogData {
  final String tag;
  final String method;
  final String message;
  final String path;
  final String date;
  final String level;

  LogData({
    required this.tag,
    required this.method,
    required this.message,
    required this.path,
    required this.date,
    required this.level,
  });

  /// This method is robust and already handles multi-line messages correctly.
  factory LogData.fromRaw(String raw) {
    final regex = RegExp(r'\{([^}]*)\}');
    final matches = regex.allMatches(raw);
    final parts = matches.map((match) => match.group(1) ?? '').toList();

    if (parts.length != 5) {
      return LogData(
        tag: '',
        method: '',
        message: raw,
        path: '',
        date: '',
        level: '',
      );
    }

    return LogData(
      tag: parts[0],
      method: parts[1],
      message: parts[2],
      path: '',
      date: parts[3],
      level: parts[4],
    );
  }

  /// CORRECTED: This method now correctly splits the entire text block by the start of a new log entry.
  /// It no longer splits by newlines first, which was breaking multi-line messages.
  static List<LogData> fromData(String logString) {
    // 1. Normalize line endings.
    final normalizedString = logString.replaceAll('\r\n', '\n');

    // 2. Split the entire string by the lookahead for a new log entry.
    // This correctly handles multi-line log messages.
    final rawEntries = normalizedString.split(RegExp(r'(?=\{AppLogger\})'));

    // 3. Process the resulting list of raw log strings.
    return rawEntries
        .map((e) => e.trim()) // Trim whitespace from each entry.
        .where((e) => e.isNotEmpty) // Filter out any empty strings.
        .map(
          (e) => LogData.fromRaw(e),
        ) // Parse each entry into a LogData object.
        .toList()
        .reversed
        .toList();
  }

  /// Convert object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'method': method,
      'message': message,
      'path': path,
      'date': date,
      'tag': tag,
    };
  }

  /// Create object from JSON map
  factory LogData.fromJson(Map<String, dynamic> json) {
    return LogData(
      tag: json['tag'] ?? '',
      method: json['method'] ?? '',
      message: json['message'] ?? '',
      path: json['path'] ?? '',
      date: json['date'] ?? '',
      level: json['level'] ?? '',
    );
  }

  Color? getStatusColor() {
    final map = {
      "info": const Color.fromARGB(255, 48, 99, 189),
      "warning": const Color.fromARGB(255, 190, 146, 14),
      "error": const Color.fromARGB(255, 133, 29, 22),
    };

    return map[level.toLowerCase()];
  }
}
