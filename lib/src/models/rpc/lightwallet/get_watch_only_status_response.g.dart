// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_watch_only_status_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WatchOnlyStatus _$WatchOnlyStatusFromJson(Map<String, dynamic> json) =>
    WatchOnlyStatus(
      status: json['status'] as String?,
      stealth_address: json['stealth_address'] as String?,
      transactions_found: json['transactions_found'] as int?,
    );

Map<String, dynamic> _$WatchOnlyStatusToJson(WatchOnlyStatus instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('status', instance.status);
  writeNotNull('stealth_address', instance.stealth_address);
  writeNotNull('transactions_found', instance.transactions_found);
  return val;
}

GetWatchOnlyStatusResponse _$GetWatchOnlyStatusResponseFromJson(
        Map<String, dynamic> json) =>
    GetWatchOnlyStatusResponse(
      json['result'] == null
          ? null
          : WatchOnlyStatus.fromJson(json['result'] as Map<String, dynamic>),
      id: json['id'] as int?,
      error: json['error'] == null
          ? null
          : JsonRpcError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetWatchOnlyStatusResponseToJson(
    GetWatchOnlyStatusResponse instance) {
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
