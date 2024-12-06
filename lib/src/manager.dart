import 'dart:io';

import 'package:podepmgr/src/consts.dart';
import 'package:podepmgr/src/logger.dart';

import 'models/config.dart';

/// A class for orchestrating podepmgr configuration
class Manager {
  static Manager get instance => _instance;
  static final Manager _instance = Manager._();
  Manager._();

  late Config _config;
  bool _initRun = false;

  /// Sets the default path for podepmgr's config file.
  ///
  /// See [Config] for details.
  String configFilePath = "config.json";

  /// Gets the current environment path variable prepended with custom paths provided by podepmgr configuration.
  String get pathVar {
    String separator = Platform.isWindows ? ';' : ':';
    return [_config.paths.join(separator), Platform.environment["PATH"]]
        .join(separator);
  }

  /// Loads podepmgr configuration for the first time.
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

  /// Generates the default directory structure and configuration for podepmgr.
  ///
  /// This function creates the default directories provided by podepmgr configuration by default. In order to skip this behavior, set [skipFolderCreation] to `true`.
  Future<void> generateFiles(String execPath,
      [bool skipFolderCreation = false]) async {
    Logger.log(
        "Initializing directory structure and configuration", LogLevel.debug);

    //Create default config.json
    _config =
        Platform.isWindows ? Config.makeDefault() : Config.makeDefaultUnix();
    await _config.saveConfig(configFilePath);

    if (!skipFolderCreation) {
      //Create default directory structure
      await Directory(_config.assetsDir).create(recursive: true);
      await Directory(_config.pluginsDir).create(recursive: true);
      await Directory(Config.defaultSourceDir).create(recursive: true);
    }

    //Create default boot scripts
    if (Platform.isWindows) {
      await File("boot.bat").writeAsString(
          createBootScript(Platform.executable),
          mode: FileMode.write);
    } else {
      await File("boot.sh").writeAsString(
          createBootScriptUnix(Platform.executable),
          mode: FileMode.write);
    }
  }

  /// Generates the text content of podepmgr's default boot script on Windows.
  ///
  /// By default, this script is created when [generateFiles] is called, during
  /// podepmgr's first-time setup procedure.
  String createBootScript(String execPath) => """@echo off
title podepmgr

$execPath start
pause
""";

  /// Generates the text content of podepmgr's default boot script on Unix systems.
  ///
  /// By default, this script is created when [generateFiles] is called, during
  /// podepmgr's first-time setup procedure.
  String createBootScriptUnix(String execPath) => """#!/bin/bash
  $execPath start
  exit""";

  /// Prints an overview of the current podepmgr configuration.
  static void printConfig() {
    print("""podepmgr configuration overview
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
