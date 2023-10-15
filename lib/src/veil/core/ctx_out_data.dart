import 'dart:typed_data';
import 'package:veil_light_plugin/src/core/buffer_utility.dart';
import 'package:veil_light_plugin/src/veil/core/ctx_out_base.dart';
import 'package:veil_light_plugin/src/veil/core/output_types.dart';

class CTxOutData extends CTxOutBase {
  Uint8List vData;

  CTxOutData(this.vData) : super(nVersion: OutputTypes.OUTPUT_DATA.value);

  @override
  serialize() {
    var writer = BufferWriter();
    writer.writeVarSlice(vData);
    return writer.getBuffer(); //writer.buffer.subarray(0, writer.offset);
  }
}
