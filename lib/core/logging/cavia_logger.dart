import 'dart:collection';

/// Log severity level.
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Structured redacted log entry.
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final Object? error;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
  });

  @override
  String toString() =>
      '[${timestamp.toIso8601String()}] [${level.name.toUpperCase()}] [$tag] $message';
}

/// Central privacy-preserving and security-hardened logger for Cavia Music.
///
/// Guaranteed protections:
/// - Bearer tokens and OAuth tokens are redacted.
/// - Client secrets and passwords are redacted.
/// - User email addresses are obfuscated.
/// - Sensitive user file paths are neutralized.
/// - Raw database/SQL stack traces are sanitized before logging.
class CaviaLogger {
  static final CaviaLogger _instance = CaviaLogger._internal();
  factory CaviaLogger() => _instance;
  CaviaLogger._internal();

  final Queue<LogEntry> _history = Queue<LogEntry>();
  static const int maxHistoryEntries = 500;

  bool enableConsoleOutput = false;

  List<LogEntry> get history => _history.toList();

  void clearHistory() => _history.clear();

  void debug(String tag, String message) =>
      _log(LogLevel.debug, tag, message);

  void info(String tag, String message) =>
      _log(LogLevel.info, tag, message);

  void warning(String tag, String message, [Object? error]) =>
      _log(LogLevel.warning, tag, message, error);

  void error(String tag, String message, [Object? error]) =>
      _log(LogLevel.error, tag, message, error);

  void _log(LogLevel level, String tag, String message, [Object? error]) {
    final sanitizedMessage = redact(message);
    final sanitizedError = error != null ? redact(error.toString()) : null;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: sanitizedMessage,
      error: sanitizedError,
    );

    if (_history.length >= maxHistoryEntries) {
      _history.removeFirst();
    }
    _history.add(entry);

    if (enableConsoleOutput) {
      // ignore: avoid_print
      print(entry.toString());
      if (sanitizedError != null) {
        // ignore: avoid_print
        print('  Error details: $sanitizedError');
      }
    }
  }

  /// Sanitizes sensitive patterns from any string before persistent logging.
  static String redact(String input) {
    var output = input;

    // 1. Redact Bearer and access tokens
    output = output.replaceAllMapped(
      RegExp(r'(Bearer\s+)[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
      (match) => '${match.group(1)}[REDACTED_TOKEN]',
    );
    output = output.replaceAllMapped(
      RegExp(r'((access_token|refresh_token|code|token)["\s:=]+)[A-Za-z0-9\-._~+/]+', caseSensitive: false),
      (match) => '${match.group(1)}[REDACTED_TOKEN]',
    );

    // 2. Redact client secrets & API keys
    output = output.replaceAllMapped(
      RegExp(r'''((client_secret|api_key|secret|password)["\s:=]+)[^\s,}"']+''', caseSensitive: false),
      (match) => '${match.group(1)}[REDACTED_SECRET]',
    );

    // 3. Obfuscate emails: test@example.com -> t***@example.com
    output = output.replaceAllMapped(
      RegExp(r'([A-Za-z0-9._%+-])[A-Za-z0-9._%+-]*@([A-Za-z0-9.-]+\.[A-Za-z]{2,})'),
      (match) => '${match.group(1)}***@${match.group(2)}',
    );

    // 4. Sanitize local user home paths (e.g. C:\Users\Username\... -> [USER_HOME]\...)
    output = output.replaceAllMapped(
      RegExp(r'[a-zA-Z]:\\Users\\[^\\]+', caseSensitive: false),
      (_) => '[USER_HOME]',
    );
    output = output.replaceAllMapped(
      RegExp(r'/home/[^/]+', caseSensitive: false),
      (_) => '[USER_HOME]',
    );
    output = output.replaceAllMapped(
      RegExp(r'/Users/[^/]+', caseSensitive: false),
      (_) => '[USER_HOME]',
    );

    // 5. Sanitize raw SQLite internal pointers and statements if present
    output = output.replaceAllMapped(
      RegExp(r'(sqlite3:\s*SqliteException\s*\([^)]*\))', caseSensitive: false),
      (_) => '[Database Operation Failed]',
    );

    return output;
  }
}
