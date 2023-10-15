import 'dart:typed_data';
import 'package:veil_light_plugin/src/core/buffer_utility.dart';
import 'package:veil_light_plugin/src/veil/tx/cout_point.dart';

class CAnonOutput {
  Uint8List? _pubkey;
  Uint8List? _commitment;
  COutPoint? _outpoint;
  int? _nBlockHeight;
  int? _nCompromised;

  deserialize(Uint8List buffer) {
    var reader = BufferReader(buffer);
    _pubkey = reader.readVarSlice();
    _commitment = reader.readSlice(33);
    _outpoint = COutPoint();
    var read = _outpoint!.deserialize(buffer.sublist(reader.offset));

    var reader2 = BufferReader(buffer.sublist(reader.offset + read));
    _nBlockHeight = reader2.readInt32();
    _nCompromised = reader2.readUInt8();
  }

  int? getBlockHeight() {
    return _nBlockHeight;
  }

  int? getCompromised() {
    return _nCompromised;
  }

  Uint8List? getCommitment() {
    return _commitment;
  }

  Uint8List? getPubKey() {
    return _pubkey;
  }
}
