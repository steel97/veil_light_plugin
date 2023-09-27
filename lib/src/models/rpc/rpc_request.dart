import 'package:json_annotation/json_annotation.dart';

part 'rpc_request.g.dart';

@JsonSerializable()
class RpcRequest {
  final String jsonrpc;
  final String? id;
  final String method;
  final List<dynamic>? params;

  RpcRequest(
      {required this.jsonrpc,
      this.id,
      required this.method,
      required this.params});

  factory RpcRequest.fromJson(Map<String, dynamic> json) =>
      _$RpcRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RpcRequestToJson(this);
}
