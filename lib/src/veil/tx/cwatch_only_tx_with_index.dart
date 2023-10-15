import 'dart:typed_data';
import 'package:veil_light_plugin/src/core/buffer_utility.dart';
import 'package:veil_light_plugin/src/veil/tx/cwatch_only_tx.dart';

class CWatchOnlyTxWithIndex extends CWatchOnlyTx {
  int? _ringctIndex;
  String raw = '';

  CWatchOnlyTxWithIndex() : super();

  @override
  void deserialize(Uint8List buffer, String? raw) {
    this.raw = raw ?? '';
    var reader = BufferReader(buffer);
    _ringctIndex = reader.readUInt64();
    super.deserialize(buffer.sublist(8), null);
  }

  int? getRingCtIndex() {
    return _ringctIndex;
  }
}
