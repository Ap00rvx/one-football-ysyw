import 'package:flutter/foundation.dart';

class Debug {
  // ANSI color codes
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  static const String _white = '\x1B[37m';
  static const String _bold = '\x1B[1m';

  /// Print function that only works in debug mode
  static void print(dynamic message, {DebugColor color = DebugColor.white}) {
    if (kDebugMode) {
      final colorCode = _getColorCode(color);
      final timestamp = DateTime.now().toString().substring(11, 23);
      debugPrint('$colorCode[$timestamp] $message$_reset');
    }
  }

  /// Print error messages in red
  static void error(dynamic message) {
    print('❌ ERROR: $message', color: DebugColor.red);
  }

  /// Print warning messages in yellow
  static void warning(dynamic message) {
    print('⚠️ WARNING: $message', color: DebugColor.yellow);
  }

  /// Print info messages in blue
  static void info(dynamic message) {
    print('ℹ️ INFO: $message', color: DebugColor.blue);
  }

  /// Print success messages in green
  static void success(dynamic message) {
    print('✅ SUCCESS: $message', color: DebugColor.green);
  }

  /// Print API-related messages in cyan
  static void api(dynamic message) {
    print('🌐 API: $message', color: DebugColor.cyan);
  }

  /// Print navigation messages in magenta
  static void navigation(dynamic message) {
    print('🧭 NAV: $message', color: DebugColor.magenta);
  }

  /// Print with custom prefix and color
  static void custom(dynamic message, String prefix, {DebugColor color = DebugColor.white}) {
    print('$prefix $message', color: color);
  }

  /// Get color code for the specified color
  static String _getColorCode(DebugColor color) {
    switch (color) {
      case DebugColor.red:
        return _red;
      case DebugColor.green:
        return _green;
      case DebugColor.yellow:
        return _yellow;
      case DebugColor.blue:
        return _blue;
      case DebugColor.magenta:
        return _magenta;
      case DebugColor.cyan:
        return _cyan;
      case DebugColor.white:
        return _white;
      case DebugColor.bold:
        return _bold;
    }
  }
}

/// Available debug colors
enum DebugColor {
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
  bold,
}