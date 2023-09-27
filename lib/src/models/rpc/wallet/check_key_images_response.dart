import 'package:json_annotation/json_annotation.dart';
import "package:veil_light_plugin/src/models/rpc/json_rpc_error.dart";
import 'package:veil_light_plugin/src/models/rpc/rpc_response.dart';

part 'check_key_images_response.g.dart';

@JsonSerializable()
class KeyImageResult {
  final String status;
  final String msg;
  final bool spent;
  final bool spentinmempool;
  String? txid;

  KeyImageResult(
      {required this.status,
      required this.msg,
      required this.spent,
      required this.spentinmempool,
      required this.txid});

  factory KeyImageResult.fromJson(Map<String, dynamic> json) =>
      _$KeyImageResultFromJson(json);

  Map<String, dynamic> toJson() => _$KeyImageResultToJson(this);
}

@JsonSerializable()
class CheckKeyImagesResponse extends RpcResponse {
  List<KeyImageResult> result;

  CheckKeyImagesResponse(this.result,
      {required super.id, required super.error});

  factory CheckKeyImagesResponse.fromJson(Map<String, dynamic> json) =>
      _$CheckKeyImagesResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CheckKeyImagesResponseToJson(this);
}
