import 'dart:io';

import 'package:dart_console/dart_console.dart';
import 'package:path/path.dart';
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
    con.writeLine("==================");
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
            manageEnvironments(con);
            break;
          case "s":
          case "S":
            managePlugins(con);
            break;
          case "p":
          case "P":
            editPaths(con);
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

  /// A submenu for editing environments.
  ///
  /// Asks first if the user wants to add, remove or edit an environment. Then, asks for the index of the environment to edit (if applicable) after listing the available environments.
  void manageEnvironments(Console con) {
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
          addEnvironment(con);
          break;
        case "r":
        case "R":
          removeEnvironment(con);
          break;
        case "e":
        case "E":
          editEnvironment(con);
          break;
        case "x":
        case "X":
          break;
      }
    } while (input != "x");
  }

  void addEnvironment(Console con) {
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

  void removeEnvironment(Console con) {
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

  void editEnvironment(Console con) {
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

  void managePlugins(Console con) {}

  void editPaths(Console con) {}
}
