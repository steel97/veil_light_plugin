import 'package:json_annotation/json_annotation.dart';

part 'build_transaction_result.g.dart';

@JsonSerializable()
class BuildTransactionResult {
  int fee;
  String? txdata;
  int amountSent;

  BuildTransactionResult(
    this.fee,
    this.amountSent, {
    this.txdata,
  });

  factory BuildTransactionResult.fromJson(Map<String, dynamic> json) =>
      _$BuildTransactionResultFromJson(json);

  Map<String, dynamic> toJson() => _$BuildTransactionResultToJson(this);
}
