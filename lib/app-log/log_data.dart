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

  factory LogData.fromRaw(String raw) {
    final parts = raw
        .split('}')
        .map((p) => p.trim().replaceAll('{', ''))
        .where((p) => p.isNotEmpty)
        .toList();

    return LogData(
      tag: parts.isNotEmpty ? parts[0] : '',
      method: parts.length > 1 ? parts[1] : '',
      path: parts.length > 2 ? parts[2] : '',
      date: parts.length > 3 ? parts[3] : '',
      level: parts.length > 4 ? parts[4] : '',
      message: parts.length > 2 && !parts[2].startsWith('/') ? parts[2] : '',
    );
  }

  static List<LogData> fromData(String logString) {
    return logString
        .replaceAll('\r\n', '\n')
        .split('\n')
        .expand((line) => line.split(RegExp(r'(?=\{AppLogger\})')))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => LogData.fromRaw(e))
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
}
