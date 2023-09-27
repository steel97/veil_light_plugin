import "package:json_annotation/json_annotation.dart";
import "package:veil_light_plugin/src/models/rpc/json_rpc_error.dart";
import "package:veil_light_plugin/src/models/rpc/rpc_response.dart";

part 'send_raw_transaction_response.g.dart';

@JsonSerializable(includeIfNull: false)
class SendRawTransactionResponse extends RpcResponse {
  String? result;

  SendRawTransactionResponse(this.result, {super.id, super.error});

  factory SendRawTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$SendRawTransactionResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SendRawTransactionResponseToJson(this);
}
