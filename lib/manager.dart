import 'dart:io';

import 'package:devbox_dart/logger.dart';

import 'models/config.dart';
import 'models/environment.dart';

class Manager {
  late Config devboxConfig;
  final String configFilePath = "config.json";
  String get portablePathVariable =>
      [devboxConfig.paths.join(';'), Platform.environment["PATH"]].join(';');

  static Manager get instance => _instance;
  static final Manager _instance = Manager._();
  Manager._();

  bool _initRun = false;

  Future<bool> init() async {
    if (_initRun) return true;

    try {
      devboxConfig = await Config.loadFromFile(configFilePath);
      _initRun = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> generateFiles(String execPath,
      [bool skipFolderCreation = false]) async {
    Logger.instance.log(
        "Initializing directory structure and configuration", LogLevel.debug);

    //Create default config.json
    devboxConfig = Config.makeDefault();
    await devboxConfig.saveConfig(configFilePath);

    if (!skipFolderCreation) {
      //Create default directory structure
      await Directory(devboxConfig.assetsDir).create(recursive: true);
      await Directory(devboxConfig.pluginsDir).create(recursive: true);
      await Directory(Config.defaultSourceDir).create(recursive: true);
    }

    //Create default boot.bat
    await File("boot.bat").writeAsString(
        makeDefaultBootBatchScript(Platform.executable),
        mode: FileMode.write);
  }

  String makeDefaultBootBatchScript(String execPath) => """@echo off
title DevBox

$execPath
pause
""";

  Environment? selectEnvironment() {
    print("Available environments:");
    int index = 0;
    for (var env in devboxConfig.environments) {
      print("[${index++}] $env");
    }

    int input;
    do {
      stdout.write("Select an environment: ");
      var inputString = stdin.readLineSync();
      input = int.tryParse(inputString ?? "") ?? -1;
    } while (input < 0 && input >= devboxConfig.environments.length);

    return devboxConfig.environments[input];
  }

  Future<void> selectAndRunPlugins() async {
    print("Available plugins:");
    int index = 0;
    for (var plugin in devboxConfig.plugins) {
      print("[${index++}] $plugin");
    }

    int? input;
    do {
      stdout.write("Select a plugin (enter to stop): ");
      var inputString = stdin.readLineSync();
      input = int.tryParse(inputString ?? "");

      if (input != null && input >= 0 && input < devboxConfig.plugins.length) {
        await devboxConfig.plugins[input].load();
      }
    } while (input != null);
  }
}
