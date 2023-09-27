// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpc_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcRequest _$RpcRequestFromJson(Map<String, dynamic> json) => RpcRequest(
      jsonrpc: json['jsonrpc'] as String,
      id: json['id'] as int?,
      method: json['method'] as String,
      params: json['params'] as List<dynamic>?,
    );

Map<String, dynamic> _$RpcRequestToJson(RpcRequest instance) {
  final val = <String, dynamic>{
    'jsonrpc': instance.jsonrpc,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['method'] = instance.method;
  writeNotNull('params', instance.params);
  return val;
}
