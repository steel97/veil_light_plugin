import "dart:typed_data";

import "package:veil_light_plugin/src/core/buffer_utility.dart";
import "package:veil_light_plugin/src/veil/core/ctx_out_base.dart";
import "package:veil_light_plugin/src/veil/core/output_types.dart";

class CTxOutStandard extends CTxOutBase {
  final int nValue; //int64
  final Uint8List scriptPubKey; //CScript

  CTxOutStandard(this.nValue, this.scriptPubKey)
      : super(nVersion: OutputTypes.OUTPUT_STANDARD.value);

  @override
  Uint8List serialize() {
    //const buf = Buffer.alloc(this.scriptPubKey?.length! + 512);
    var writer = BufferWriter();
    writer.writeUInt64(nValue);
    writer.writeVarInt(scriptPubKey.length);
    writer.writeSlice(scriptPubKey);
    return writer.getBuffer();
  }
}
