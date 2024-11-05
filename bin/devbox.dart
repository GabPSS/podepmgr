import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:devbox_dart/src/cli/devbox_cli.dart';
import 'package:devbox_dart/src/logger.dart';
import 'package:devbox_dart/src/manager.dart';

Future<void> main(List<String> arguments) async {
  CommandRunner("devbox", "Portable Development box manager")
    ..addCommand(StartCommand())
    ..addCommand(InitCommand())
    ..run(arguments);
}

class InitCommand extends Command {
  @override
  final String name = "build";
  @override
  final String description = "Creates DevBox starter files";

  InitCommand() {
    argParser.addFlag("no-folders", abbr: 'n', defaultsTo: false);
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
