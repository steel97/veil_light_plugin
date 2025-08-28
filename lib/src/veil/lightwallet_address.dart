// ignore_for_file: unused_import

import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:reaxdb_dart/reaxdb_dart.dart';
import 'package:veil_light_plugin/src/core/crypto.dart';
import 'package:veil_light_plugin/src/models/build_transaction_result.dart';
import 'package:veil_light_plugin/src/models/rpc/lightwallet/get_watch_only_status_response.dart';
import 'package:veil_light_plugin/src/models/rpc/lightwallet/get_watch_only_txes_response.dart';
import 'package:veil_light_plugin/src/models/rpc/lightwallet/import_lightwallet_address_response.dart';
import 'package:veil_light_plugin/src/models/rpc/rpc_request.dart';
import 'package:veil_light_plugin/src/models/rpc/wallet/check_key_images_response.dart';
import 'package:veil_light_plugin/src/veil/cveil_recipient.dart';
import 'package:veil_light_plugin/src/veil/cveil_stealth_address.dart';
import 'package:veil_light_plugin/src/veil/lightwallet.dart';
import 'package:veil_light_plugin/src/veil/lightwallet_account.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:veil_light_plugin/src/veil/lightwallet_transaction_builder.dart';
import 'package:veil_light_plugin/src/veil/rpc_requester.dart';
import 'package:veil_light_plugin/src/veil/stealth.dart';
import 'package:veil_light_plugin/src/veil/tx/cwatch_only_tx_with_index.dart';

const int lightWalletApiMaxTxs = 1000;

class LightwalletAddress {
  final LightwalletAccount _lwAccount;
  bip32.BIP32? _addressKey;
  AccountType _accountType = AccountType.DEFAULT;
  CVeilStealthAddress? _stealth;
  final int _index;
  List<CWatchOnlyTxWithIndex>? _transactionsCache;
  List<KeyImageResult>? _keyImageCache;
  bool _syncWithNodeCalled = false;
  String _syncStatus =
      'unknown'; // TO-DO "failed" | "synced" | "scanning" = "scanning";
  bool _txesSynced = false;

  AccountType getAccountType() => _accountType;

  LightwalletAddress(this._lwAccount, bip32.BIP32 account,
      AccountType accountType, this._index) {
    _addressKey = account.deriveHardened(_index);
    _accountType = accountType;
    _stealth = CVeilStealthAddress();
    _stealth!.fromData(
        getScanKey()!.privateKey!,
        Stealth.getPubKey(getScanKey()!.privateKey!),
        hash160(getSpendKey()!.privateKey!),
        Stealth.getPubKey(getSpendKey()!.privateKey!),
        0);
  }

  int getIndex() {
    return _index;
  }

  Future<String> syncWithNode({int fromBlock = 0}) async {
    if (fromBlock == 0) {
      fromBlock = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    }

    var scanKeyPriv = hex.encode(getScanKey()!.privateKey!);
    var spendKeyPub = hex.encode(getSpendKey()!.publicKey);

    var importResponseRes = await RpcRequester.send(RpcRequest(
        jsonrpc: '1.0',
        method: 'importlightwalletaddress',
        params: [scanKeyPriv, spendKeyPub, fromBlock]));
    var importResponse =
        ImportLightwalletAddressResponse.fromJson(importResponseRes);
    var address = '';

    if (importResponse.error != null) {
      var importStatusRes = await RpcRequester.send(RpcRequest(
          jsonrpc: '1.0',
          method: 'getwatchonlystatus',
          params: [scanKeyPriv, spendKeyPub]));
      var importStatus = GetWatchOnlyStatusResponse.fromJson(importStatusRes);

      _syncStatus = importStatus.result?.status ?? 'unknown';

      address = importStatus.result?.stealth_address ?? '';
    } else {
      var importStatusRes = await RpcRequester.send(RpcRequest(
          jsonrpc: '1.0',
          method: 'getwatchonlystatus',
          params: [scanKeyPriv, spendKeyPub]));
      var importStatus = GetWatchOnlyStatusResponse.fromJson(importStatusRes);
      _syncStatus = importStatus.result?.status ?? 'unknown';

      address = importResponse.result!.stealth_address_bech!;
    }

    _syncWithNodeCalled = true;

    return address;
  }

  Future<List<CWatchOnlyTxWithIndex>?> fetchTxes(
      {bool fetchIfCacheExists = true}) async {
    if (!_syncWithNodeCalled || _syncStatus != 'synced') {
      await syncWithNode();
    }

    var scanKey = getScanKey();
    var spendKey = getSpendKey();

    List<CWatchOnlyTxWithIndex> txes = [];
    List<CWatchOnlyTxWithIndex> txToFetch = [];
    List<KeyImageResult> newKeyImageRes = [];

    var cachedTxes = 0;
    var db = await _lwAccount.getDb();
    var collKey = '${getIndex()}-main';
    if (db != null) {
      var txData = await db.getAll('$collKey:*');
      var txcnt = txData.length;
      cachedTxes = txcnt;

      // fill txes
      for (var tx in txData.values) {
        var txObj = CWatchOnlyTxWithIndex();
        txObj.deserialize(Uint8List.fromList(hex.decode(tx['raw'])), tx['raw']);
        txObj.getRingCtOut()?.decodeTx(spendKey!, scanKey!);
        txes.add(txObj);
      }

      // fill key images
      for (var tx in txData.values) {
        var ki = tx['keyimage'];
        if (ki == null) {
          // TO-DO log?
          newKeyImageRes.add(KeyImageResult());
          continue;
        }

        newKeyImageRes.add(KeyImageResult.fromJson(ki));
      }
    }

    final nTxCache = <String, dynamic>{};
    if (cachedTxes == 0 || fetchIfCacheExists) {
      var offset = cachedTxes;
      while (true) {
        var responseRes = await RpcRequester.send(
            RpcRequest(jsonrpc: '1.0', method: 'getwatchonlytxes', params: [
          hex.encode(scanKey!.privateKey!),
          offset + 1
        ])); // ref: https://github.com/Veil-Project/veil/blob/471fba9f3011b3cd611f1d1de63efc0841135796/src/wallet/rpcwallet.cpp#L1208
        var response = GetWatchOnlyTxesResponse.fromJson(responseRes);

        var counter = 0;
        for (var tx in response.result?.anon ?? []) {
          if (txes.any((el) => el.raw == tx.raw)) {
            counter = 0; // out of second condition
            break;
          }

          var txObj = CWatchOnlyTxWithIndex();
          txObj.deserialize(Uint8List.fromList(hex.decode(tx.raw)), tx.raw);
          txObj.getRingCtOut()?.decodeTx(spendKey!, scanKey);
          txes.add(txObj);
          txToFetch.add(txObj);

          nTxCache['$collKey:$offset'] = {
            'index': offset,
            'txid': txObj.getId(),
            // will be detecetd with special spent tx cache
            //'type': 0, // 2 - unknown, 1 - spent, 2 - received
            'keyimage': null,
            'spent': true,
            'amount': txObj.getAmount(_lwAccount.getWallet().getChainParams()),
            'raw': tx.raw
          };

          counter++;
          offset++;
        }

        if (counter < lightWalletApiMaxTxs) {
          break;
        }
      }
    }

    // get keyimages
    // sometimes we have duplicate tx id's for some reason (but with different KI, which might be consumed on other tx, careful!)

    if (txToFetch.isNotEmpty) {
      List<String> keyimages = [];
      for (var tx in txToFetch) {
        var kib = tx.getKeyImage();
        var ki = kib == null ? '' : hex.encode(kib);
        keyimages.add(ki);
      }
      // get keyimages info
      var kiResponseRes = await RpcRequester.send(RpcRequest(
          jsonrpc: '1.0', method: 'checkkeyimages', params: [keyimages]));
      var kiResponse = CheckKeyImagesResponse.fromJson(kiResponseRes);
      if (kiResponse.error != null) return null;

      // fix key images response
      for (var i = 0; i < (kiResponse.result?.length ?? 0); i++) {
        var tx = txToFetch[i];
        var keyImageRes = kiResponse.result![i];
        keyImageRes.txid = tx.getId();
        newKeyImageRes.add(keyImageRes);

        var json = keyImageRes.toJson();
        var dbIndex = cachedTxes + i;

        nTxCache['$collKey:$dbIndex']['keyimage'] = json;
        nTxCache['$collKey:$dbIndex']['spent'] = keyImageRes.spent;
      }
    }

    if (nTxCache.isNotEmpty) {
      await db?.putAll(nTxCache);
    }

    _keyImageCache = newKeyImageRes;
    _transactionsCache = txes.sublist(0);

    _txesSynced = true;
    await db?.close();

    return _transactionsCache;
  }

  Future<List<CWatchOnlyTxWithIndex>> getUnspentOutputs(
      {bool ignoreMemPoolSpend = false, bool fetchIfCacheExists = true}) async {
    if (_transactionsCache == null) {
      await fetchTxes(fetchIfCacheExists: fetchIfCacheExists);
      if (_transactionsCache == null) return [];
    }

    List<CWatchOnlyTxWithIndex> res = [];
    var txIndex = 0;
    for (var tx in _transactionsCache ?? []) {
      var txInfo =
          _keyImageCache?[txIndex]; // .firstWhere((a) => a.txid == tx.getId());
      txIndex++;
      if (!(txInfo?.spent ?? true) &&
          (!(txInfo?.spentinmempool ?? false) || ignoreMemPoolSpend)) {
        res.add(tx);
      }
    }

    return res;
  }

  Future<List<CWatchOnlyTxWithIndex>> getSpentOutputsInMemoryPool(
      {bool fetchIfCacheExists = true}) async {
    if (_transactionsCache == null) {
      await fetchTxes(fetchIfCacheExists: fetchIfCacheExists);
      if (_transactionsCache == null) return [];
    }

    List<CWatchOnlyTxWithIndex> res = [];
    for (var tx in _transactionsCache ?? []) {
      var txInfo = _keyImageCache?.firstWhere((a) => a.txid == tx.getId());
      if ((txInfo?.spentinmempool ?? false)) {
        res.add(tx);
      }
    }

    return res;
  }

  List<CWatchOnlyTxWithIndex>? getAllOutputs() {
    return _transactionsCache;
  }

  Future<double> getBalance(List<String>? substractTxes,
      {bool fetchIfCacheExists = true}) async {
    var res = await getUnspentOutputs(fetchIfCacheExists: fetchIfCacheExists);
    if (res.isEmpty) return 0;

    // compute balance
    double amount = 0;
    for (var utx in res) {
      if (substractTxes?.contains(utx.getId() ?? '') ?? false) continue;
      amount += utx.getAmount(_lwAccount.getWallet().getChainParams());
    }
    return amount;
  }

  Future getBalanceLocked({bool fetchIfCacheExists = true}) async {
    var res = await getSpentOutputsInMemoryPool(
        fetchIfCacheExists: fetchIfCacheExists);
    if (res.isEmpty) return 0;

    // compute balance
    double amount = 0;
    for (var utx in res) {
      amount += utx.getAmount(_lwAccount.getWallet().getChainParams());
    }
    return amount;
  }

  bip32.BIP32? getScanKey() {
    return _addressKey?.deriveHardened(1);
  }

  bip32.BIP32? getSpendKey() {
    return _addressKey?.deriveHardened(2);
  }

  Future<BuildTransactionResult> buildTransaction(
      List<CVeilRecipient> recipients,
      List<CWatchOnlyTxWithIndex> vSpendableTx,
      bool strategyUseSingleTxPriority,
      {int ringSize = 5}) async {
    var chainParams = _lwAccount.getWallet().getChainParams();
    var vDummyOutputs = await Lightwallet.getAnonOutputs(
        vSpendableTx.length * 2,
        ringSize: ringSize);

    // rebuild recipients
    List<CVeilRecipient> resultingRecipients = [];
    for (var rcp in recipients) {
      resultingRecipients.add(CVeilRecipient(rcp.address,
          double.parse(rcp.amount.toStringAsFixed(chainParams.COIN_DIGITS))));
    }

    return LightwalletTransactionBuilder.buildLightWalletTransaction(
        chainParams,
        this,
        resultingRecipients,
        vSpendableTx,
        vDummyOutputs,
        strategyUseSingleTxPriority,
        ringSize: ringSize);
  }

  String getStringAddress() {
    return _stealth?.toBech32(_lwAccount.getWallet().getChainParams()) ?? '';
  }

  String getSyncStatus() {
    return _syncStatus;
  }

  bool getTxSyncStatus() {
    return _txesSynced;
  }
}
