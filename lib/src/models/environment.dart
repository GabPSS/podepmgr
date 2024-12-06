import 'dart:io';
import 'package:podepmgr/src/manager.dart';
import 'package:podepmgr/src/models/config.dart';

import '../logger.dart';
import 'package:json_annotation/json_annotation.dart';

part 'environment.g.dart';

/// A class for defining and running a podepmgr environment.
///
/// An Environment in podepmgr is a program, specified at [path], that the user
/// wishes to run portably. Environments can be IDEs, toolsets, or any other
/// executable programs.
///
/// The [absolute] property sets if the specified path is absolute, meaning it
/// represents the entire path in which the program is located, and not a
/// reference relative to the working directory.
///
/// When defining environments, the user should **always** set the [absolute]
/// to false if the program is contained within [Config.defaultBinDir], so
/// that moving podepmgr to a different root direcotry is easier.
///
/// [args] may be empty if the user does not wish to specify and command line
/// arguments to be run while the environment is starting.
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

  /// Runs the program specified at [Environment.path] with the specified
  /// [Environment.args], redirecting stdin and stdout to the user's console.
  Future<int?> run() async {
    try {
      //Prepare path to run
      var execPath = absolute ? path : File(path).absolute.path;
      Logger.log("Running $execPath ${args.join(" ")}".trim(), LogLevel.debug);

      //Start the process
      var process = await Process.start(
          execPath.trim(), args.where((arg) => arg != "").toList(),
          includeParentEnvironment: true,
          mode: ProcessStartMode.inheritStdio,
          environment: {"PATH": Manager.instance.pathVar});

      //Wait for completion and dispose
      return await process.exitCode;
    } catch (e) {
      Logger.log("Error while running program. $e", LogLevel.error);
      return null;
    }
  }

  factory Environment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentFromJson(json);
  Map<String, dynamic> toJson() => _$EnvironmentToJson(this);

  @override
  String toString() => name;
}
