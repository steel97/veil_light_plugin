import 'package:json_annotation/json_annotation.dart';
import 'package:veil_light_plugin/src/models/rpc/json_rpc_error.dart';
import 'package:veil_light_plugin/src/models/rpc/rpc_response.dart';

part 'get_raw_mempool.g.dart';

@JsonSerializable(includeIfNull: false)
class GetRawMempool extends RpcResponse {
  List<String>? result;

  GetRawMempool(this.result, {super.id, super.error});

  factory GetRawMempool.fromJson(Map<String, dynamic> json) =>
      _$GetRawMempoolFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetRawMempoolToJson(this);
}
