import "package:json_annotation/json_annotation.dart";
import "package:veil_light_plugin/src/models/rpc/json_rpc_error.dart";
import "package:veil_light_plugin/src/models/rpc/rpc_response.dart";

part 'import_lightwallet_address_response.g.dart';

@JsonSerializable()
class ImportLightwalletStatus {
  final String result;
  final String stealth_address_bech;
  final String stealth_address_normal;
  final int imported_on;
  final int created_on;
  final bool watchonly;

  ImportLightwalletStatus(
      this.result,
      this.stealth_address_bech,
      this.stealth_address_normal,
      this.imported_on,
      this.created_on,
      this.watchonly);

  factory ImportLightwalletStatus.fromJson(Map<String, dynamic> json) =>
      _$ImportLightwalletStatusFromJson(json);

  Map<String, dynamic> toJson() => _$ImportLightwalletStatusToJson(this);
}

@JsonSerializable()
class ImportLightwalletAddressResponse extends RpcResponse {
  final ImportLightwalletStatus result;

  ImportLightwalletAddressResponse(this.result,
      {required super.id, required super.error});

  factory ImportLightwalletAddressResponse.fromJson(
          Map<String, dynamic> json) =>
      _$ImportLightwalletAddressResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$ImportLightwalletAddressResponseToJson(this);
}
