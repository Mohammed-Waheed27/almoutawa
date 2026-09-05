import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Pretty Logger Utility
///
/// A comprehensive logging utility that provides beautiful, readable console output
/// with different log levels, timestamps, and formatting options.
///
/// ## Features:
/// - Multiple log levels (debug, info, success, warning, error)
/// - Pretty formatting with emojis and colors
/// - Timestamp support
/// - JSON pretty printing
/// - Stack trace support
/// - Easy to use anywhere in your codebase
///
/// ## Usage Examples:
///
/// ### Basic Usage:
/// ```dart
/// // Import the logger
/// import 'package:w/core/utils/pretty_logger.dart';
///
/// // Simple log
/// PrettyLogger.info('User logged in successfully');
///
/// // Log with data
/// PrettyLogger.debug('Product data', data: productModel.toJson());
///
/// // Log error with stack trace
/// PrettyLogger.error('Failed to load products', error: e, stackTrace: st);
///
/// // Log success
/// PrettyLogger.success('Order created successfully');
///
/// // Log warning
/// PrettyLogger.warning('Low stock detected');
/// ```
///
/// ### JSON Pretty Print:
/// ```dart
/// // Pretty print JSON data
/// PrettyLogger.json('Product JSON', productModel.toJson());
/// ```
///
/// ### Custom Log:
/// ```dart
/// // Custom log with emoji and color
/// PrettyLogger.custom('🚀', 'Custom Message', 'BLUE');
/// ```
///
/// ## Log Levels:
/// - **Debug**: For detailed debugging information (🔍)
/// - **Info**: For general information (ℹ️)
/// - **Success**: For successful operations (✅)
/// - **Warning**: For warnings (⚠️)
/// - **Error**: For errors (❌)
///
/// ## Best Practices:
/// - Use `debug()` for detailed debugging during development
/// - Use `info()` for general information about app flow
/// - Use `success()` for successful operations
/// - Use `warning()` for potential issues
/// - Use `error()` for errors with stack traces
/// - Use `json()` for pretty printing JSON data
class PrettyLogger {
  // Private constructor to prevent instantiation
  PrettyLogger._();

  /// Enable or disable logging (useful for production builds)
  static bool enabled = kDebugMode;

  /// Enable or disable timestamps in logs
  static bool showTimestamp = true;

  /// Enable or disable emojis in logs
  static bool showEmojis = true;

  /// Maximum length for log messages before truncation
  static int maxMessageLength = 500;

  // ==================== LOG LEVELS ====================

  /// Log a debug message
  ///
  /// Use this for detailed debugging information during development.
  ///
  /// Example:
  /// ```dart
  /// PrettyLogger.debug('Processing user data', data: userData);
  /// ```
  ///
  /// Output:
  /// ```
  /// 🔍 [DEBUG] [2024-01-15 10:30:45] Processing user data
  /// ```
  static void debug(
    String message, {
    Object? data,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (!enabled) return;
    _log(
      emoji: '🔍',
      level: 'DEBUG',
      message: message,
      data: data,
      stackTrace: stackTrace,
      tag: tag,
      color: _LogColor.green,
    );
  }

  /// Log an info message
  ///
  /// Use this for general information about app flow.
  ///
  /// Example:
  /// ```dart
  /// PrettyLogger.info('User navigated to products page');
  /// ```
  ///
  /// Output:
  /// ```
  /// ℹ️ [INFO] [2024-01-15 10:30:45] User navigated to products page
  /// ```
  static void info(
    String message, {
    Object? data,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (!enabled) return;
    _log(
      emoji: 'ℹ️',
      level: 'INFO',
      message: message,
      data: data,
      stackTrace: stackTrace,
      tag: tag,
      color: _LogColor.green,
    );
  }

  /// Log a success message
  ///
  /// Use this for successful operations.
  ///
  /// Example:
  /// ```dart
  /// PrettyLogger.success('Product saved successfully');
  /// ```
  ///
  /// Output:
  /// ```
  /// ✅ [SUCCESS] [2024-01-15 10:30:45] Product saved successfully
  /// ```
  static void success(
    String message, {
    Object? data,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (!enabled) return;
    _log(
      emoji: '✅',
      level: 'SUCCESS',
      message: message,
      data: data,
      stackTrace: stackTrace,
      tag: tag,
      color: _LogColor.green,
    );
  }

  /// Log a warning message
  ///
  /// Use this for potential issues or warnings.
  ///
  /// Example:
  /// ```dart
  /// PrettyLogger.warning('Low stock detected for product ${productId}');
  /// ```
  ///
  /// Output:
  /// ```
  /// ⚠️ [WARNING] [2024-01-15 10:30:45] Low stock detected for product 123
  /// ```
  static void warning(
    String message, {
    Object? data,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (!enabled) return;
    _log(
      emoji: '⚠️',
      level: 'WARNING',
      message: message,
      data: data,
      stackTrace: stackTrace,
      tag: tag,
      color: _LogColor.green,
    );
  }

  /// Log an error message
  ///
  /// Use this for errors. Always include error and stackTrace when available.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await saveProduct(product);
  /// } catch (e, st) {
  ///   PrettyLogger.error('Failed to save product', error: e, stackTrace: st);
  /// }
  /// ```
  ///
  /// Output:
  /// ```
  /// ❌ [ERROR] [2024-01-15 10:30:45] Failed to save product
  /// Error: DatabaseException: Connection failed
  /// StackTrace: ...
  /// ```
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Object? data,
    String? tag,
  }) {
    if (!enabled) return;
    _log(
      emoji: '❌',
      level: 'ERROR',
      message: message,
      data: data ?? error,
      stackTrace: stackTrace,
      tag: tag,
      color: _LogColor.green,
    );
  }

  // ==================== SPECIAL LOGGING METHODS ====================

  /// Pretty print JSON data
  ///
  /// Use this to pretty print JSON objects or maps.
  ///
  /// Example:
  /// ```dart
  /// PrettyLogger.json('Product Data', productModel.toJson());
  /// ```
  ///
  /// Output:
  /// ```
  /// 📄 [JSON] [2024-01-15 10:30:45] Product Data
  /// {
  ///   "id": "123",
  ///   "name": "Product Name",
  ///   "price": 99.99
  /// }
  /// ```
  static void json(String title, Object? jsonData, {String? tag}) {
    if (!enabled) return;

    final timestamp = showTimestamp ? _getTimestamp() : '';
    final emoji = showEmojis ? '📄' : '';
    final tagStr = tag != null ? '[$tag] ' : '';

    final header = _buildHeader(
      emoji,
      'JSON',
      timestamp,
      tagStr,
      _LogColor.green,
    );

    developer.log(header, name: 'Dexter');

    if (jsonData != null) {
      try {
        // Format JSON with indentation
        final jsonString = _formatJson(jsonData);
        developer.log(jsonString, name: 'Dexter');
      } catch (e) {
        developer.log('⚠️ Failed to format JSON: $e', name: 'Dexter');
        developer.log(jsonData.toString(), name: 'Dexter');
      }
    } else {
      developer.log('null', name: 'Dexter');
    }

    developer.log(_buildSeparator(), name: 'Dexter');
  }

  /// Log a custom message with custom emoji and color
  ///
  /// Example:
  /// ```dart
  /// PrettyLogger.custom('🚀', 'Custom Event', 'BLUE');
  /// ```
  static void custom(
    String emoji,
    String message, {
    String color = 'WHITE',
    Object? data,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (!enabled) return;
    _log(
      emoji: emoji,
      level: 'CUSTOM',
      message: message,
      data: data,
      stackTrace: stackTrace,
      tag: tag,
      color: _LogColor.fromString(color),
    );
  }

  /// Log a separator line (useful for grouping logs)
  ///
  /// Example:
  /// ```dart
  /// PrettyLogger.separator();
  /// ```
  static void separator({String? label}) {
    if (!enabled) return;
    if (label != null) {
      developer.log(
        '${_buildSeparator()} $label ${_buildSeparator()}',
        name: 'Dexter',
      );
    } else {
      developer.log(_buildSeparator(), name: 'Dexter');
    }
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Internal log method that handles all logging
  static void _log({
    required String emoji,
    required String level,
    required String message,
    Object? data,
    StackTrace? stackTrace,
    String? tag,
    required _LogColor color,
  }) {
    final timestamp = showTimestamp ? _getTimestamp() : '';
    final emojiStr = showEmojis ? '$emoji ' : '';
    final tagStr = tag != null ? '[$tag] ' : '';

    // Build the main log message
    final header = _buildHeader(emojiStr, level, timestamp, tagStr, color);
    final truncatedMessage = _truncateMessage(message);

    developer.log('$header$truncatedMessage', name: 'Dexter');

    // Log data if provided
    if (data != null) {
      final dataStr = _formatData(data);
      developer.log('   📦 Data: $dataStr', name: 'Dexter');
    }

    // Log stack trace if provided
    if (stackTrace != null) {
      developer.log(
        '   📍 StackTrace:\n${stackTrace.toString()}',
        name: 'Dexter',
      );
    }

    // Add separator for readability
    developer.log(_buildSeparator(), name: 'Dexter');
  }

  /// Build the log header with formatting
  static String _buildHeader(
    String emoji,
    String level,
    String timestamp,
    String tag,
    _LogColor color,
  ) {
    final parts = <String>[];
    if (emoji.isNotEmpty) parts.add(emoji);
    parts.add('[$level]');
    if (timestamp.isNotEmpty) parts.add('[$timestamp]');
    if (tag.isNotEmpty) parts.add(tag);
    return parts.join(' ');
  }

  /// Get formatted timestamp
  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}-${_padZero(now.month)}-${_padZero(now.day)} '
        '${_padZero(now.hour)}:${_padZero(now.minute)}:${_padZero(now.second)}';
  }

  /// Pad number with zero if needed
  static String _padZero(int number) {
    return number.toString().padLeft(2, '0');
  }

  /// Truncate message if too long
  static String _truncateMessage(String message) {
    if (message.length <= maxMessageLength) {
      return message;
    }
    return '${message.substring(0, maxMessageLength)}... (truncated)';
  }

  /// Format data object for logging
  static String _formatData(Object data) {
    if (data is Map || data is List) {
      try {
        return _formatJson(data);
      } catch (e) {
        return data.toString();
      }
    }
    return data.toString();
  }

  /// Format JSON with indentation
  static String _formatJson(Object jsonData) {
    // Simple JSON formatting with indentation
    if (jsonData is Map) {
      return _formatMap(jsonData, 0);
    } else if (jsonData is List) {
      return _formatList(jsonData, 0);
    }
    return jsonData.toString();
  }

  /// Format map with indentation
  static String _formatMap(Map map, int indent) {
    if (map.isEmpty) return '{}';
    final indentStr = '  ' * indent;
    final nextIndent = '  ' * (indent + 1);
    final buffer = StringBuffer('{\n');
    final entries = map.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isLast = i == entries.length - 1;
      buffer.write('$nextIndent"${entry.key}": ');
      if (entry.value is Map) {
        buffer.write(_formatMap(entry.value as Map, indent + 1));
      } else if (entry.value is List) {
        buffer.write(_formatList(entry.value as List, indent + 1));
      } else {
        buffer.write(_formatValue(entry.value));
      }
      if (!isLast) buffer.write(',');
      buffer.write('\n');
    }
    buffer.write('$indentStr}');
    return buffer.toString();
  }

  /// Format list with indentation
  static String _formatList(List list, int indent) {
    if (list.isEmpty) return '[]';
    final indentStr = '  ' * indent;
    final nextIndent = '  ' * (indent + 1);
    final buffer = StringBuffer('[\n');
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final isLast = i == list.length - 1;
      buffer.write(nextIndent);
      if (item is Map) {
        buffer.write(_formatMap(item, indent + 1));
      } else if (item is List) {
        buffer.write(_formatList(item, indent + 1));
      } else {
        buffer.write(_formatValue(item));
      }
      if (!isLast) buffer.write(',');
      buffer.write('\n');
    }
    buffer.write('$indentStr]');
    return buffer.toString();
  }

  /// Format value for JSON output
  static String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"$value"';
    if (value is num || value is bool) return value.toString();
    return '"${value.toString()}"';
  }

  /// Build separator line
  static String _buildSeparator() {
    return '─' * 80;
  }
}

/// Log color enum (for future color support in console)
enum _LogColor {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white;

  static _LogColor fromString(String color) {
    switch (color.toUpperCase()) {
      case 'BLACK':
        return _LogColor.black;
      case 'RED':
        return _LogColor.red;
      case 'GREEN':
        return _LogColor.green;
      case 'YELLOW':
        return _LogColor.yellow;
      case 'BLUE':
        return _LogColor.blue;
      case 'MAGENTA':
        return _LogColor.magenta;
      case 'CYAN':
        return _LogColor.cyan;
      case 'WHITE':
      default:
        return _LogColor.white;
    }
  }
}
