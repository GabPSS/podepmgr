class Logger {
  static Logger get instance => _instance;
  static final Logger _instance = Logger._();
  Logger._();

  int level = 0; //-1 = silent

  void _log(String content, LogLevel level) {
    if (level.index >= this.level) {
      print("[${level.name.toUpperCase()}] $content");
    }
  }

  static void log(String content, LogLevel level) =>
      Logger.instance._log(content, level);
}

enum LogLevel { error, warning, debug }
