import 'package:json_annotation/json_annotation.dart';

part 'json_rpc_error.g.dart';

@JsonSerializable()
class JsonRpcError {
  final int code;
  final String? message;

  JsonRpcError({required this.code, required this.message});

  factory JsonRpcError.fromJson(Map<String, dynamic> json) =>
      _$JsonRpcErrorFromJson(json);

  Map<String, dynamic> toJson() => _$JsonRpcErrorToJson(this);
}
