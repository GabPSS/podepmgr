import 'dart:io';

import 'package:devbox_dart/src/consts.dart';
import 'package:devbox_dart/src/logger.dart';

import 'models/config.dart';

class Manager {
  static Manager get instance => _instance;
  static final Manager _instance = Manager._();
  Manager._();

  late Config _config;
  bool _initRun = false;

  /// Sets the default path for DevBox's config file.
  ///
  /// See [Config] for details.
  String configFilePath = "config.json";
  String get pathVar =>
      [_config.paths.join(';'), Platform.environment["PATH"]].join(';');

  static Future<bool> init() => Manager.instance._init();
  static Config get config => Manager.instance._config;

  Future<bool> _init() async {
    if (_initRun) return true;

    try {
      _config = await Config.loadFromFile(configFilePath);
      _initRun = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> generateFiles(String execPath,
      [bool skipFolderCreation = false]) async {
    Logger.log(
        "Initializing directory structure and configuration", LogLevel.debug);

    //Create default config.json
    _config = Config.makeDefault();
    await _config.saveConfig(configFilePath);

    if (!skipFolderCreation) {
      //Create default directory structure
      await Directory(_config.assetsDir).create(recursive: true);
      await Directory(_config.pluginsDir).create(recursive: true);
      await Directory(Config.defaultSourceDir).create(recursive: true);
    }

    //Create default boot.bat
    await File("boot.bat").writeAsString(
        makeDefaultBootBatchScript(Platform.executable),
        mode: FileMode.write);
  }

  /// Generates the text content of DevBox's default boot script on Windows.
  ///
  /// By default, this script is created when [generateFiles] is called, during
  /// DevBox's first-time setup procedure.
  String makeDefaultBootBatchScript(String execPath) => """@echo off
title DevBox

$execPath start
pause
""";

  static void printConfig() {
    print("""DevBox configuration overview
=============================

Manager version: $managerVersion
Installed at: [${config.rootPath}]""");

    print("Available environments:");
    for (int i = 0; i < config.environments.length; i++) {
      print("[$i] ${config.environments[i].name}");
    }

    print("Available plugins:");
    for (int i = 0; i < config.plugins.length; i++) {
      print("[$i] ${config.plugins[i].name}");
    }
  }

  Future<void> _saveConfig() => config.saveConfig(configFilePath);
  static Future<void> saveConfig() => instance._saveConfig();
}
