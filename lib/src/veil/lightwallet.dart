// ignore_for_file: constant_identifier_names
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip39/src/wordlists/english.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:reaxdb_dart/reaxdb_dart.dart';
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
  static Future<Lightwallet> fromMnemonic(
    Chainparams chainParams,
    List<String> mnemonic, {
    String password = '',
    String? storageName,
    String? encryptionKey,
    String? storagePath,
  }) async {
    var mnemonicSeed =
        bip39.mnemonicToSeed(mnemonic.join(' '), passphrase: password);

    return Lightwallet(chainParams, mnemonicSeed,
        storageName: storageName,
        encryptionKey: encryptionKey,
        storagePath: storagePath);
  }

  static List<String> generateMnemonic({int size = 256}) {
    return bip39.generateMnemonic(strength: size).split(' ');
  }

  static bool verifyMnemonic(String mnemonic /*, List<String>? wordlist*/) {
    return bip39.validateMnemonic(mnemonic);
  }

  static bool verifyWord(String word) {
    return WORDLIST.contains(word);
  }

  static List<String> getValidWords() {
    return WORDLIST;
  }

  final Chainparams chainParams;
  bip32.BIP32? _keyMaster;
  bip32.BIP32? _keyPurpose;
  bip32.BIP32? _keyCoin;
  String? _storageName;
  String? _encryptionKey;
  String? _storagePath;

  Lightwallet(
    this.chainParams,
    Uint8List mnemonicSeed, {
    String? storageName,
    String? encryptionKey,
    String? storagePath,
  }) {
    _keyMaster = bip32.BIP32.fromSeed(mnemonicSeed);
    _keyPurpose = _keyMaster!.derive(BIP44_PURPOSE);
    _keyCoin = _keyPurpose!.derive(chainParams.nBIP44ID);
    _storageName = storageName;
    _encryptionKey = encryptionKey;
    _storagePath = storagePath;
  }

  Chainparams getChainParams() {
    return chainParams;
  }

  bip32.BIP32 getKeyCoin() {
    return _keyCoin!;
  }

  Future<SimpleReaxDB?> getDb() async {
    SimpleReaxDB? db;
    var sname = _storageName;
    if (sname != null) {
      /*var dbConfig = DatabaseConfig(
        memtableSizeMB: 4, // Reduced from 16 for mobile
        pageSize: 4096,
        l1CacheSize: 500, // Reduced cache sizes
        l2CacheSize: 1000,
        l3CacheSize: 2000,
        compressionEnabled: true,
        syncWrites: false, // Async for better performance
        maxImmutableMemtables: 4,
        cacheSize: 50,
        enableCache: true,
        encryptionType: _encryptionKey != null
            ? EncryptionType.aes256
            : EncryptionType.none,
      );*/
      db = await SimpleReaxDB.open(sname,
          encrypted: _encryptionKey != null, path: _storagePath);
    }

    return db;
  }

  static Future<List<CLightWalletAnonOutputData>> getAnonOutputs(
      int vtxoutCount,
      {int ringSize = 5}) async {
    var responseRes = await RpcRequester.send(RpcRequest(
        jsonrpc: '1.0',
        method: 'getanonoutputs',
        params: [vtxoutCount, ringSize] // inputSize, ringSize
        ));
    var response = GetAnonOutputsResponse.fromJson(responseRes);
    return LightwalletTransactionBuilder.AnonOutputsToObj(
        response.result ?? []);
  }

  static Future<PublishTransactionResult> publishTransaction(
      String rawTx) async {
    var responseRes = await RpcRequester.send(RpcRequest(
        jsonrpc: '1.0', method: 'sendrawtransaction', params: [rawTx]));
    var response = SendRawTransactionResponse.fromJson(responseRes);

    if (response.error != null) {
      return PublishTransactionResult(
          errorCode: response.error?.code, message: response.error?.message);
    } else {
      return PublishTransactionResult(txid: response.result);
    }
  }
}
