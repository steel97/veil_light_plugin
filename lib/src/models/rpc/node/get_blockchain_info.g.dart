// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_blockchain_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetBlockchainInfoResult _$GetBlockchainInfoResultFromJson(
        Map<String, dynamic> json) =>
    GetBlockchainInfoResult(
      chain: json['chain'] as String?,
      blocks: json['blocks'] as int?,
      moneysupply: json['moneysupply'] as int?,
      zerocoinsupply: (json['zerocoinsupply'] as List<dynamic>?)
          ?.map((e) => ZerocoinSupply.fromJson(e as Map<String, dynamic>))
          .toList(),
      bestblockhash: json['bestblockhash'] as String?,
      difficulty_pow: json['difficulty_pow'] as int?,
      difficulty_randomx: json['difficulty_randomx'] as int?,
      difficulty_progpow: json['difficulty_progpow'] as int?,
      difficulty_sha256d: json['difficulty_sha256d'] as int?,
      difficulty_pos: json['difficulty_pos'] as int?,
      mediantime: json['mediantime'] as int?,
      size_on_disk: json['size_on_disk'] as int?,
      next_super_block: json['next_super_block'] as int?,
    );

Map<String, dynamic> _$GetBlockchainInfoResultToJson(
    GetBlockchainInfoResult instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('chain', instance.chain);
  writeNotNull('blocks', instance.blocks);
  writeNotNull('moneysupply', instance.moneysupply);
  writeNotNull('zerocoinsupply', instance.zerocoinsupply);
  writeNotNull('bestblockhash', instance.bestblockhash);
  writeNotNull('difficulty_pow', instance.difficulty_pow);
  writeNotNull('difficulty_randomx', instance.difficulty_randomx);
  writeNotNull('difficulty_progpow', instance.difficulty_progpow);
  writeNotNull('difficulty_sha256d', instance.difficulty_sha256d);
  writeNotNull('difficulty_pos', instance.difficulty_pos);
  writeNotNull('mediantime', instance.mediantime);
  writeNotNull('size_on_disk', instance.size_on_disk);
  writeNotNull('next_super_block', instance.next_super_block);
  return val;
}

ZerocoinSupply _$ZerocoinSupplyFromJson(Map<String, dynamic> json) =>
    ZerocoinSupply(
      denom: json['denom'] as String?,
      amount: json['amount'] as int?,
      percent: json['percent'] as int?,
    );

Map<String, dynamic> _$ZerocoinSupplyToJson(ZerocoinSupply instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('denom', instance.denom);
  writeNotNull('amount', instance.amount);
  writeNotNull('percent', instance.percent);
  return val;
}

GetBlockchainInfo _$GetBlockchainInfoFromJson(Map<String, dynamic> json) =>
    GetBlockchainInfo(
      result: json['result'] == null
          ? null
          : GetBlockchainInfoResult.fromJson(
              json['result'] as Map<String, dynamic>),
      id: json['id'] as int?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetBlockchainInfoToJson(GetBlockchainInfo instance) {
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
