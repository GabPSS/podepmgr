import 'dart:io';

import 'package:devbox_dart/src/manager.dart';

import '../logger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'plugin.g.dart';

@JsonSerializable()
class Plugin {
  final String name;
  final String? env;
  final String exec;

  Plugin({
    required this.env,
    required this.name,
    required this.exec,
  });

  Future<void> load() async {
    try {
      Logger.log("Running ${env ?? exec}", LogLevel.debug);
      var run = await Process.start(
          env ?? exec,
          env == null
              ? []
              : exec.split(" ").where((element) => element != "").toList(),
          mode: ProcessStartMode.inheritStdio,
          includeParentEnvironment: true,
          environment: {"PATH": Manager.instance.pathVar});

      int exitCode = await run.exitCode;
      // subscription.cancel();
      Logger.log("Exited with code $exitCode", LogLevel.debug);
    } catch (e) {
      Logger.log("Plugin failed to load: $e", LogLevel.warning);
    }
  }

  @override
  String toString() => name;

  factory Plugin.fromJson(Map<String, dynamic> json) => _$PluginFromJson(json);
  Map<String, dynamic> toJson() => _$PluginToJson(this);
}
