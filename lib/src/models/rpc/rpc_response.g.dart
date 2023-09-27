// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rpc_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcResponse _$RpcResponseFromJson(Map<String, dynamic> json) => RpcResponse(
      id: json['id'] as String?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RpcResponseToJson(RpcResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'error': instance.error,
    };
