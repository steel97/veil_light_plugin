// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_key_images_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KeyImageResult _$KeyImageResultFromJson(Map<String, dynamic> json) =>
    KeyImageResult(
      status: json['status'] as String?,
      msg: json['msg'] as String?,
      spent: json['spent'] as bool?,
      spentinmempool: json['spentinmempool'] as bool?,
      txid: json['txid'] as String?,
    );

Map<String, dynamic> _$KeyImageResultToJson(KeyImageResult instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('status', instance.status);
  writeNotNull('msg', instance.msg);
  writeNotNull('spent', instance.spent);
  writeNotNull('spentinmempool', instance.spentinmempool);
  writeNotNull('txid', instance.txid);
  return val;
}

CheckKeyImagesResponse _$CheckKeyImagesResponseFromJson(
        Map<String, dynamic> json) =>
    CheckKeyImagesResponse(
      (json['result'] as List<dynamic>?)
          ?.map((e) => KeyImageResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as int?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CheckKeyImagesResponseToJson(
    CheckKeyImagesResponse instance) {
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
