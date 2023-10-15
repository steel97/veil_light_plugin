import 'package:json_annotation/json_annotation.dart';
import 'package:veil_light_plugin/src/models/rpc/json_rpc_error.dart';
import 'package:veil_light_plugin/src/models/rpc/rpc_response.dart';

part 'check_key_images_response.g.dart';

@JsonSerializable(includeIfNull: false)
class KeyImageResult {
  String? status;
  String? msg;
  bool? spent;
  bool? spentinmempool;
  String? txid;

  KeyImageResult(
      {this.status, this.msg, this.spent, this.spentinmempool, this.txid});

  factory KeyImageResult.fromJson(Map<String, dynamic> json) =>
      _$KeyImageResultFromJson(json);

  Map<String, dynamic> toJson() => _$KeyImageResultToJson(this);
}

@JsonSerializable(includeIfNull: false)
class CheckKeyImagesResponse extends RpcResponse {
  List<KeyImageResult>? result;

  CheckKeyImagesResponse(this.result, {super.id, super.error});

  factory CheckKeyImagesResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckKeyImagesResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CheckKeyImagesResponseToJson(this);
}
