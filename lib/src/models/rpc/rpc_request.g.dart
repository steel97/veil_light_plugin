// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpc_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcRequest _$RpcRequestFromJson(Map<String, dynamic> json) => RpcRequest(
      jsonrpc: json['jsonrpc'] as String,
      id: json['id'] as String?,
      method: json['method'] as String,
      params: json['params'] as List<dynamic>?,
    );

Map<String, dynamic> _$RpcRequestToJson(RpcRequest instance) =>
    <String, dynamic>{
      'jsonrpc': instance.jsonrpc,
      'id': instance.id,
      'method': instance.method,
      'params': instance.params,
    };
