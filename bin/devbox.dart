import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:devbox_dart/src/cli/devbox_cli.dart';
import 'package:devbox_dart/src/devbox_runner.dart';
import 'package:devbox_dart/src/logger.dart';
import 'package:devbox_dart/src/manager.dart';

Future<void> main(List<String> arguments) async {
  await Manager.init();

  CommandRunner("devbox", "Portable Development box manager")
    ..addCommand(StartCommand())
    ..addCommand(InitCommand())
    ..addCommand(RunCommand())
    ..addCommand(StatusCommand())
    ..run(arguments);
}

class StatusCommand extends Command {
  @override
  final String name = "status";
  @override
  final String description = "Lists DevBox environments and plugins";

  @override
  void run() {
    Manager.printConfig();
  }
}

class RunCommand extends Command {
  @override
  final String name = "runenv";
  @override
  final String description = "Sets up a DevBox environment without user input";

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
          "Error: You must provide a valid environment. Run 'devbox status' to list available configurations.\nSee --help for details\n");
      return;
    }

    var plugins = results
        .multiOption("plugins")
        .map((index) => Manager.config.plugins[int.parse(index)])
        .toList();

    var env = Manager.config.environments[envIndex];

    await DevBoxRunner.runUnattended(env, plugins);
  }
}

class InitCommand extends Command {
  @override
  final String name = "build";
  @override
  final String description = "Creates DevBox starter files";

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
  final String description = "Starts DevBox interactively";

  StartCommand() {
    argParser.addFlag("verbose", abbr: 'v');
  }

  @override
  Future<void> run() async {
    if (argResults?.flag("verbose") ?? false) {
      Logger.instance.level = 2;
    }
    await DevBoxCLI().main();
  }
}
