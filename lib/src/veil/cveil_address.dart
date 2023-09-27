// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:typed_data';

import 'package:flutter_bitcoin/flutter_bitcoin.dart';
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

  static CVeilAddress? parse(Chainparams chainParams, String address) {
    Uint8List? scriptPubKey;
    CVeilStealthAddress? stealthAddress;
    var valid = false;

    try {
      scriptPubKey =
          Address.addressToOutputScript(address, chainParams.veilNetwork);
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
        var data = bech32.decode(address, 128);
        if (data.hrp != chainParams.bech32Prefixes.STEALTH_ADDRESS) {
          throw Exception("Invalid address");
        }
        //const res = bech32.fromWords(data.words);
        //const buf = Buffer.from(res);
        stealthAddress = CVeilStealthAddress();
        stealthAddress.fromBuffer(Uint8List.fromList(data.data));
      }
    }

    var addrObj = CVeilAddress(scriptPubKey, stealthAddress, valid);
    return addrObj;
  }
}
