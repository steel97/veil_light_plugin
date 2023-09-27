import 'package:json_annotation/json_annotation.dart';
import 'package:veil_light_plugin/src/models/rpc/json_rpc_error.dart';

part 'rpc_response.g.dart';

@JsonSerializable(includeIfNull: false)
class RpcResponse {
  int? id;
  JsonRpcError? error;

  RpcResponse({this.id, this.error});

  factory RpcResponse.fromJson(Map<String, dynamic> json) =>
      _$RpcResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RpcResponseToJson(this);
}
