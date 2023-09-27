// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_transaction_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuildTransactionResult _$BuildTransactionResultFromJson(
        Map<String, dynamic> json) =>
    BuildTransactionResult(
      json['fee'] as int,
      json['amountSent'] as int,
      txdata: json['txdata'] as String?,
    );

Map<String, dynamic> _$BuildTransactionResultToJson(
        BuildTransactionResult instance) =>
    <String, dynamic>{
      'fee': instance.fee,
      'txdata': instance.txdata,
      'amountSent': instance.amountSent,
    };
