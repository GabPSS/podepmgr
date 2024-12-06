/// podepmgr's default command line interface.
///
/// This library contains only the [InteractiveCLI] class.
library;

import 'dart:io';
import 'package:podepmgr/src/podepmgr_runner.dart';
import 'package:podepmgr/src/logger.dart';
import 'package:podepmgr/src/manager.dart';
import 'package:podepmgr/src/models/environment.dart';

/// Default command line interface for accessing and managing podepmgr
/// interactively.
///
/// The goal of this class is not to manage every single thing about podepmgr as a
/// CLI application, but is to merely provide the interface for running it
/// interactively, without any parameters.
///
/// For a quick function to run podepmgr non-interactively, see
/// [PodepmgrRunner.runUnattended]
///
/// To get started, in a fresh instance, call [main] to run through the basic
/// script.
class InteractiveCLI {
  Future<void> main() async {
    print("Welcome to podepmgr");
    print("===================");
    if (await Manager.init()) {
      Environment? env;

      do {
        env = selectEnvironment();

        if (env != null) {
          await selectAndRunPlugins();
          var exitCode = await PodepmgrRunner.runEnvironment(env);
          Logger.log("Environment exited with code: $exitCode", LogLevel.debug);
        }
      } while (env != null);

      print("Thanks for using podepmgr!");
    } else {
      Logger.log("Failed to initialize podepmgr. Exiting...", LogLevel.warning);
    }
  }

  /// Allows the user to choose an environment to run
  Environment? selectEnvironment() {
    print("Available environments:");
    int index = 0;

    print("[-1] Exit podepmgr");
    for (var env in Manager.config.environments) {
      print("[${index++}] $env");
    }

    int input;
    do {
      stdout.write("Select an environment: ");
      var inputString = stdin.readLineSync();
      input = int.tryParse(inputString ?? "") ?? -1;
    } while (input < -1 && input >= Manager.config.environments.length);

    return input != -1 ? Manager.config.environments[input] : null;
  }

  /// Allows the user to run a set of plugins
  Future<void> selectAndRunPlugins() async {
    int? input;
    do {
      _displayPlugins();
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

  void _displayPlugins() {
    print("Available plugins:");
    int index = 0;
    for (var plugin in Manager.config.plugins) {
      print("[${index++}] $plugin");
    }
  }
}
