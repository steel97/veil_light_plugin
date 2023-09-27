// ignore_for_file: non_constant_identifier_names
import 'dart:typed_data';
import 'package:veil_light_plugin/src/core/buffer_utility.dart';

class COutPoint {
  static int ANON_MARKER = 0xffffffa0; // uint32_t

  Uint8List? hash;
  int? n;

  int deserialize(Uint8List buffer) {
    var reader = BufferReader(buffer);
    hash = reader.readSlice(32);
    n = reader.readUInt32();

    return reader.offset;
  }

  Uint8List serialize() {
    //const tmpBuf = Buffer.alloc(32 + 4);
    var writer = BufferWriter();
    writer.writeSlice(hash!);
    writer.writeUInt32(n!);
    return writer.getBuffer(); //writer.buffer.subarray(0, writer.offset);
  }

  bool isAnonInput() {
    return n == COutPoint.ANON_MARKER;
  }
}
