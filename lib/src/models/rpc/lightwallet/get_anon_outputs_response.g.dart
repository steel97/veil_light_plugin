// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_anon_outputs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnonOutput _$AnonOutputFromJson(Map<String, dynamic> json) => AnonOutput(
      ringctindex: json['ringctindex'] as int,
      pubkey: json['pubkey'] as String,
      commitment: json['commitment'] as String,
      tx_hash: json['tx_hash'] as String,
      tx_index: json['tx_index'] as String,
      blockheight: json['blockheight'] as int,
      compromised: json['compromised'] as int,
      raw: json['raw'] as String,
    );

Map<String, dynamic> _$AnonOutputToJson(AnonOutput instance) =>
    <String, dynamic>{
      'ringctindex': instance.ringctindex,
      'pubkey': instance.pubkey,
      'commitment': instance.commitment,
      'tx_hash': instance.tx_hash,
      'tx_index': instance.tx_index,
      'blockheight': instance.blockheight,
      'compromised': instance.compromised,
      'raw': instance.raw,
    };

GetAnonOutputsResponse _$GetAnonOutputsResponseFromJson(
        Map<String, dynamic> json) =>
    GetAnonOutputsResponse(
      result: (json['result'] as List<dynamic>)
          .map((e) => AnonOutput.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetAnonOutputsResponseToJson(
        GetAnonOutputsResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'error': instance.error,
      'result': instance.result,
    };
