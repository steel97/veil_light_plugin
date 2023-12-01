// ignore_for_file: unused_import

import 'dart:typed_data';

import 'package:convert/convert.dart';
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

  Future<List<CWatchOnlyTxWithIndex>?> fetchTxes() async {
    if (!_syncWithNodeCalled || _syncStatus != 'synced') {
      await syncWithNode();
    }

    var scanKey = getScanKey();
    var spendKey = getSpendKey();

    var responseRes = await RpcRequester.send(RpcRequest(
        jsonrpc: '1.0',
        method: 'getwatchonlytxes',
        params: [hex.encode(scanKey!.privateKey!)]));
    var response = GetWatchOnlyTxesResponse.fromJson(responseRes);

    List<CWatchOnlyTxWithIndex> txes = [];
    for (var tx in response.result?.anon ?? []) {
      var txObj = CWatchOnlyTxWithIndex();
      txObj.deserialize(Uint8List.fromList(hex.decode(tx.raw)), tx.raw);
      txObj.getRingCtOut()?.decodeTx(spendKey!, scanKey);
      txes.add(txObj);
    }

    // get keyimages
    // sometimes we have duplicate tx id's for some reason (but with different KI, which might be consumed on other tx, careful!)
    List<String> keyimages = [];
    for (var tx in txes) {
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
    List<KeyImageResult> newKeyImageRes = [];
    for (var i = 0; i < (kiResponse.result?.length ?? 0); i++) {
      var tx = txes[i];
      var keyImageRes = kiResponse.result![i];
      keyImageRes.txid = tx.getId();
      newKeyImageRes.add(keyImageRes);
    }

    _keyImageCache = newKeyImageRes;
    _transactionsCache = txes.sublist(0);

    return _transactionsCache;
  }

  Future<List<CWatchOnlyTxWithIndex>> getUnspentOutputs(
      {ignoreMemPoolSpend = false}) async {
    if (_transactionsCache == null) {
      await fetchTxes();
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

  Future<List<CWatchOnlyTxWithIndex>> getSpentOutputsInMemoryPool() async {
    if (_transactionsCache == null) {
      await fetchTxes();
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

  Future<double> getBalance(List<String>? substractTxes) async {
    var res = await getUnspentOutputs();
    if (res.isEmpty) return 0;

    // compute balance
    double amount = 0;
    for (var utx in res) {
      if (substractTxes?.contains(utx.getId() ?? '') ?? false) continue;
      amount += utx.getAmount(_lwAccount.getWallet().getChainParams());
    }
    return amount;
  }

  Future getBalanceLocked() async {
    var res = await getSpentOutputsInMemoryPool();
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
    var vDummyOutputs = await Lightwallet.getAnonOutputs(vSpendableTx.length,
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
}
