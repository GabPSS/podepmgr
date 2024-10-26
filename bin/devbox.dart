import 'dart:io';

import 'package:devbox_dart/devbox_cli.dart';
import 'package:devbox_dart/src/logger.dart';
import 'package:devbox_dart/src/manager.dart';

Future<void> main(List<String> arguments) async {
  DevBoxCLI cli = DevBoxCLI();

  if (arguments.isNotEmpty) {
    await handleConfiguration(arguments);
  } else {
    await cli.main();
  }
}

Future<void> handleConfiguration(List<String> arguments) async {
  switch (arguments[0]) {
    case "create":
      await Manager.instance.generateFiles(Platform.executable);
      Logger.log("Files created successfully", LogLevel.debug);
      break;
  }
}
