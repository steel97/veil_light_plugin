// ignore_for_file: non_constant_identifier_names
import 'package:json_annotation/json_annotation.dart';
import 'package:veil_light_plugin/src/models/rpc/json_rpc_error.dart';
import 'package:veil_light_plugin/src/models/rpc/rpc_response.dart';

part 'get_watch_only_status_response.g.dart';

@JsonSerializable(includeIfNull: false)
class WatchOnlyStatus {
  String? status; // "failed" | "synced" | "scanning"
  String? stealth_address;
  int? transactions_found;

  WatchOnlyStatus({this.status, this.stealth_address, this.transactions_found});

  factory WatchOnlyStatus.fromJson(Map<String, dynamic> json) =>
      _$WatchOnlyStatusFromJson(json);

  Map<String, dynamic> toJson() => _$WatchOnlyStatusToJson(this);
}

@JsonSerializable(includeIfNull: false)
class GetWatchOnlyStatusResponse extends RpcResponse {
  WatchOnlyStatus? result;

  GetWatchOnlyStatusResponse(this.result, {super.id, super.error});

  factory GetWatchOnlyStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$GetWatchOnlyStatusResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetWatchOnlyStatusResponseToJson(this);
}
