import 'dart:io';
import 'package:devbox_dart/manager.dart';

import '../logger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment.g.dart';

@JsonSerializable()
class Environment {
  final String name;
  final String path;
  final bool absolute;
  @JsonKey(toJson: joinArgs)
  final List<String> args;

  Environment({
    required this.name,
    required this.absolute,
    required this.path,
    required String args,
  }) : args = args.split(' ');

  static String joinArgs(List<String> input) => input.join(" ");

  Future<int?> run() async {
    try {
      //Prepare path to run
      var execPath = absolute ? path : File(path).absolute.path;
      Logger.instance
          .log("Running $execPath ${args.join(" ")}".trim(), LogLevel.debug);

      //Start the process
      var process = await Process.start(
          execPath.trim(), args.where((arg) => arg != "").toList(),
          includeParentEnvironment: true,
          mode: ProcessStartMode.inheritStdio,
          environment: {"PATH": Manager.instance.portablePathVariable});

      //Wait for completion and dispose
      return await process.exitCode;
    } catch (e) {
      Logger.instance.log("Error while running program. $e", LogLevel.error);
      return null;
    }
  }

  factory Environment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentToJson(this);

  @override
  String toString() => name;
}
