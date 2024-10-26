import 'dart:io';

import 'package:devbox_dart/models/environment.dart';
import 'package:devbox_dart/logger.dart';
import 'package:devbox_dart/manager.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isNotEmpty) {
    await handleConfiguration(arguments);
  } else {
    await startDevBox();
  }
}

Future<void> startDevBox() async {
  print("Welcome to DevBox");
  print("==================");
  if (await manager.init()) {
    //Select an environment first
    Environment? env = manager.selectEnvironment();
    if (env != null) {
      //Select plugins
      await manager.selectAndRunPlugins();
      //Run the environment
      var exitCode = await env.run();
      Logger.instance.log("Process returned $exitCode", LogLevel.debug);
      print("Process completed, exiting...");
      exit(exitCode ?? -1);
    }
  } else {
    Logger.instance
        .log("Failed to initialize DevBox. Exiting...", LogLevel.warning);
  }
}

Future<void> handleConfiguration(List<String> arguments) async {
  switch (arguments[0]) {
    case "create":
      await manager.generateFiles(Platform.executable);
      Logger.instance.log("Files created successfully", LogLevel.debug);
      break;
  }
}

//Shorthands
Manager get manager => Manager.instance;
