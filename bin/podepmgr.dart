import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:dart_console/dart_console.dart';
import 'package:podepmgr/podepmgr_manager.dart';
import 'package:podepmgr/src/cli/interactive_cli.dart';
import 'package:podepmgr/src/cli/manager_cli.dart';
import 'package:podepmgr/src/podepmgr_runner.dart';
import 'package:podepmgr/src/logger.dart';

Future<void> main(List<String> arguments) async {
  if (arguments[0] == "init") {
    Logger.instance.level = -1;
  }
  await Manager.init();

  CommandRunner("podepmgr", "Portable Development box manager")
    ..addCommand(StartCommand())
    ..addCommand(BuildCommand())
    ..addCommand(ListCommand())
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

class BuildCommand extends Command {
  @override
  final String name = "init";
  @override
  final String description = "Creates podepmgr starter files";
  @override
  final bool hidden = true;

  @override
  Future<void> run() async {
    Console con = Console();
    con.writeLine("Welcome to podepmgr!");
    con.writeLine("====================");
    con.writeLine(
        "This utility will create the necessary files for podepmgr to run.");
    con.writeLine();
    con.write(
        "Would you like to create the default directory structure? (y/n) [y]:");
    bool skipDefaultDirs = con.readLine() == "n";

    await Manager.instance.generateFiles(Platform.executable, skipDefaultDirs);

    con.writeLine(
        "Files created successfully, thank you for choosing podepmgr!");
    con.writeLine();
    con.writeLine("Your root directory is: ${Manager.config.rootPath}");
    con.writeLine(
        "Your configuration is stored in: ${Manager.instance.configFilePath}");
    con.writeLine();
    con.writeLine(
        "You can now run 'podepmgr edit' to configure your environments.");
    con.writeLine(
        "Run 'podepmgr start' to start podepmgr in interactive mode, or run the included 'boot' script.");
    con.write("Press any key to exit...");
    con.readKey();
  }
}

class StartCommand extends Command {
  @override
  final String name = "start";
  @override
  final String description =
      "Starts podepmgr in interactive mode, or runs a specified environment";

  StartCommand() {
    argParser.addFlag("verbose",
        abbr: 'v', help: "Enable verbose logging", negatable: false);
    argParser.addOption("environment",
        abbr: 'e', help: "Run a specific environment in unattended mode");
    argParser.addMultiOption("plugins",
        abbr: 'p', help: "Run specified plugins in unattended mode");
  }

  @override
  Future<void> run() async {
    if (argResults?.flag("verbose") ?? false) {
      Logger.instance.level = 2;
    }

    var results = argResults;

    if (results != null && results.option("environment") != null) {
      await runUnattended(results);
    } else {
      await InteractiveCLI().main();
    }
  }

  Future<void> runUnattended(ArgResults results) async {
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
