// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_raw_mempool.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetRawMempool _$GetRawMempoolFromJson(Map<String, dynamic> json) =>
    GetRawMempool(
      (json['result'] as List<dynamic>?)?.map((e) => e as String).toList(),
      id: json['id'] as int?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetRawMempoolToJson(GetRawMempool instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('error', instance.error);
  writeNotNull('result', instance.result);
  return val;
}
