import "package:json_annotation/json_annotation.dart";
import "package:veil_light_plugin/src/models/rpc/json_rpc_error.dart";
import "package:veil_light_plugin/src/models/rpc/rpc_response.dart";

part 'get_anon_outputs_response.g.dart';

@JsonSerializable(includeIfNull: false)
class AnonOutput {
  int? ringctindex;
  String? pubkey;
  String? commitment;
  String? tx_hash;
  String? tx_index; // number?
  int? blockheight;
  int? compromised;
  String? raw;

  AnonOutput(
      {required this.ringctindex,
      required this.pubkey,
      required this.commitment,
      required this.tx_hash,
      required this.tx_index,
      required this.blockheight,
      required this.compromised,
      required this.raw});

  factory AnonOutput.fromJson(Map<String, dynamic> json) =>
      _$AnonOutputFromJson(json);

  Map<String, dynamic> toJson() => _$AnonOutputToJson(this);
}

@JsonSerializable(includeIfNull: false)
class GetAnonOutputsResponse extends RpcResponse {
  List<AnonOutput>? result;

  GetAnonOutputsResponse({this.result, super.id, super.error});

  factory GetAnonOutputsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAnonOutputsResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetAnonOutputsResponseToJson(this);
}
