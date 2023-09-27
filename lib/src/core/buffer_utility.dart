import 'dart:typed_data';
import 'package:veil_light_plugin/src/core/bitcoin_dart_fix.dart';
import 'package:veil_light_plugin/src/core/helpers.dart';

class BufferReader {
  final Uint8List buffer;
  int offset = 0;

  BufferReader(this.buffer);

  int readUInt8() {
    var value = buffer.buffer.asByteData().getUint8(offset);
    offset += 1;
    return value;
  }

  int readUInt32() {
    var value = buffer.buffer.asByteData().getUint32(offset, Endian.little);
    offset += 4;
    return value;
  }

  int readUInt64() {
    var value = buffer.buffer.asByteData().getUint64(offset, Endian.little);
    offset += 8;
    return value;
  }

  int readInt32() {
    var value = buffer.buffer.asByteData().getInt32(offset, Endian.little);
    offset += 4;
    return value;
  }

  Uint8List readSlice(int size) {
    var slice = buffer.sublist(offset, size);
    offset += size;
    return slice;
  }

  Uint8List readVarSlice() {
    var size = readVarInt();
    var res = buffer.sublist(offset, size);
    offset += size;
    return res;
  }

  int readVarInt() {
    ByteData bytes = buffer.buffer.asByteData();
    final first = bytes.getUint8(offset);
    offset++;

    // 8 bit
    if (first < 0xfd) {
      return first;
      // 16 bit
    } else if (first == 0xfd) {
      var res = bytes.getUint16(offset, Endian.little);
      offset += 2;
      return res;
      // 32 bit
    } else if (first == 0xfe) {
      var res = bytes.getUint32(offset, Endian.little);
      offset += 4;
      return res;
      // 64 bit
    } else {
      var lo = bytes.getUint32(offset, Endian.little);
      offset += 4;
      var hi = bytes.getUint32(offset, Endian.little);
      offset += 4;
      var number = hi * 0x0100000000 + lo;
      if (!isUint(number, 53)) throw ArgumentError("Expected UInt53");
      return number;
    }
  }
}

class BufferWriter {
  final List<int> buffer = List.empty();
  int offset = 0;

  void customVarInt(int data) {
    var res = putVarInt(data);
    buffer.setAll(offset, res);
    offset += res.lengthInBytes;
  }

  void writeVarInt(int data) {
    var res = putVarInt(data);
    buffer.setAll(offset, res);
    offset += res.lengthInBytes;
  }

  void writeVarSlice(Uint8List slice) {
    var res = putVarSlice(slice);
    buffer.setAll(offset, res);
    offset += res.lengthInBytes;
    buffer.setAll(offset, slice);
    offset += slice.lengthInBytes;
  }

  void writeSlice(Uint8List slice) {
    buffer.setAll(offset, slice);
    offset += slice.lengthInBytes;
  }

  void writeUInt8(int value) {
    var slice = Uint8List(4)..buffer.asByteData().setUint8(0, value);
    writeSlice(slice);
  }

  void writeUInt32(int value) {
    var slice = Uint8List(4)
      ..buffer.asByteData().setUint32(0, value, Endian.little);
    writeSlice(slice);
  }

  void writeUInt64(int value) {
    var slice = Uint8List(8)
      ..buffer.asByteData().setUint64(0, value, Endian.little);
    writeSlice(slice);
  }

  Uint8List getBuffer() {
    return Uint8List.fromList(buffer);
  }
}
