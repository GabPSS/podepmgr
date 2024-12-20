import 'package:podepmgr/src/logger.dart';
import 'package:podepmgr/src/models/environment.dart';
import 'package:podepmgr/src/models/plugin.dart';

/// A class for running podepmgr environments and plugins.
///
/// This class provides a static methods for coordenating the execution of podepmgr environments and plugins, and a helper method for running them unattended.
///
/// The [runEnvironment] method runs a podepmgr environment and returns the exit code of the process.
///
/// The [runPlugins] method takes a list of podepmgr plugins and runs each one until completion.
///
/// The [runUnattended] method runs a podepmgr environment and plugins unattended, returning the exit code of the process.
abstract final class Runner {
  static Future<int?> runEnvironment(Environment env,
      [bool runPlugins = false]) async {
    if (runPlugins) await env.prepare();
    var exitCode = await env.run();
    Logger.log("Process returned $exitCode", LogLevel.debug);
    return exitCode;
  }

  static Future<void> runPlugins(List<Plugin> plugins) async {
    for (var plugin in plugins) {
      await plugin.load();
    }
  }

  static Future<bool> runPluginAt(List<Plugin> plugins, int index) async {
    if (index < 0 || index >= plugins.length) return false;
    await plugins[index].load();
    return true;
  }

  static Future<int?> runUnattended(
      Environment env, List<Plugin> plugins) async {
    await runPlugins(plugins);
    return runEnvironment(env, true);
  }
}
