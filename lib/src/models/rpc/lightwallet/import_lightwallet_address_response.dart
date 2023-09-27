import "package:json_annotation/json_annotation.dart";
import "package:veil_light_plugin/src/models/rpc/json_rpc_error.dart";
import "package:veil_light_plugin/src/models/rpc/rpc_response.dart";

part 'import_lightwallet_address_response.g.dart';

@JsonSerializable(includeIfNull: false)
class ImportLightwalletStatus {
  String? result;
  String? stealth_address_bech;
  String? stealth_address_normal;
  int? imported_on;
  int? created_on;
  bool? watchonly;

  ImportLightwalletStatus(
      {this.result,
      this.stealth_address_bech,
      this.stealth_address_normal,
      this.imported_on,
      this.created_on,
      this.watchonly});

  factory ImportLightwalletStatus.fromJson(Map<String, dynamic> json) =>
      _$ImportLightwalletStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ImportLightwalletStatusToJson(this);
}

@JsonSerializable(includeIfNull: false)
class ImportLightwalletAddressResponse extends RpcResponse {
  ImportLightwalletStatus? result;

  ImportLightwalletAddressResponse(this.result, {super.id, super.error});

  factory ImportLightwalletAddressResponse.fromJson(
          Map<String, dynamic> json) =>
      _$ImportLightwalletAddressResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ImportLightwalletAddressResponseToJson(this);
}
