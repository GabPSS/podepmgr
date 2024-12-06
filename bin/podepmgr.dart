import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:podepmgr/podepmgr_manager.dart';
import 'package:podepmgr/src/cli/interactive_cli.dart';
import 'package:podepmgr/src/cli/manager_cli.dart';
import 'package:podepmgr/src/podepmgr_runner.dart';
import 'package:podepmgr/src/logger.dart';

Future<void> main(List<String> arguments) async {
  await Manager.init();

  CommandRunner("podepmgr", "Portable Development box manager")
    ..addCommand(StartCommand())
    ..addCommand(InitCommand())
    ..addCommand(RunCommand())
    ..addCommand(ListCommand())
    ..addCommand(AddEnvCommand())
    ..addCommand(AddPluginCommand())
    ..addCommand(EditCommand())
    ..run(arguments);
}

class ListCommand extends Command {
  @override
  final String name = "list";
  @override
  final String description = "Lists podepmgr environments and plugins";

  @override
  void run() {
    Manager.printConfig();
  }
}

class RunCommand extends Command {
  @override
  final String name = "runenv";
  @override
  final String description =
      "Sets up a podepmgr environment without user input";

  RunCommand() {
    argParser.addOption("environment", abbr: 'e', mandatory: true);
    argParser.addMultiOption("plugins", abbr: 'p');
  }

  @override
  Future<void> run() async {
    var results = argResults;
    if (results == null) return;

    var envIndex = int.tryParse(results.option("environment") ?? "");
    if (envIndex == null ||
        envIndex < 0 ||
        envIndex >= Manager.config.environments.length) {
      print(
          "Error: You must provide a valid environment. Run 'podepmgr list' to list available configurations.\nSee --help for details\n");
      return;
    }

    var plugins = results
        .multiOption("plugins")
        .map((index) => Manager.config.plugins[int.parse(index)])
        .toList();

    var env = Manager.config.environments[envIndex];

    await PodepmgrRunner.runUnattended(env, plugins);
  }
}

class InitCommand extends Command {
  @override
  final String name = "build";
  @override
  final String description = "Creates podepmgr starter files";

  InitCommand() {
    argParser.addFlag("no-folders",
        abbr: 'n', defaultsTo: false, negatable: false);
  }

  @override
  void run() {
    Manager.instance.generateFiles(
        Platform.executable, argResults?.flag("no-folders") ?? false);
  }
}

class StartCommand extends Command {
  @override
  final String name = "start";
  @override
  final String description = "Starts podepmgr interactively";

  StartCommand() {
    argParser.addFlag("verbose", abbr: 'v');
  }

  @override
  Future<void> run() async {
    if (argResults?.flag("verbose") ?? false) {
      Logger.instance.level = 2;
    }
    await InteractiveCLI().main();
  }
}

class AddEnvCommand extends Command {
  @override
  final String name = "addenv";

  @override
  final String description = "Adds a new environment to podepmgr";

  AddEnvCommand() {
    argParser.addOption("name",
        help: "The name of the environment", mandatory: true);
    argParser.addOption("path",
        help: "The path of the program to execute", mandatory: true);
    argParser.addFlag("absolute",
        help:
            "Whether or not the provided path should be considered absolute. If it is specified in the system's PATH, then this flag should be set. Otherwise, avoid providing absolute paths, since they require manual updates after a change to the podepmgr's root directory",
        defaultsTo: false);
    argParser.addOption("args",
        help: "Command-line arguments provided when the environment is run",
        defaultsTo: "");
  }

  @override
  Future<void> run() async {
    var args = argResults;
    if (args != null) {
      var nameOpt = args.option("name");
      var pathOpt = args.option("path");
      var argsOpt = args.option("args");
      var absFlag = args.flag("absolute");
      if (nameOpt != null && pathOpt != null && argsOpt != null) {
        var env = Environment(
          name: nameOpt,
          absolute: absFlag,
          path: pathOpt,
          args: argsOpt,
        );

        await Manager.init();

        Manager.config.environments.add(env);
        Manager.saveConfig();
      } else {
        print("Invalid arguments provided!");
        print(usage);
      }
    }
  }
}

class AddPluginCommand extends Command {
  @override
  final String name = "addplugin";

  @override
  final String description = "Adds a new plugin to podepmgr";

  AddPluginCommand() {
    argParser.addOption("name",
        help: "The name of the plugin", mandatory: true);
    argParser.addOption("env",
        help:
            "The path of the script file or environment where the script is run",
        mandatory: true);
    argParser.addOption("exec",
        help: "The path of the script file, if an environment was specified",
        defaultsTo: "");
  }

  @override
  FutureOr? run() {
    var args = argResults;
    if (args != null) {
      var nameOpt = args.option("name");
      var envOpt = args.option("env");
      var execOpt = args.option("exec");

      if (nameOpt != null && envOpt != null) {
        var plugin = Plugin(
          name: nameOpt,
          env: envOpt,
          exec: execOpt ?? "",
        );

        Manager.config.plugins.add(plugin);
        Manager.saveConfig();
      } else {
        print("Invalid arguments provided!");
        print(usage);
      }
    }
  }
}

/// A command for editing podepmgr configuration.
///
/// Calls the [ManagerCLI] class to provide a command line interface for editing podepmgr configuration interactively.
class EditCommand extends Command {
  @override
  final String name = "edit";
  @override
  final String description = "Launch UI for editing podepmgr configuration";

  @override
  Future<void> run() => ManagerCLI().main();
}
