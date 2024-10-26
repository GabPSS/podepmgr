class Logger {
  static Logger get instance => _instance;
  static final Logger _instance = Logger._();
  Logger._();

  int level = 0; //-1 = silent

  void log(String content, LogLevel level) {
    if (level.index >= this.level) {
      print("[${level.name.toUpperCase()}] $content");
    }
  }
}

enum LogLevel { error, warning, debug }
