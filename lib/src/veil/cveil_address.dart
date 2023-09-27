// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:typed_data';

import 'package:flutter_bitcoin/flutter_bitcoin.dart';
import 'package:flutter_bitcoin/src/utils/script.dart' as bscript;
import 'package:flutter_bitcoin/src/utils/constants/op.dart';
import 'package:veil_light_plugin/src/core/bitcoin_dart_fix.dart';
import 'package:veil_light_plugin/src/veil/chainparams.dart';
import 'package:veil_light_plugin/src/veil/cveil_stealth_address.dart';
import 'package:bech32/bech32.dart';
import 'package:bs58check/bs58check.dart' as bs58check;

class CVeilAddress {
  final bool _isValid;
  final Uint8List? _scriptPubKey;
  final CVeilStealthAddress? _stealthAddress;

  CVeilAddress(this._scriptPubKey, this._stealthAddress, this._isValid);

  Uint8List? getScriptPubKey() {
    return _scriptPubKey;
  }

  CVeilStealthAddress? getStealthAddress() {
    return _stealthAddress;
  }

  bool isValid() {
    return _isValid;
  }

  bool isValidStealthAddress() {
    if (_stealthAddress == null) return false;
    return _stealthAddress?.isValid ?? false;
  }

  static Uint8List addressToOutputScript(String address, [NetworkType? nw]) {
    NetworkType network = nw ?? bitcoin;
    Uint8List? decodeBase58;
    Segwit? decodeBech32;
    try {
      decodeBase58 = bs58check.decode(address);
    } catch (err) {}
    if (decodeBase58 != null) {
      if (decodeBase58[0] != network.pubKeyHash) {
        throw ArgumentError('Invalid version or Network mismatch');
      }
      P2PKH p2pkh =
          P2PKH(data: PaymentData(address: address), network: network);
      return p2pkh.data.output!;
    } else {
      try {
        //decodeBech32 = segwit.decode(address);
        decodeBech32 = getSegWitFromAddress(nw!.bech32 ?? "bv", address);
      } catch (err) {}
      if (decodeBech32 != null) {
        if (network.bech32 != decodeBech32.hrp) {
          throw ArgumentError('Invalid prefix or Network mismatch');
        }
        if (decodeBech32.version != 0) {
          throw ArgumentError('Invalid address version');
        }
        //P2WPKH p2wpkh =
        //    P2WPKH(data: PaymentData(address: address), network: network);
        var hash = Uint8List.fromList(decodeBech32.program);
        var output = bscript.compile([OPS['OP_0'], hash]);
        return output;
      }
    }
    throw ArgumentError('$address has no matching Script');
  }

  static CVeilAddress? parse(Chainparams chainParams, String address) {
    Uint8List? scriptPubKey;
    CVeilStealthAddress? stealthAddress;
    var valid = false;

    try {
      scriptPubKey =
          CVeilAddress.addressToOutputScript(address, chainParams.veilNetwork);
      valid = true;
    } catch (e) {
      try {
        var b58d = bs58check.decode(address);
        //const b58d = fromBase58Check(address);
        /*const addrHash = b58d.hash
            .subarray(1); // size of array base58Prefixes.STEALTH_ADDRESS*/
        var addrHash = b58d.sublist(1);
        stealthAddress = CVeilStealthAddress();
        stealthAddress.fromBuffer(addrHash);
      } catch (e1) {
        // stealth bech32
        /*const bechRes = fromBech32(address);
                if (bechRes.prefix != bech32Prefixes.STEALTH_ADDRESS) {
                    throw new Error("Invalid address");
                }*/
        /*var data = getSegWitFromAddress(
            chainParams.bech32Prefixes.STEALTH_ADDRESS, address,
            maxLen: 128, useValidations: false);*/ // bech32.decode(address, 128);
        var data = bech32.decode(address, 128);
        if (data.hrp != chainParams.bech32Prefixes.STEALTH_ADDRESS) {
          throw Exception("Invalid address");
        }
        var res = convertBits(data.data, 5, 8, false);

        //const res = bech32.fromWords(data.words);
        //const buf = Buffer.from(res);
        stealthAddress = CVeilStealthAddress();
        stealthAddress.fromBuffer(Uint8List.fromList(res));
      }
    }

    var addrObj = CVeilAddress(scriptPubKey, stealthAddress, valid);
    return addrObj;
  }
}
