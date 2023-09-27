// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_anon_outputs_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnonOutput _$AnonOutputFromJson(Map<String, dynamic> json) => AnonOutput(
      ringctindex: json['ringctindex'] as int?,
      pubkey: json['pubkey'] as String?,
      commitment: json['commitment'] as String?,
      tx_hash: json['tx_hash'] as String?,
      tx_index: json['tx_index'] as String?,
      blockheight: json['blockheight'] as int?,
      compromised: json['compromised'] as int?,
      raw: json['raw'] as String?,
    );

Map<String, dynamic> _$AnonOutputToJson(AnonOutput instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('ringctindex', instance.ringctindex);
  writeNotNull('pubkey', instance.pubkey);
  writeNotNull('commitment', instance.commitment);
  writeNotNull('tx_hash', instance.tx_hash);
  writeNotNull('tx_index', instance.tx_index);
  writeNotNull('blockheight', instance.blockheight);
  writeNotNull('compromised', instance.compromised);
  writeNotNull('raw', instance.raw);
  return val;
}

GetAnonOutputsResponse _$GetAnonOutputsResponseFromJson(
        Map<String, dynamic> json) =>
    GetAnonOutputsResponse(
      result: (json['result'] as List<dynamic>?)
          ?.map((e) => AnonOutput.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as int?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetAnonOutputsResponseToJson(
    GetAnonOutputsResponse instance) {
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
