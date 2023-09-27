// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_raw_mempool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetRawMempool _$GetRawMempoolFromJson(Map<String, dynamic> json) =>
    GetRawMempool(
      (json['result'] as List<dynamic>).map((e) => e as String).toList(),
      id: json['id'] as String?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetRawMempoolToJson(GetRawMempool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'error': instance.error,
      'result': instance.result,
    };
