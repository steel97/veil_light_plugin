import "package:json_annotation/json_annotation.dart";
import "package:veil_light_plugin/src/models/rpc/json_rpc_error.dart";
import "package:veil_light_plugin/src/models/rpc/rpc_response.dart";

part 'get_watch_only_status_response.g.dart';

@JsonSerializable()
class WatchOnlyStatus {
  final String status; // "failed" | "synced" | "scanning"
  final String stealth_address;
  final int? transactions_found;

  WatchOnlyStatus(
      {required this.status,
      required this.stealth_address,
      required this.transactions_found});

  factory WatchOnlyStatus.fromJson(Map<String, dynamic> json) =>
      _$WatchOnlyStatusFromJson(json);

  Map<String, dynamic> toJson() => _$WatchOnlyStatusToJson(this);
}

@JsonSerializable()
class GetWatchOnlyStatusResponse extends RpcResponse {
  final WatchOnlyStatus result;

  GetWatchOnlyStatusResponse(this.result,
      {required super.id, required super.error});

  factory GetWatchOnlyStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$GetWatchOnlyStatusResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetWatchOnlyStatusResponseToJson(this);
}
