// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_lightwallet_address_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportLightwalletStatus _$ImportLightwalletStatusFromJson(
        Map<String, dynamic> json) =>
    ImportLightwalletStatus(
      result: json['result'] as String?,
      stealth_address_bech: json['stealth_address_bech'] as String?,
      stealth_address_normal: json['stealth_address_normal'] as String?,
      imported_on: json['imported_on'] as int?,
      created_on: json['created_on'] as int?,
      watchonly: json['watchonly'] as bool?,
    );

Map<String, dynamic> _$ImportLightwalletStatusToJson(
    ImportLightwalletStatus instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('result', instance.result);
  writeNotNull('stealth_address_bech', instance.stealth_address_bech);
  writeNotNull('stealth_address_normal', instance.stealth_address_normal);
  writeNotNull('imported_on', instance.imported_on);
  writeNotNull('created_on', instance.created_on);
  writeNotNull('watchonly', instance.watchonly);
  return val;
}

ImportLightwalletAddressResponse _$ImportLightwalletAddressResponseFromJson(
        Map<String, dynamic> json) =>
    ImportLightwalletAddressResponse(
      json['result'] == null
          ? null
          : ImportLightwalletStatus.fromJson(
              json['result'] as Map<String, dynamic>),
      id: json['id'] as int?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImportLightwalletAddressResponseToJson(
    ImportLightwalletAddressResponse instance) {
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
