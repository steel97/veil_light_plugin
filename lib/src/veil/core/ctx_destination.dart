import "dart:typed_data";
import "package:veil_light_plugin/src/veil/core/output_types.dart";
import "package:veil_light_plugin/src/veil/cveil_stealth_address.dart";

class CTxDestination {
  Uint8List? scriptPubKey;
  CVeilStealthAddress? stealthAddress;
  OutputTypes type = OutputTypes.OUTPUT_CT;

  CTxDestination(Uint8List? scriptPubKey, CVeilStealthAddress? stealthAddress,
      OutputTypes type) {
    scriptPubKey = scriptPubKey;
    stealthAddress = stealthAddress;
    type = type;
  }
}
