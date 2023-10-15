import 'dart:typed_data';
import 'package:flutter_bitcoin/flutter_bitcoin.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:veil_light_plugin/native/plugin.dart' as ecc;

// ignore: constant_identifier_names
const _EC_COMPRESSED_SIZE = 33;

class StealthSecretResult {
  final Uint8List sShared;
  final Uint8List pkExtracted;

  StealthSecretResult(this.sShared, this.pkExtracted);
}

class Stealth {
  static Uint8List setPublicKey(Uint8List pk) {
    var buf = Uint8List(_EC_COMPRESSED_SIZE);
    buf.setAll(0, pk);
    return buf;
  }

  static stealthSecret(Uint8List secret, Uint8List pubkey, Uint8List pkSpend) {
    Uint8List? sShared;
    Uint8List? pkExtracted;

    if (pubkey.length != _EC_COMPRESSED_SIZE ||
        pkSpend.length != _EC_COMPRESSED_SIZE) {
      throw Exception('sanity checks failed');
    }

    var Q = pubkey;
    var R = pkSpend;

    Q = ecc.pointMultiply(Q, secret, compressed: true)!;
    var tmp33 =
        Q; // secp256k1_ec_pubkey_serialize(secp256k1_ctx_stealth, tmp33, &len, &Q, SECP256K1_EC_COMPRESSED); // Returns: 1 always.

    var vKey = SHA256Digest().process(tmp33);

    //sShared = Buffer.from(vKey); //valid, compressed
    sShared = Uint8List(32);
    sShared.setAll(0, vKey);
    //if (!secp256k1_ec_seckey_verify(secp256k1_ctx_stealth, sharedSOut.begin()))
    //    return errorN(1, "%s: secp256k1_ec_seckey_verify failed.", __func__); // Start again with a new ephemeral key

    R = ecc.pointAddScalar(R, sShared, compressed: true)!;

    pkExtracted = Stealth.setPublicKey(R);

    var res = StealthSecretResult(sShared, pkExtracted);
    return res;
  }

  static stealthSharedToSecretSpend(Uint8List sharedS, Uint8List spendSecret) {
    //ckey, ckey, ckey
    var secretOut = spendSecret;

    secretOut = ecc.privateAdd(secretOut, sharedS)!;
    //secp256k1_ec_seckey_verify
    return secretOut;
  }

  static getPubKey(Uint8List input) {
    var keyPair = ECPair.fromPrivateKey(input);
    return keyPair.publicKey;
  }
}
