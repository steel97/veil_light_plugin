// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';
import 'package:veil_light_plugin/src/models/rpc/json_rpc_error.dart';
import 'package:veil_light_plugin/src/models/rpc/rpc_response.dart';

part 'get_blockchain_info.g.dart';

@JsonSerializable(includeIfNull: false)
class GetBlockchainInfoResult {
  String? chain;
  int? blocks;
  int? moneysupply;
  List<ZerocoinSupply>? zerocoinsupply;
  String? bestblockhash;
  int? difficulty_pow;
  int? difficulty_randomx;
  int? difficulty_progpow;
  int? difficulty_sha256d;
  int? difficulty_pos;
  int? mediantime;
  int? size_on_disk;
  int? next_super_block;

  GetBlockchainInfoResult(
      {this.chain,
      this.blocks,
      this.moneysupply,
      this.zerocoinsupply,
      this.bestblockhash,
      this.difficulty_pow,
      this.difficulty_randomx,
      this.difficulty_progpow,
      this.difficulty_sha256d,
      this.difficulty_pos,
      this.mediantime,
      this.size_on_disk,
      this.next_super_block});

  factory GetBlockchainInfoResult.fromJson(Map<String, dynamic> json) =>
      _$GetBlockchainInfoResultFromJson(json);

  Map<String, dynamic> toJson() => _$GetBlockchainInfoResultToJson(this);
}

@JsonSerializable(includeIfNull: false)
class ZerocoinSupply {
  String? denom;
  int? amount;
  int? percent;

  ZerocoinSupply({this.denom, this.amount, this.percent});

  factory ZerocoinSupply.fromJson(Map<String, dynamic> json) =>
      _$ZerocoinSupplyFromJson(json);

  Map<String, dynamic> toJson() => _$ZerocoinSupplyToJson(this);
}

@JsonSerializable(includeIfNull: false)
class GetBlockchainInfo extends RpcResponse {
  GetBlockchainInfoResult? result;

  GetBlockchainInfo({this.result, super.id, super.error});

  factory GetBlockchainInfo.fromJson(Map<String, dynamic> json) =>
      _$GetBlockchainInfoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetBlockchainInfoToJson(this);
}
