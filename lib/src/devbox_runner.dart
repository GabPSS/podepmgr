import 'package:devbox_dart/src/logger.dart';
import 'package:devbox_dart/src/models/environment.dart';
import 'package:devbox_dart/src/models/plugin.dart';

abstract class DevBoxRunner {
  static Future<int?> runEnvironment(Environment env) async {
    var exitCode = await env.run();
    Logger.log("Process returned $exitCode", LogLevel.debug);
    return exitCode;
  }

  static Future<void> runPlugins(List<Plugin> plugins) async {
    for (var plugin in plugins) {
      await plugin.load();
    }
  }

  static Future<int?> runUnattended(
      Environment env, List<Plugin> plugins) async {
    await runPlugins(plugins);
    return runEnvironment(env);
  }
}
