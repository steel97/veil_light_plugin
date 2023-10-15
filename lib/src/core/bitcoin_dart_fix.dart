import 'dart:typed_data';
import 'package:bech32/bech32.dart';

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

Segwit getSegWitFromAddress(String expectedPrefix, String input,
    {int maxLen = 90, bool useValidations = true}) {
  SegwitValidations val = SegwitValidations();
  var decoded = bech32.decode(input, maxLen);

  if (decoded.hrp != expectedPrefix) {
    throw InvalidHrp();
  }

  if (val.isEmptyProgram(decoded.data)) {
    throw InvalidProgramLength('empty');
  }

  var version = decoded.data[0];

  if (val.isInvalidVersion(version)) {
    throw InvalidWitnessVersion(version);
  }

  var program = convertBits(decoded.data.sublist(1), 5, 8, false);

  if (useValidations) {
    if (val.isTooShortProgram(program)) {
      throw InvalidProgramLength('too short');
    }

    if (val.isTooLongProgram(program)) {
      throw InvalidProgramLength('too long');
    }

    if (val.isWrongVersion0Program(version, program)) {
      throw InvalidProgramLength(
          'version $version invalid with length ${program.length}');
    }
  }

  return Segwit(decoded.hrp, version, program);
}

List<int> convertBits(List<int> data, int from, int to, bool pad) {
  var acc = 0;
  var bits = 0;
  var result = <int>[];
  var maxv = (1 << to) - 1;

  for (var v in data) {
    if (v < 0 || (v >> from) != 0) {
      throw Exception();
    }
    acc = (acc << from) | v;
    bits += from;
    while (bits >= to) {
      bits -= to;
      result.add((acc >> bits) & maxv);
    }
  }

  if (pad) {
    if (bits > 0) {
      result.add((acc << (to - bits)) & maxv);
    }
  } else if (bits >= from) {
    throw InvalidPadding('illegal zero padding');
  } else if (((acc << (to - bits)) & maxv) != 0) {
    throw InvalidPadding('non zero');
  }

  return result;
}
