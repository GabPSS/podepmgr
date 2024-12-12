// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config()
  ..environments = (json['environments'] as List<dynamic>)
      .map((e) => Environment.fromJson(e as Map<String, dynamic>))
      .toList()
  ..plugins = (json['plugins'] as List<dynamic>)
      .map((e) => Plugin.fromJson(e as Map<String, dynamic>))
      .toList()
  ..paths = (json['paths'] as List<dynamic>).map((e) => e as String).toList()
  ..rootPath = json['rootPath'] as String
  ..pluginsDir = json['pluginsDir'] as String
  ..assetsDir = json['assetsDir'] as String
  ..textEditor = json['textEditor'] as String;

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'environments': instance.environments,
      'plugins': instance.plugins,
      'paths': instance.paths,
      'rootPath': instance.rootPath,
      'pluginsDir': instance.pluginsDir,
      'assetsDir': instance.assetsDir,
      'textEditor': instance.textEditor,
    };
