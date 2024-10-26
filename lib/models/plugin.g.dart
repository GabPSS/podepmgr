// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plugin _$PluginFromJson(Map<String, dynamic> json) => Plugin(
      env: json['env'] as String?,
      name: json['name'] as String,
      exec: json['exec'] as String,
    );

Map<String, dynamic> _$PluginToJson(Plugin instance) => <String, dynamic>{
      'name': instance.name,
      'env': instance.env,
      'exec': instance.exec,
    };
