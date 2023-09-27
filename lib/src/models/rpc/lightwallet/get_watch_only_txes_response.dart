import "package:json_annotation/json_annotation.dart";
import "package:veil_light_plugin/src/models/rpc/json_rpc_error.dart";
import "package:veil_light_plugin/src/models/rpc/rpc_response.dart";

part 'get_watch_only_txes_response.g.dart';

@JsonSerializable()
class WatchOnlyTx {
  final String type; //"stealth" | "anon"
  final String? keyimage;
  final String? amount;
  final bool? spent;
  final String? spent_in;
  final int dbindex;
  final String tx_hash;

  final int n; // txindex
  // ringct
  final int? ringct_index; //
  final String? pubkey;
  final String? pubkey_hash; // CBitcoinAddress
  // stealth
  final String? scriptPubKey;
  final String? destination_bech32;
  final String? destination;
  // common
  final String valueCommitment;
  final String data_hex;

  final String raw;

  WatchOnlyTx(
      this.type,
      this.keyimage,
      this.amount,
      this.spent,
      this.spent_in,
      this.dbindex,
      this.tx_hash,
      this.n,
      this.ringct_index,
      this.pubkey,
      this.pubkey_hash,
      this.scriptPubKey,
      this.destination_bech32,
      this.destination,
      this.valueCommitment,
      this.data_hex,
      this.raw);

  factory WatchOnlyTx.fromJson(Map<String, dynamic> json) =>
      _$WatchOnlyTxFromJson(json);

  Map<String, dynamic> toJson() => _$WatchOnlyTxToJson(this);
}

@JsonSerializable()
class GetWatchOnlyTxesResult {
  final List<WatchOnlyTx> anon;
  final List<WatchOnlyTx> stealth;

  GetWatchOnlyTxesResult(this.anon, this.stealth);

  factory GetWatchOnlyTxesResult.fromJson(Map<String, dynamic> json) =>
      _$GetWatchOnlyTxesResultFromJson(json);

  Map<String, dynamic> toJson() => _$GetWatchOnlyTxesResultToJson(this);
}

@JsonSerializable()
class GetWatchOnlyTxesResponse extends RpcResponse {
  final GetWatchOnlyTxesResult result;

  GetWatchOnlyTxesResponse(this.result,
      {required super.id, required super.error});

  factory GetWatchOnlyTxesResponse.fromJson(Map<String, dynamic> json) =>
      _$GetWatchOnlyTxesResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetWatchOnlyTxesResponseToJson(this);
}
