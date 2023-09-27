// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_key_images_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyImageResult _$KeyImageResultFromJson(Map<String, dynamic> json) =>
    KeyImageResult(
      status: json['status'] as String,
      msg: json['msg'] as String,
      spent: json['spent'] as bool,
      spentinmempool: json['spentinmempool'] as bool,
      txid: json['txid'] as String?,
    );

Map<String, dynamic> _$KeyImageResultToJson(KeyImageResult instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'spent': instance.spent,
      'spentinmempool': instance.spentinmempool,
      'txid': instance.txid,
    };

CheckKeyImagesResponse _$CheckKeyImagesResponseFromJson(
        Map<String, dynamic> json) =>
    CheckKeyImagesResponse(
      (json['result'] as List<dynamic>)
          .map((e) => KeyImageResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CheckKeyImagesResponseToJson(
        CheckKeyImagesResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'error': instance.error,
      'result': instance.result,
    };
