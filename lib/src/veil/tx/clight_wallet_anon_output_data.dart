import 'dart:typed_data';

import 'package:veil_light_plugin/src/core/buffer_utility.dart';
import 'package:veil_light_plugin/src/veil/tx/canon_output.dart';

class CLightWalletAnonOutputData {
  int? _index;
  CAnonOutput? _output;

  deserialize(Uint8List buffer) {
    var reader = BufferReader(buffer);
    _index = reader.readUInt64();
    _output = CAnonOutput();
    _output!.deserialize(buffer.sublist(8));
  }

  int? getIndex() {
    return _index;
  }

  CAnonOutput? getOutput() {
    return _output;
  }
}
