// ignore_for_file: non_constant_identifier_names

import "dart:typed_data";

import "package:veil_light_plugin/src/core/buffer_utility.dart";
import "package:veil_light_plugin/src/core/dart_ref.dart";
import "package:veil_light_plugin/src/veil/core/cscript_witness.dart";
import "package:veil_light_plugin/src/veil/tx/cout_point.dart";

class CTxIn {
  static int SEQUENCE_FINAL = 0xffffffff; // uint32_t
  static int SEQUENCE_LOCKTIME_DISABLE_FLAG = (1 << 31); // uint32_t
  static int SEQUENCE_LOCKTIME_TYPE_FLAG = (1 << 22); // uint32_t
  static int SEQUENCE_LOCKTIME_MASK = 0x0000ffff; // uint32_t
  static int SEQUENCE_LOCKTIME_GRANULARITY = 9; // int

  int nSequence = 0;
  COutPoint prevout = COutPoint();

  CScriptWitness scriptData = CScriptWitness();
  CScriptWitness scriptWitness = CScriptWitness();

  CTxIn() {
    nSequence = CTxIn.SEQUENCE_FINAL;
  }

  setAnonInfo(int nInputs, int nRingSize) //uint32_t
  {
    prevout.hash = Uint8List(32); //uint256
    var writer = BufferWriter();
    writer.writeUInt32(nInputs);
    writer.writeUInt32(nRingSize);
    prevout.hash!.setAll(0, writer.getBuffer());
    //memcpy(prevout.hash.begin(), &nInputs, 4);
    //memcpy(prevout.hash.begin()+4, &nRingSize, 4);
    return true;
  }

  getAnonInfo(NumPass nInputs, NumPass nRingSize) {
    var reader = BufferReader(prevout.hash!);
    nInputs.num = reader.readUInt32();
    nRingSize.num = reader.readUInt32();

    return true;
  }

  bool isAnonInput() {
    return prevout.isAnonInput();
  }

  Uint8List serialize() {
    //const buf = Buffer.alloc(4096);
    var writer = BufferWriter();
    writer.writeSlice(prevout.serialize());
    //scriptSig empty
    writer.writeUInt8(0);
    writer.writeUInt32(nSequence);
    if (isAnonInput()) {
      //scriptData.stack
      writer.writeSlice(scriptData.serialize());
    }
    return writer.getBuffer();
  }
}
