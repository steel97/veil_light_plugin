// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_lightwallet_address_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImportLightwalletStatus _$ImportLightwalletStatusFromJson(
        Map<String, dynamic> json) =>
    ImportLightwalletStatus(
      json['result'] as String,
      json['stealth_address_bech'] as String,
      json['stealth_address_normal'] as String,
      json['imported_on'] as int,
      json['created_on'] as int,
      json['watchonly'] as bool,
    );

Map<String, dynamic> _$ImportLightwalletStatusToJson(
        ImportLightwalletStatus instance) =>
    <String, dynamic>{
      'result': instance.result,
      'stealth_address_bech': instance.stealth_address_bech,
      'stealth_address_normal': instance.stealth_address_normal,
      'imported_on': instance.imported_on,
      'created_on': instance.created_on,
      'watchonly': instance.watchonly,
    };

ImportLightwalletAddressResponse _$ImportLightwalletAddressResponseFromJson(
        Map<String, dynamic> json) =>
    ImportLightwalletAddressResponse(
      ImportLightwalletStatus.fromJson(json['result'] as Map<String, dynamic>),
      id: json['id'] as String?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ImportLightwalletAddressResponseToJson(
        ImportLightwalletAddressResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'error': instance.error,
      'result': instance.result,
    };
