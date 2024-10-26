import 'dart:convert';
import 'dart:io';

import 'environment.dart';
import '../logger.dart';
import 'plugin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;

part 'config.g.dart';

@JsonSerializable()
class Config {
  List<Environment> environments = [];
  List<Plugin> plugins = [];
  List<String> paths = [];
  String rootPath = "";
  String pluginsDir = "";
  String assetsDir = "";
  static const String defaultBinDir = "bin";
  static const String defaultExecPath = "bin\\devbox\\devbox";
  static const String defaultSourceDir = "src";
  static const String defaultPluginsDir = "plugins";
  static const String defaultAssetsDir = "assets";

  Config();

  ///Generates a starter configuration file with
  Config.makeDefault()
      : environments = [
          Environment(
            name: "Command Prompt",
            absolute: true,
            path: "cmd",
            args: "",
          ),
          Environment(
            name: "Notepad",
            absolute: true,
            path: "notepad",
            args: "",
          ),
        ],
        pluginsDir = p.join(Directory.current.path, defaultPluginsDir),
        rootPath = Directory.current.path,
        paths = [],
        assetsDir = p.join(Directory.current.path, defaultAssetsDir);

  static Future<Config> loadFromFile(
      [String configFilePath = "config.json"]) async {
    try {
      Logger.instance.log("Loading settings...", LogLevel.debug);

      var source = await File(configFilePath).readAsString();
      Map<String, dynamic> configJson = jsonDecode(source);
      return Config.fromJson(configJson);
    } catch (e) {
      Logger.instance.log("${e.runtimeType}: $e", LogLevel.debug);
      Logger.instance.log(
          "Failed to load settings file, attempting to create one",
          LogLevel.warning);

      var newConfig = Config.makeDefault();

      try {
        await newConfig.saveConfig(configFilePath);

        Logger.instance.log(
            "Config file reset. New file saved at $configFilePath",
            LogLevel.warning);
        return newConfig;
      } catch (e) {
        Logger.instance.log(
            "Failed to read or create settings file. Make sure file isn't blocked by other programs or permissions",
            LogLevel.error);
        rethrow;
      }
    }
  }

  Future<void> saveConfig(String configFilePath) async {
    var file = File(configFilePath);
    await file.writeAsString(jsonEncode(toJson()), flush: true);
  }

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
