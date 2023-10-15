import 'dart:typed_data';
import 'package:veil_light_plugin/src/core/buffer_utility.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_out_base.dart';
import 'package:veil_light_plugin/src/veil/core/output_types.dart';

class CTxOutCT extends CTxOutBase {
  Uint8List? commitment;
  Uint8List? vData;
  Uint8List? scriptPubKey;
  Uint8List? vRangeproof;

  CTxOutCT(int? nVersion)
      : super(nVersion: nVersion ?? OutputTypes.OUTPUT_CT.value);

  @override
  Uint8List serialize() {
    //var preSize = 33 + vData!.lengthInBytes + scriptPubKey!.lengthInBytes;
    //const writerBuf = Buffer.alloc(preSize + this.vRangeproof?.length! + 10);

    var writer = BufferWriter();
    writer.writeSlice(commitment!);
    writer.writeSlice(vData!);
    writer.writeSlice(scriptPubKey!);
    writer.writeVarSlice(vRangeproof!);

    return writer.getBuffer(); // writer.buffer.subarray(0, writer.offset);
  }
}
