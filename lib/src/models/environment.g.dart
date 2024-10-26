// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Environment _$EnvironmentFromJson(Map<String, dynamic> json) => Environment(
      name: json['name'] as String,
      absolute: json['absolute'] as bool,
      path: json['path'] as String,
      args: json['args'] as String,
    );

Map<String, dynamic> _$EnvironmentToJson(Environment instance) =>
    <String, dynamic>{
      'name': instance.name,
      'path': instance.path,
      'absolute': instance.absolute,
      'args': Environment.joinArgs(instance.args),
    };
