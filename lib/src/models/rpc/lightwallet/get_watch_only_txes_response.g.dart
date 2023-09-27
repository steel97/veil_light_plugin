// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_watch_only_txes_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchOnlyTx _$WatchOnlyTxFromJson(Map<String, dynamic> json) => WatchOnlyTx(
      json['type'] as String,
      json['keyimage'] as String?,
      json['amount'] as String?,
      json['spent'] as bool?,
      json['spent_in'] as String?,
      json['dbindex'] as int,
      json['tx_hash'] as String,
      json['n'] as int,
      json['ringct_index'] as int?,
      json['pubkey'] as String?,
      json['pubkey_hash'] as String?,
      json['scriptPubKey'] as String?,
      json['destination_bech32'] as String?,
      json['destination'] as String?,
      json['valueCommitment'] as String,
      json['data_hex'] as String,
      json['raw'] as String,
    );

Map<String, dynamic> _$WatchOnlyTxToJson(WatchOnlyTx instance) =>
    <String, dynamic>{
      'type': instance.type,
      'keyimage': instance.keyimage,
      'amount': instance.amount,
      'spent': instance.spent,
      'spent_in': instance.spent_in,
      'dbindex': instance.dbindex,
      'tx_hash': instance.tx_hash,
      'n': instance.n,
      'ringct_index': instance.ringct_index,
      'pubkey': instance.pubkey,
      'pubkey_hash': instance.pubkey_hash,
      'scriptPubKey': instance.scriptPubKey,
      'destination_bech32': instance.destination_bech32,
      'destination': instance.destination,
      'valueCommitment': instance.valueCommitment,
      'data_hex': instance.data_hex,
      'raw': instance.raw,
    };

GetWatchOnlyTxesResult _$GetWatchOnlyTxesResultFromJson(
        Map<String, dynamic> json) =>
    GetWatchOnlyTxesResult(
      (json['anon'] as List<dynamic>)
          .map((e) => WatchOnlyTx.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['stealth'] as List<dynamic>)
          .map((e) => WatchOnlyTx.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetWatchOnlyTxesResultToJson(
        GetWatchOnlyTxesResult instance) =>
    <String, dynamic>{
      'anon': instance.anon,
      'stealth': instance.stealth,
    };

GetWatchOnlyTxesResponse _$GetWatchOnlyTxesResponseFromJson(
        Map<String, dynamic> json) =>
    GetWatchOnlyTxesResponse(
      GetWatchOnlyTxesResult.fromJson(json['result'] as Map<String, dynamic>),
      id: json['id'] as String?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetWatchOnlyTxesResponseToJson(
        GetWatchOnlyTxesResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'error': instance.error,
      'result': instance.result,
    };
