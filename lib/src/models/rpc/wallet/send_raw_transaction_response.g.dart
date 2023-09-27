// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_raw_transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendRawTransactionResponse _$SendRawTransactionResponseFromJson(
        Map<String, dynamic> json) =>
    SendRawTransactionResponse(
      json['result'] as String?,
      id: json['id'] as int?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SendRawTransactionResponseToJson(
    SendRawTransactionResponse instance) {
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
