class Logger {
  static bool isEnabled = true;

  static void log(dynamic message) {
    if (isEnabled) {
      print('[LOG] $message');
    }
  }

  static void error(dynamic message) {
    if (isEnabled) {
      print('[ERROR] $message');
    }
  }

  static void warning(dynamic message) {
    if (isEnabled) {
      print('[WARNING] $message');
    }
  }
}
