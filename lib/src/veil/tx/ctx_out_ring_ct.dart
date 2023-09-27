// ignore_for_file: depend_on_referenced_packages

import "dart:typed_data";

import "package:pointycastle/digests/sha256.dart";
import "package:veil_light_plugin/src/core/buffer_utility.dart";
import 'package:bip32/bip32.dart' as bip32;
import "package:veil_light_plugin/src/veil/stealth.dart";
import 'package:veil_light_plugin/native/plugin.dart' as ecc;

class CTxOutRingCT {
  Uint8List? _pubKey;
  Uint8List? _commitment;
  Uint8List? _vData;
  Uint8List? _vRangeproof;
  Uint8List? _vchEphemPK;

  Uint8List? _keyImage;
  BigInt? _nAmount;
  Uint8List? _blind;

  void deserialize(Uint8List buffer) {
    var reader = BufferReader(buffer);
    _pubKey = reader.readSlice(33);
    _commitment = reader.readSlice(33);
    _vData = reader.readVarSlice();
    _vRangeproof = reader.readVarSlice();
    _vchEphemPK = _vData?.sublist(0, 33);
  }

  void decodeTx(bip32.BIP32 spendKey, bip32.BIP32 scanKey) {
    var ecPubKey = Stealth.setPublicKey(spendKey.publicKey);
    var stealthSecretRes =
        Stealth.stealthSecret(scanKey.privateKey!, _vchEphemPK!, ecPubKey);

    var sShared = stealthSecretRes.sShared;
    //const pkExtracted = stealthSecretRes.pkExtracted;

    var destinationKeyPriv =
        Stealth.stealthSharedToSecretSpend(sShared, spendKey.privateKey!);
    //const destinationKey = Stealth.getPubKey(destinationKeyPriv);

    //const destIdent = hash160(destinationKey);
    //const pkIdent = hash160(this._pubKey!);

    _keyImage = ecc.getKeyImage(_pubKey!, destinationKeyPriv);
    var nonce = ecc.ECDH_VEIL(_vchEphemPK!, destinationKeyPriv);

    var hasher = SHA256Digest();
    hasher.update(nonce!, 0, 32);
    var nonceHashed = Uint8List(32);
    hasher.doFinal(nonceHashed, 32);

    var amountres =
        ecc.rangeProofRewind(nonceHashed, _commitment!, _vRangeproof!);
    _nAmount = amountres?.value;
    _blind = amountres?.blindOut;
  }

  Uint8List? getPubKey() {
    return _pubKey;
  }

  Uint8List? getKeyImage() {
    return _keyImage;
  }

  BigInt? getAmount() {
    return _nAmount;
  }

  Uint8List? getVCHEphemPK() {
    return _vchEphemPK;
  }

  Uint8List? getVData() {
    return _vData;
  }

  Uint8List? getCommitment() {
    return _commitment;
  }

  Uint8List? getBlind() {
    return _blind;
  }
}
