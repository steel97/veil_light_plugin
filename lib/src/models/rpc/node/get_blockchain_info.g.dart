// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_blockchain_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetBlockchainInfoResult _$GetBlockchainInfoResultFromJson(
        Map<String, dynamic> json) =>
    GetBlockchainInfoResult(
      chain: json['chain'] as String,
      blocks: json['blocks'] as int,
      moneysupply: json['moneysupply'] as int,
      zerocoinsupply: (json['zerocoinsupply'] as List<dynamic>)
          .map((e) => ZerocoinSupply.fromJson(e as Map<String, dynamic>))
          .toList(),
      bestblockhash: json['bestblockhash'] as String,
      difficulty_pow: json['difficulty_pow'] as int,
      difficulty_randomx: json['difficulty_randomx'] as int,
      difficulty_progpow: json['difficulty_progpow'] as int,
      difficulty_sha256d: json['difficulty_sha256d'] as int,
      difficulty_pos: json['difficulty_pos'] as int,
      mediantime: json['mediantime'] as int,
      size_on_disk: json['size_on_disk'] as int,
      next_super_block: json['next_super_block'] as int,
    );

Map<String, dynamic> _$GetBlockchainInfoResultToJson(
        GetBlockchainInfoResult instance) =>
    <String, dynamic>{
      'chain': instance.chain,
      'blocks': instance.blocks,
      'moneysupply': instance.moneysupply,
      'zerocoinsupply': instance.zerocoinsupply,
      'bestblockhash': instance.bestblockhash,
      'difficulty_pow': instance.difficulty_pow,
      'difficulty_randomx': instance.difficulty_randomx,
      'difficulty_progpow': instance.difficulty_progpow,
      'difficulty_sha256d': instance.difficulty_sha256d,
      'difficulty_pos': instance.difficulty_pos,
      'mediantime': instance.mediantime,
      'size_on_disk': instance.size_on_disk,
      'next_super_block': instance.next_super_block,
    };

ZerocoinSupply _$ZerocoinSupplyFromJson(Map<String, dynamic> json) =>
    ZerocoinSupply(
      denom: json['denom'] as String,
      amount: json['amount'] as int,
      percent: json['percent'] as int,
    );

Map<String, dynamic> _$ZerocoinSupplyToJson(ZerocoinSupply instance) =>
    <String, dynamic>{
      'denom': instance.denom,
      'amount': instance.amount,
      'percent': instance.percent,
    };

GetBlockchainInfo _$GetBlockchainInfoFromJson(Map<String, dynamic> json) =>
    GetBlockchainInfo(
      result: GetBlockchainInfoResult.fromJson(
          json['result'] as Map<String, dynamic>),
      id: json['id'] as String?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetBlockchainInfoToJson(GetBlockchainInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'error': instance.error,
      'result': instance.result,
    };
