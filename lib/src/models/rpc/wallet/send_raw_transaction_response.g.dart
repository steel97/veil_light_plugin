// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_raw_transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendRawTransactionResponse _$SendRawTransactionResponseFromJson(
        Map<String, dynamic> json) =>
    SendRawTransactionResponse(
      json['result'] as String?,
      id: json['id'] as String?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SendRawTransactionResponseToJson(
        SendRawTransactionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'error': instance.error,
      'result': instance.result,
    };
