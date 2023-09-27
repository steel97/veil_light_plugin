import 'dart:typed_data';

Uint8List putVarInt(int i) {
  //uint64_t
  var u8a = Uint8List(9);
  int nBytes = 0; // int
  int b = i & 0x7F; // byte
  int ptr = 0;
  while ((i = i >> 7) > 0) {
    u8a[ptr++] = b | 0x80;
    //*p++ = b | 0x80;
    b = i & 0x7F;
    nBytes++;
  }
  u8a[ptr++] = b;
  nBytes++;
  var buf = Uint8List(nBytes);
  buf.setAll(0, u8a.sublist(0, nBytes));
  return buf;
}

Uint8List putVarSlice(Uint8List slice) {
  var sliceLen = putVarInt(slice.lengthInBytes);
  var res = Uint8List(slice.lengthInBytes + sliceLen.lengthInBytes);
  res.setAll(0, sliceLen);
  res.setAll(sliceLen.lengthInBytes, slice);
  return res;
}
