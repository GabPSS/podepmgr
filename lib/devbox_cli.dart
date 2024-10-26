/// DevBox's default command line interface.
///
/// This library contains only the [DevBoxCLI] class.
library;

import 'dart:io';
import 'package:devbox_dart/src/logger.dart';
import 'package:devbox_dart/src/manager.dart';
import 'package:devbox_dart/src/models/environment.dart';

/// Default command line interface for accessing and managing DevBox
///
/// To get started, in a fresh instance, call [main] to run through the basic
/// script.
class DevBoxCLI {
  Future<void> main() async {
    print("Welcome to DevBox");
    print("==================");
    if (await Manager.init()) {
      Environment? env = selectEnvironment();

      if (env != null) {
        await selectAndRunPlugins();

        var exitCode = await env.run();

        Logger.log("Process returned $exitCode", LogLevel.debug);
        print("Process completed, exiting...");
        exit(exitCode ?? -1);
      }
    } else {
      Logger.log("Failed to initialize DevBox. Exiting...", LogLevel.warning);
    }
  }

  /// Allows the user to choose an environment to run
  Environment? selectEnvironment() {
    print("Available environments:");
    int index = 0;
    for (var env in Manager.config.environments) {
      print("[${index++}] $env");
    }

    int input;
    do {
      stdout.write("Select an environment: ");
      var inputString = stdin.readLineSync();
      input = int.tryParse(inputString ?? "") ?? -1;
    } while (input < 0 && input >= Manager.config.environments.length);

    return Manager.config.environments[input];
  }

  /// Allows the user to run a set of plugins
  Future<void> selectAndRunPlugins() async {
    print("Available plugins:");
    int index = 0;
    for (var plugin in Manager.config.plugins) {
      print("[${index++}] $plugin");
    }

    int? input;
    do {
      stdout.write("Select a plugin (enter to stop): ");
      var inputString = stdin.readLineSync();
      input = int.tryParse(inputString ?? "");

      if (input != null &&
          input >= 0 &&
          input < Manager.config.plugins.length) {
        await Manager.config.plugins[input].load();
      }
    } while (input != null);
  }
}
