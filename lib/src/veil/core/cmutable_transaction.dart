import "dart:typed_data";
import "package:convert/convert.dart";
import "package:pointycastle/digests/sha256.dart";
import "package:veil_light_plugin/src/core/crypto.dart";
import "package:veil_light_plugin/src/core/buffer_utility.dart";
import "package:veil_light_plugin/src/veil/core/ctx_in.dart";
import "package:veil_light_plugin/src/veil/core/ctx_out_base.dart";
import "package:veil_light_plugin/src/veil/serialization.dart";

class CMutableTransaction {
  List<CTxIn> vin = [];
  List<CTxOutBase> vpout = []; // std::vector<CTxOutBaseRef> vpout;
  int nVersion = 2; //int32_t
  int nLockTime = 0; //uint32_t

  Uint8List serializeHash(CTxOutBase out, int hashType) {
    var buf = out.serialize();
    //const tbuf = Buffer.alloc(4 + buf.length);
    var writer = BufferWriter();
    //writer.writeUInt32(hashType);

    writer.writeSlice(buf);
    var rbuf = writer.getBuffer().sublist(0, writer.offset);

    return hash256(rbuf);
  }

  getOutputsHash() {
    // uint256 return
    var pblank = Uint8List.fromList(hex.decode(
        "0000000000000000000000000000000000000000000000000000000000000000"));
    var hashOutputs = Uint8List(32);
    var hashOutputsSet = false;
    //static const unsigned char pblank[1] = {};
    var hasher = SHA256Digest();
    for (var out in vpout) {
      var hash = serializeHash(out, SerializationType.SER_GETHASH.value);

      hasher.reset();

      var hsh1 = hash.lengthInBytes == 0 ? pblank : hash;
      var hsh2 = !hashOutputsSet ? pblank : hashOutputs;
      hasher.update(hsh1, 0, hsh1.lengthInBytes);
      hasher.update(hsh2, 0, hsh2.lengthInBytes);
      // call update on all data came from serialization
      var temp = Uint8List(32);
      hasher.doFinal(temp, 0);

      hasher.reset();
      hasher.update(temp, 0, temp.lengthInBytes);
      //hashOutputs = Buffer.from(hasher.digest());
      hasher.doFinal(hashOutputs, 0);
      hashOutputsSet = true;
      //hashOutputs = Hash(BEGIN(hash), END(hash), hashOutputs.begin(), hashOutputs.end());
    }

    return hashOutputs;
  }

  bool hasWitness() {
    for (int i = 0; i < vin.length; i++) {
      if (!vin[i].scriptWitness.isNull()) {
        return true;
      }
    }
    return false;
  }

  Uint8List encode() {
    //const buf = Buffer.alloc(81920);
    var writer = BufferWriter();
    writer.writeUInt8(nVersion & 0xFF);
    //type
    var bv = (nVersion >> 8) & 0xFF;
    writer.writeUInt8(bv);
    writer.writeUInt8(hasWitness() ? 1 : 0);
    writer.writeUInt32(nLockTime);

    writer.writeVarInt(vin.length);
    for (var txin in vin) {
      var buf = txin.serialize();
      writer.writeSlice(buf);
    }

    writer.writeVarInt(vpout.length);
    for (var k = 0; k < vpout.length; ++k) {
      writer.writeUInt8(vpout[k].nVersion);
      writer.writeSlice(vpout[k].serialize());
    }

    if (hasWitness()) {
      for (var txin in vin) {
        writer.writeSlice(txin.scriptWitness.serialize());
      }
    }
    /*
    if (tx.HasWitness()) {
        for (auto &txin : tx.vin)
            s << txin.scriptWitness.stack;
    }
        */
    return writer.getBuffer();
  }
}

/**
 * Basic transaction serialization format:
 * - int32_t nVersion
 * - std::vector<CTxIn> vin
 * - std::vector<CTxOut> vout
 * - uint32_t nLockTime
 *
 * Extended transaction serialization format:
 * - int32_t nVersion
 * - unsigned char dummy = 0x00
 * - unsigned char flags (!= 0)
 * - bool Tx Has Segwit
 * - std::vector<CTxIn> vin
 * - std::vector<CTxOut> vout
 * - if (flags & 1):
 *   - CTxWitness wit;
 * - uint32_t nLockTime
 */