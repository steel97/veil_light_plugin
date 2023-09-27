import "package:json_annotation/json_annotation.dart";
import "package:veil_light_plugin/src/models/rpc/json_rpc_error.dart";
import "package:veil_light_plugin/src/models/rpc/rpc_response.dart";

part 'get_blockchain_info.g.dart';

@JsonSerializable()
class GetBlockchainInfoResult {
  final String chain;
  final int blocks;
  final int moneysupply;
  final List<ZerocoinSupply> zerocoinsupply;
  final String bestblockhash;
  final int difficulty_pow;
  final int difficulty_randomx;
  final int difficulty_progpow;
  final int difficulty_sha256d;
  final int difficulty_pos;
  final int mediantime;
  final int size_on_disk;
  final int next_super_block;

  GetBlockchainInfoResult(
      {required this.chain,
      required this.blocks,
      required this.moneysupply,
      required this.zerocoinsupply,
      required this.bestblockhash,
      required this.difficulty_pow,
      required this.difficulty_randomx,
      required this.difficulty_progpow,
      required this.difficulty_sha256d,
      required this.difficulty_pos,
      required this.mediantime,
      required this.size_on_disk,
      required this.next_super_block});

  factory GetBlockchainInfoResult.fromJson(Map<String, dynamic> json) =>
      _$GetBlockchainInfoResultFromJson(json);

  Map<String, dynamic> toJson() => _$GetBlockchainInfoResultToJson(this);
}

@JsonSerializable()
class ZerocoinSupply {
  final String denom;
  final int amount;
  final int percent;

  ZerocoinSupply(
      {required this.denom, required this.amount, required this.percent});

  factory ZerocoinSupply.fromJson(Map<String, dynamic> json) =>
      _$ZerocoinSupplyFromJson(json);

  Map<String, dynamic> toJson() => _$ZerocoinSupplyToJson(this);
}

@JsonSerializable()
class GetBlockchainInfo extends RpcResponse {
  final GetBlockchainInfoResult result;

  GetBlockchainInfo(
      {required this.result, required super.id, required super.error});

  factory GetBlockchainInfo.fromJson(Map<String, dynamic> json) =>
      _$GetBlockchainInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetBlockchainInfoToJson(this);
}
