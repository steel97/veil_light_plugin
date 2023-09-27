// ignore_for_file: constant_identifier_names
import "dart:typed_data";
import "package:convert/convert.dart";
import "package:veil_light_plugin/src/core/buffer_utility.dart";
import "package:veil_light_plugin/src/veil/chainparams.dart";
import "package:veil_light_plugin/src/veil/tx/ctx_out_ring_ct.dart";

enum WatchOnlyTxType {
  NOTSET(-1),
  STEALTH(0),
  ANON(1);

  const WatchOnlyTxType(this.value);
  final int value;
}

class CWatchOnlyTx {
  WatchOnlyTxType? _type;
  Uint8List? _scanSecret;
  Uint8List? _txHash;
  String? _txHashHex;
  int? _txIndex;
  CTxOutRingCT? _ringctout;
  //private _ctout: CTxOutCT;

  void deserialize(Uint8List buffer, String? voids) {
    var reader = BufferReader(buffer);
    _type = WatchOnlyTxType.NOTSET;
    switch (reader.readInt32()) {
      case 0:
        _type = WatchOnlyTxType.STEALTH;
        break;
      case 1:
        _type = WatchOnlyTxType.ANON;
        break;
    }

    _scanSecret = reader.readSlice(32);
    var scanSecretValid = (reader.readUInt8()) > 0;
    var scanSecretCompressed = (reader.readUInt8()) > 0;

    _txHash = reader.readSlice(32);
    _txIndex = reader.readUInt32();

    if (_type == WatchOnlyTxType.ANON) {
      var ctxOut = CTxOutRingCT();
      ctxOut.deserialize(buffer.sublist(reader.offset));
      _ringctout = ctxOut;
    }
  }

  WatchOnlyTxType? getType() {
    return _type;
  }

  Uint8List? getKeyImage() {
    // return ct or ringct
    if (_ringctout == null) {
      return null;
    }

    return _ringctout!.getKeyImage();
  }

  double getAmount(Chainparams chainParams) {
    // return ct or ringct
    if (_ringctout == null) {
      return 0;
    }

    return ((_ringctout!.getAmount() ?? BigInt.from(0)) as int) /
        (chainParams.COIN as int);
  }

  CTxOutRingCT? getRingCtOut() {
    return _ringctout;
  }

  String? getId() {
    _txHashHex ??= hex.encode(_txHash!.reversed.toList());

    return _txHashHex;
  }

  Uint8List? getTxHash() {
    return _txHash;
  }
}
