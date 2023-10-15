import 'dart:typed_data';
import 'package:veil_light_plugin/src/core/buffer_utility.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_out_ct.dart';
import 'package:veil_light_plugin/src/veil/core/output_types.dart';

class CTxOutRingCTOr extends CTxOutCT {
  Uint8List? pk;

  CTxOutRingCTOr() : super(OutputTypes.OUTPUT_RINGCT.value);

  @override
  serialize() {
    /*const preSize = 33 + 33;
    const writerBuf = Buffer.alloc(
        preSize + this.vData!.length + this.vRangeproof?.length! + 128);*/
    var writer = BufferWriter();
    writer.writeSlice(pk!);
    writer.writeSlice(commitment!);
    writer.writeVarSlice(vData!);
    writer.writeVarSlice(vRangeproof!);

    return writer.getBuffer(); //writer.buffer.subarray(0, writer.offset);
  }
}
