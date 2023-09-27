import "package:json_annotation/json_annotation.dart";
import "package:veil_light_plugin/src/models/rpc/json_rpc_error.dart";
import "package:veil_light_plugin/src/models/rpc/rpc_response.dart";

part 'get_anon_outputs_response.g.dart';

@JsonSerializable()
class AnonOutput {
  final int ringctindex;
  final String pubkey;
  final String commitment;
  final String tx_hash;
  final String tx_index; // number?
  final int blockheight;
  final int compromised;
  final String raw;

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

@JsonSerializable()
class GetAnonOutputsResponse extends RpcResponse {
  final List<AnonOutput> result;

  GetAnonOutputsResponse(
      {required this.result, required super.id, required super.error});

  factory GetAnonOutputsResponse.fromJson(Map<String, dynamic> json) =>
      _$GetAnonOutputsResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetAnonOutputsResponseToJson(this);
}
