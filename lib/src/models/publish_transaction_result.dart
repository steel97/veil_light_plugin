import 'package:json_annotation/json_annotation.dart';

part 'publish_transaction_result.g.dart';

@JsonSerializable()
class PublishTransactionResult {
  final String? txid;
  final int? errorCode;
  final String? message;

  PublishTransactionResult({
    this.txid,
    this.errorCode,
    this.message,
  });

  factory PublishTransactionResult.fromJson(Map<String, dynamic> json) =>
      _$PublishTransactionResultFromJson(json);

  Map<String, dynamic> toJson() => _$PublishTransactionResultToJson(this);
}
