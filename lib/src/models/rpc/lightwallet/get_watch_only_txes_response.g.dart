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

Map<String, dynamic> _$WatchOnlyTxToJson(WatchOnlyTx instance) {
  final val = <String, dynamic>{
    'type': instance.type,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('keyimage', instance.keyimage);
  writeNotNull('amount', instance.amount);
  writeNotNull('spent', instance.spent);
  writeNotNull('spent_in', instance.spent_in);
  val['dbindex'] = instance.dbindex;
  val['tx_hash'] = instance.tx_hash;
  val['n'] = instance.n;
  writeNotNull('ringct_index', instance.ringct_index);
  writeNotNull('pubkey', instance.pubkey);
  writeNotNull('pubkey_hash', instance.pubkey_hash);
  writeNotNull('scriptPubKey', instance.scriptPubKey);
  writeNotNull('destination_bech32', instance.destination_bech32);
  writeNotNull('destination', instance.destination);
  val['valueCommitment'] = instance.valueCommitment;
  val['data_hex'] = instance.data_hex;
  val['raw'] = instance.raw;
  return val;
}

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
      json['result'] == null
          ? null
          : GetWatchOnlyTxesResult.fromJson(
              json['result'] as Map<String, dynamic>),
      id: json['id'] as int?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetWatchOnlyTxesResponseToJson(
    GetWatchOnlyTxesResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('error', instance.error);
  writeNotNull('result', instance.result);
  return val;
}
