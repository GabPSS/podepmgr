import 'package:devbox_dart/src/logger.dart';
import 'package:devbox_dart/src/models/environment.dart';
import 'package:devbox_dart/src/models/plugin.dart';

/// A class for running DevBox environments and plugins.
///
/// This class provides a static methods for running DevBox environments and plugins, and a helper method for running them unattended.
///
/// The [runEnvironment] method runs a DevBox environment and returns the exit code of the process.
///
/// The [runPlugins] method takes a list of DevBox plugins and runs each one until completion.
///
/// The [runUnattended] method runs a DevBox environment and plugins unattended, returning the exit code of the process.
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
