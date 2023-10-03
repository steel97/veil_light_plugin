// ignore_for_file: constant_identifier_names

import 'package:bip32/bip32.dart' as bip32;
import 'package:veil_light_plugin/src/veil/lightwallet.dart';
import 'package:veil_light_plugin/src/veil/lightwallet_address.dart';
//import { BIP32Interface } from "bip32";
//import Lightwallet from "./Lightwallet";
//import LightwalletAddress from "./LightwalletAddress";

enum AccountType {
  DEFAULT(0),
  STEALTH(1),
  CHANGE(2);

  const AccountType(this.value);
  final int value;
}

class LightwalletAccount {
  final Lightwallet _wallet;

  bip32.BIP32? _walletAccount;
  bip32.BIP32? _keyMasterAnon;

  bip32.BIP32? _vDefaultAccount;
  bip32.BIP32? _vStealthAccount;
  bip32.BIP32? _vChangeAccount;

  LightwalletAccount(this._wallet, {int accountId = 0}) {
    _walletAccount = _wallet.getKeyCoin().deriveHardened(accountId);

    _keyMasterAnon =
        _walletAccount?.deriveHardened(_wallet.getChainParams().nRingCTAccount);
    _vDefaultAccount = _keyMasterAnon?.deriveHardened(1);
    _vStealthAccount = _keyMasterAnon?.deriveHardened(2);
    _vChangeAccount = _keyMasterAnon?.deriveHardened(3);
  }

  LightwalletAddress getAddress(AccountType fromAccount, {int index = 1}) {
    var address =
        LightwalletAddress(this, getAccount(fromAccount)!, fromAccount, index);
    return address;
  }

  bip32.BIP32? getAccount(AccountType type) {
    switch (type) {
      case AccountType.STEALTH:
        return _vStealthAccount;
      case AccountType.CHANGE:
        return _vChangeAccount;
      case AccountType.DEFAULT:
        return _vDefaultAccount;
    }
  }

  Future<double> getBalanceRaw(
      List<LightwalletAddress> input, List<String> substractTxes) async {
    double amount = 0;
    for (var addr in input) {
      amount += await addr.getBalance(substractTxes);
    }

    return amount;
  }

  Future<String> getBalanceFormatted(
      List<LightwalletAddress> input, List<String> substractTxes) async {
    var res = await getBalanceRaw(input, substractTxes);
    return res.toStringAsFixed(_wallet.getChainParams().COIN_DIGITS);
  }

  String formatAmount(double amount) {
    return amount.toStringAsFixed(_wallet.getChainParams().COIN_DIGITS);
  }

  Lightwallet getWallet() {
    return _wallet;
  }
}
