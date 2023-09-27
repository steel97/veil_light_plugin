import "dart:typed_data";
import "package:veil_light_plugin/src/core/buffer_utility.dart";

class CScriptWitness {
  // Note that this encodes the data elements being pushed, rather than
  // encoding them as a CScript that pushes them.
  List<Uint8List> stack = [];

  bool isNull() {
    return stack.isEmpty;
  }
  //public setNull() { stack.clear(); stack.shrink_to_fit(); }

  Uint8List serialize() {
    //var tmpBuf = Uint8List(8096 * 2);// Buffer.alloc(8096 * 2);
    var writer = BufferWriter();
    writer.writeVarInt(stack.length);
    for (var element in stack) {
      writer.writeVarSlice(element);
    }
    /*
        var size = 0UL;
    var tempSize = 0UL;
    serializationContext.ReadCompactSize(out size);

    Stack = new List<byte[]>();

    for (var i = 0UL; i < size; i++)
    {
        serializationContext.ReadCompactSize(out tempSize);
        var stackEntry = serializationContext.ReadByteArray(tempSize);
        Stack.Add(stackEntry);
    }
        */
    return writer.getBuffer();
  }
}
