// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_watch_only_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchOnlyStatus _$WatchOnlyStatusFromJson(Map<String, dynamic> json) =>
    WatchOnlyStatus(
      status: json['status'] as String,
      stealth_address: json['stealth_address'] as String,
      transactions_found: json['transactions_found'] as int?,
    );

Map<String, dynamic> _$WatchOnlyStatusToJson(WatchOnlyStatus instance) =>
    <String, dynamic>{
      'status': instance.status,
      'stealth_address': instance.stealth_address,
      'transactions_found': instance.transactions_found,
    };

GetWatchOnlyStatusResponse _$GetWatchOnlyStatusResponseFromJson(
        Map<String, dynamic> json) =>
    GetWatchOnlyStatusResponse(
      WatchOnlyStatus.fromJson(json['result'] as Map<String, dynamic>),
      id: json['id'] as String?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetWatchOnlyStatusResponseToJson(
        GetWatchOnlyStatusResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'error': instance.error,
      'result': instance.result,
    };
