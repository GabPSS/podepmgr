import 'dart:convert';
import 'dart:io';

import 'package:podepmgr/podepmgr_manager.dart';

import '../logger.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path/path.dart' as p;

part 'config.g.dart';

/// A class that defines essential podepmgr configuration.
///
/// This class defines the environments, plugins, path variables and default
/// directories for the current podepmgr installation. The configuration is stored
/// by default as a JSON file in `(root)/config.json`, and can be modified by
/// the user.
///
/// Because of this, care should be taken when reading the file and attempting
/// to run any programs.
///
/// The path where podepmgr starts is defined in [rootPath] and is by default the
/// root directory of a Windows partition with assigned drive letter.
/// (typically T:\\)
///
/// Path variables are defined in a basic string array. It is important that
/// **all user-defined paths MUST be absolute**, since podepmgr does not check for
/// any file or script's existence before adding it to the instance's PATH.
///
/// See [Environment], [Plugin] for details on these items.
@JsonSerializable()
class Config {
  List<Environment> environments = [];
  List<Plugin> plugins = [];
  List<String> paths = [];
  String rootPath = "";
  String pluginsDir = "";
  String assetsDir = "";
  static const String defaultBinDir = "bin";
  static const String defaultExecPath = "bin\\podepmgr";
  static const String defaultSourceDir = "src";
  static const String defaultPluginsDir = "plugins";
  static const String defaultAssetsDir = "assets";

  Config();

  /// Generates a basic default configuration file containing references to
  /// Command Prompt and Notepad, and no plugins or custom paths.
  ///
  /// This method is invoked when podepmgr Manager attempts to initialize (see [Manager.init]), but couldn't load the configuration file.
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
        paths = [p.join(Directory.current.path, defaultExecPath)],
        assetsDir = p.join(Directory.current.path, defaultAssetsDir);

  /// Generates a basic default configuration file for Unix systems containing references to
  /// Bash and Nano, and no plugins or custom paths.
  ///
  /// See [makeDefault] for more details.
  Config.makeDefaultUnix()
      : environments = [
          Environment(
            name: "Bash",
            absolute: true,
            path: "bash",
            args: "",
          ),
          Environment(
            name: "Nano",
            absolute: true,
            path: "nano",
            args: "",
          ),
        ],
        pluginsDir = p.join(Directory.current.path, defaultPluginsDir),
        rootPath = Directory.current.path,
        paths = [p.join(Directory.current.path, defaultExecPath)],
        assetsDir = p.join(Directory.current.path, defaultAssetsDir);

  /// Reads the configuration file specified at [configFilePath] and parses the
  /// configuration into a [Config] object.
  ///
  /// If it fails to read or parse the JSON file, it first attempts to create a
  /// new one via [Config.makeDefault] and write to disk.
  ///
  /// If both fail, it rethrows the error after logging an error.
  static Future<Config> loadFromFile(
      [String configFilePath = "config.json"]) async {
    try {
      Logger.log("Loading settings...", LogLevel.debug);

      var source = await File(configFilePath).readAsString();
      Map<String, dynamic> configJson = jsonDecode(source);
      return Config.fromJson(configJson);
    } catch (e) {
      Logger.log("${e.runtimeType}: $e", LogLevel.debug);
      Logger.log("Failed to load settings file, attempting to create one",
          LogLevel.warning);

      var newConfig = Config.makeDefault();

      try {
        await newConfig.saveConfig(configFilePath);

        Logger.log("Config file reset. New file saved at $configFilePath",
            LogLevel.warning);
        return newConfig;
      } catch (e) {
        Logger.log(
            "Failed to read or create settings file. Make sure file isn't blocked by other programs or permissions",
            LogLevel.error);
        rethrow;
      }
    }
  }

  /// Writes the current configuration file at [configFilePath].
  Future<void> saveConfig(String configFilePath) async {
    var file = File(configFilePath);
    await file.writeAsString(jsonEncode(toJson()), flush: true);
  }

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);
  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
