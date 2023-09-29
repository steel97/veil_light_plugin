// ignore_for_file: constant_identifier_names
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip39/src/wordlists/english.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:veil_light_plugin/src/models/publish_transaction_result.dart';
import 'package:veil_light_plugin/src/models/rpc/lightwallet/get_anon_outputs_response.dart';
import 'package:veil_light_plugin/src/models/rpc/rpc_request.dart';
import 'package:veil_light_plugin/src/models/rpc/wallet/send_raw_transaction_response.dart';
import 'package:veil_light_plugin/src/veil/chainparams.dart';
import 'package:veil_light_plugin/src/veil/lightwallet_transaction_builder.dart';
import 'package:veil_light_plugin/src/veil/rpc_requester.dart';
import 'package:veil_light_plugin/src/veil/tx/clight_wallet_anon_output_data.dart';

const BIP44_PURPOSE = 0x8000002C;

class Lightwallet {
  static Lightwallet fromMnemonic(
      Chainparams chainParams, List<String> mnemonic,
      {String password = ""}) {
    var mnemonicSeed =
        bip39.mnemonicToSeed(mnemonic.join(" "), passphrase: password);
    return Lightwallet(chainParams, mnemonicSeed);
  }

  static List<String> generateMnemonic({int size = 256}) {
    return bip39.generateMnemonic(strength: size).split(" ");
  }

  static bool verifyMnemonic(String mnemonic /*, List<String>? wordlist*/) {
    return bip39.validateMnemonic(mnemonic);
  }

  static bool verifyWord(String word) {
    return WORDLIST.contains(word);
  }

  final Chainparams chainParams;
  bip32.BIP32? _keyMaster;
  bip32.BIP32? _keyPurpose;
  bip32.BIP32? _keyCoin;

  Lightwallet(this.chainParams, Uint8List mnemonicSeed) {
    _keyMaster = bip32.BIP32.fromSeed(mnemonicSeed);
    _keyPurpose = _keyMaster!.derive(BIP44_PURPOSE);
    _keyCoin = _keyPurpose!.derive(chainParams.nBIP44ID);
  }

  Chainparams getChainParams() {
    return chainParams;
  }

  bip32.BIP32 getKeyCoin() {
    return _keyCoin!;
  }

  static Future<List<CLightWalletAnonOutputData>> getAnonOutputs(
      int vtxoutCount,
      {int ringSize = 5}) async {
    var responseRes = await RpcRequester.send(RpcRequest(
        jsonrpc: "1.0",
        method: "getanonoutputs",
        params: [vtxoutCount, ringSize] // inputSize, ringSize
        ));
    var response = GetAnonOutputsResponse.fromJson(responseRes);
    return LightwalletTransactionBuilder.AnonOutputsToObj(
        response.result ?? []);
  }

  static Future<PublishTransactionResult> publishTransaction(
      String rawTx) async {
    var responseRes = await RpcRequester.send(RpcRequest(
        jsonrpc: "1.0", method: "sendrawtransaction", params: [rawTx]));
    var response = SendRawTransactionResponse.fromJson(responseRes);

    if (response.error != null) {
      return PublishTransactionResult(
          errorCode: response.error?.code, message: response.error?.message);
    } else {
      return PublishTransactionResult(txid: response.result);
    }
  }
}
