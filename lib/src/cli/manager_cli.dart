import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:podepmgr/podepmgr_manager.dart';

/// A class that provides a command line interface for editing podepmgr configuration.
///
/// Provides a default home menu with options to add, remove, and edit environments, plugins and paths.
///
/// To get started, call [main] to run through the basic script.
class ManagerCLI {
  /// Main method for the ManagerCLI class.
  Future<void> main() async {
    Console con = Console();
    con.clearScreen();

    con.writeLine("Welcome to podepmgr");
    con.writeLine("===================");
    if (await Manager.init()) {
      var exit = false;
      do {
        con.writeLine("e. Environments");
        con.writeLine("s. Plugins");
        con.writeLine("p. Paths");
        con.writeLine("q. Discard changes and exit");
        con.writeLine("x. Save changes and exit");
        con.write("Select an option: ");
        var input = con.readLine();
        switch (input) {
          case "e":
          case "E":
            _manageEnvironments(con);
            break;
          case "s":
          case "S":
            _managePlugins(con);
            break;
          case "p":
          case "P":
            await _editPaths(con);
            break;
          case "q":
          case "Q":
            exit = true;
            break;
          case "x":
          case "X":
            Manager.saveConfig();
            exit = true;
            break;
          default:
            break;
        }
      } while (!exit);
    } else {
      con.writeLine("Failed to initialize podepmgr. Exiting...");
    }
  }

  void _manageEnvironments(Console con) {
    con.clearScreen();
    String? input;
    do {
      con.writeLine("Available environments:");
      int index = 0;

      for (var env in Manager.config.environments) {
        con.writeLine("[${index++}] $env");
      }

      con.writeLine("a. Add environment");
      con.writeLine("r. Remove environment");
      con.writeLine("e. Edit environment");
      con.writeLine("x. Back to main menu");

      con.write("Select an option: ");
      input = con.readLine();
      switch (input) {
        case "a":
        case "A":
          _addEnvironment(con);
          break;
        case "r":
        case "R":
          _removeEnvironment(con);
          break;
        case "e":
        case "E":
          _editEnvironment(con);
          break;
        case "x":
        case "X":
          break;
      }
    } while (input != "x");
  }

  void _addEnvironment(Console con) {
    con.write("Enter the name of the environment: ");
    String? name = con.readLine() ?? "Unnamed environment";
    con.write("Enter the path to the environment: ");
    var path = con.readLine();
    if (path == null) {
      con.writeLine("Error: Path cannot be empty.");
      return;
    }
    con.write("Is the path absolute? (y/n): ");
    var absolute = (con.readLine()?.toLowerCase() ?? "n") == "y";
    con.write("Enter any command line arguments: ");
    var args = con.readLine();

    Manager.config.environments.add(Environment(
        name: name, path: path, absolute: absolute, args: args ?? ""));
    con.writeLine("Environment '$name' added successfully.");
    con.write("Press any key to continue...");
    con.readKey();
    con.clearScreen();
  }

  void _removeEnvironment(Console con) {
    con.write("Enter the index of the environment to remove: ");
    var index = int.tryParse(con.readLine() ?? "");
    if (index == null ||
        index < 0 ||
        index >= Manager.config.environments.length) {
      con.writeLine("Error: Invalid index.");
      return;
    }
    var env = Manager.config.environments.removeAt(index);
    con.writeLine("Environment '$env' removed successfully.");
    con.write("Press any key to continue...");
    con.readKey();
    con.clearScreen();
  }

  void _editEnvironment(Console con) {
    con.write("Enter the index of the environment to edit: ");
    var index = int.tryParse(con.readLine() ?? "");
    if (index == null ||
        index < 0 ||
        index >= Manager.config.environments.length) {
      con.writeLine("Error: Invalid index.");
      return;
    }
    var env = Manager.config.environments[index];

    con.writeLine("Editing environment: $env");
    con.write("Enter the new name of the environment [${env.name}]: ");
    var name = con.readLine();
    con.write("Enter the new path to the environment [${env.path}]: ");
    var path = con.readLine();
    con.write("Is the path absolute? (y/n) [${env.absolute}]: ");
    var absolute =
        (con.readLine()?.toLowerCase() ?? (env.absolute ? "y" : "n")) == "y";
    con.write("Enter any command line arguments [${env.args.join(" ")}]: ");
    var args = con.readLine();

    Environment newEnv = Environment(
        name: name == null || name.isEmpty ? env.name : name,
        path: path == null || path.isEmpty ? env.path : path,
        absolute: absolute,
        args: args == null || args.isEmpty ? env.args.join(" ") : args);

    Manager.config.environments[index] = newEnv;

    con.writeLine("Environment '$env' edited successfully.");
    con.write("Press any key to continue...");
    con.readKey();
    con.clearScreen();
  }

  void _managePlugins(Console con) {
    con.clearScreen();
    String? input;
    do {
      con.writeLine("Available plugins:");
      int index = 0;

      for (var plugin in Manager.config.plugins) {
        con.writeLine("[${index++}] $plugin");
      }

      con.writeLine("a. Add plugin");
      con.writeLine("r. Remove plugin");
      con.writeLine("e. Edit plugin");
      con.writeLine("x. Back to main menu");

      con.write("Select an option: ");
      input = con.readLine();
      switch (input) {
        case "a":
        case "A":
          _addPlugin(con);
          break;
        case "r":
        case "R":
          _removePlugin(con);
          break;
        case "e":
        case "E":
          _editPlugin(con);
          break;
        case "x":
        case "X":
          break;
      }
    } while (input != "x");
  }

  void _addPlugin(Console con) {
    con.write("Enter the name of the plugin: ");
    String? name = con.readLine() ?? "Unnamed plugin";
    con.write("Enter the path to the script or environment: ");
    var env = con.readLine();
    if (env == null) {
      con.writeLine("Error: Path cannot be empty.");
      return;
    }
    con.write(
        "Enter the path to the script (if an environment was specified): ");
    var exec = con.readLine();

    Manager.config.plugins.add(Plugin(name: name, env: env, exec: exec ?? ""));
    con.writeLine("Plugin '$name' added successfully.");
    con.write("Press any key to continue...");
    con.readKey();
    con.clearScreen();
  }

  void _removePlugin(Console con) {
    con.write("Enter the index of the plugin to remove: ");
    var index = int.tryParse(con.readLine() ?? "");
    if (index == null || index < 0 || index >= Manager.config.plugins.length) {
      con.writeLine("Error: Invalid index.");
      return;
    }
    var plugin = Manager.config.plugins.removeAt(index);
    con.writeLine("Plugin '$plugin' removed successfully.");
    con.write("Press any key to continue...");
    con.readKey();
    con.clearScreen();
  }

  void _editPlugin(Console con) {
    con.write("Enter the index of the plugin to edit: ");
    var index = int.tryParse(con.readLine() ?? "");
    if (index == null || index < 0 || index >= Manager.config.plugins.length) {
      con.writeLine("Error: Invalid index.");
      return;
    }
    var plugin = Manager.config.plugins[index];

    con.writeLine("Editing plugin: $plugin");
    con.write("Enter the new name of the plugin [${plugin.name}]: ");
    var name = con.readLine();
    con.write(
        "Enter the new path to the script or environment [${plugin.env}]: ");
    var env = con.readLine();
    con.write("Enter the new path to the script [${plugin.exec}]: ");
    var exec = con.readLine();

    Plugin newPlugin = Plugin(
        name: name == null || name.isEmpty ? plugin.name : name,
        env: env == null || env.isEmpty ? plugin.env : env,
        exec: exec == null || exec.isEmpty ? plugin.exec : exec);

    Manager.config.plugins[index] = newPlugin;

    con.writeLine("Plugin '$plugin' edited successfully.");
    con.write("Press any key to continue...");
    con.readKey();
    con.clearScreen();
  }

  Future<void> _editPaths(Console con) async {
    con.clearScreen();
    con.writeLine("Current paths:");
    for (var path in Manager.config.paths) {
      con.writeLine("\"$path\"");
    }

    con.writeLine("Exporting to paths.env...");

    var file = File("paths.env");
    await file.writeAsString(_createPathsFileContent(), mode: FileMode.write);

    con.writeLine("Launching path editor...");

    if (Platform.isWindows) {
      await Process.run("notepad", [file.path]);
    } else {
      await Process.run("nano", [file.path]);
    }

    con.writeLine("Reading new paths...");

    var newPaths = await file.readAsLines();

    Manager.config.paths =
        newPaths.where((path) => !path.startsWith("#")).toList();
    file.delete();

    con.writeLine("Paths updated successfully.");
    con.write("Press any key to continue...");
    con.readKey();
    con.clearScreen();
  }

  String _createPathsFileContent() => [
        "# podepmgr custom paths",
        "# =====================",
        "# This is a temporary file created for you to easily edit podepmgr paths. Lines starting with '#' will not be saved",
        "# Enter any custom paths below, remembering to keep them absolute!",
        "# Example: 'D:\\bin\\MyProgram' on Windows, and '/path/to/MyProgram' on *nix.",
        ...Manager.config.paths
      ].join(Platform.lineTerminator);
}
