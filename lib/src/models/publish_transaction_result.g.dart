// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publish_transaction_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PublishTransactionResult _$PublishTransactionResultFromJson(
        Map<String, dynamic> json) =>
    PublishTransactionResult(
      txid: json['txid'] as String?,
      errorCode: json['errorCode'] as int?,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$PublishTransactionResultToJson(
        PublishTransactionResult instance) =>
    <String, dynamic>{
      'txid': instance.txid,
      'errorCode': instance.errorCode,
      'message': instance.message,
    };
