// ignore_for_file: non_constant_identifier_names
import "package:flutter_bitcoin/flutter_bitcoin.dart";
import "package:veil_light_plugin/src/veil/core/cfee_rate.dart";

class Base58Prefixes {
  final int PUBKEY_ADDRESS;
  final int SCRIPT_ADDRESS;
  final int SECRET_KEY;
  final int STEALTH_ADDRESS;
  final int EXT_PUBLIC_KEY;
  final int EXT_SECRET_KEY;

  Base58Prefixes(
      {required this.PUBKEY_ADDRESS,
      required this.SCRIPT_ADDRESS,
      required this.SECRET_KEY,
      required this.STEALTH_ADDRESS,
      required this.EXT_PUBLIC_KEY,
      required this.EXT_SECRET_KEY});
}

class Bech32Prefixes {
  final String STEALTH_ADDRESS;
  final String BASE_ADDRESS;

  Bech32Prefixes({required this.STEALTH_ADDRESS, required this.BASE_ADDRESS});
}

class Chainparams {
  final Base58Prefixes base58Prefixes;
  final Bech32Prefixes bech32Prefixes;
  final int nBIP44ID;
  final int nRingCTAccount;
  final int nZerocoinAccount;

  final int COIN_DIGITS;
  final BigInt COIN;
  final int CENT_DIGITS;
  final BigInt CENT;
  final int DEFAULT_MIN_RELAY_TX_FEE;
  final CFeeRate? minRelayTxFee;
  final NetworkType? veilNetwork;

  Chainparams(
      {required this.base58Prefixes,
      required this.bech32Prefixes,
      required this.nBIP44ID,
      required this.nRingCTAccount,
      required this.nZerocoinAccount,
      required this.COIN_DIGITS,
      required this.COIN,
      required this.CENT_DIGITS,
      required this.CENT,
      required this.DEFAULT_MIN_RELAY_TX_FEE,
      required this.minRelayTxFee,
      required this.veilNetwork});
}

var MAINNET_DEFAULT_MIN_RELAY_TX_FEE = 1000;
var mainNetBech32 = Bech32Prefixes(STEALTH_ADDRESS: "sv", BASE_ADDRESS: "bv");
var mainNetBase58 = Base58Prefixes(
    PUBKEY_ADDRESS: 0x46,
    SCRIPT_ADDRESS: 0x05,
    SECRET_KEY: 0x80,
    STEALTH_ADDRESS: 0x84,
    EXT_PUBLIC_KEY: 0x0488b21e,
    EXT_SECRET_KEY: 0x0488ade4);
var mainNetParams = Chainparams(
    base58Prefixes: mainNetBase58,
    bech32Prefixes: mainNetBech32,
    nBIP44ID: 0x800002ba,
    nRingCTAccount: 20000,
    nZerocoinAccount: 100000,

    // CAmount
    COIN_DIGITS: 8,
    COIN: BigInt.from(100000000),
    CENT_DIGITS: 6,
    CENT: BigInt.from(1000000),
    DEFAULT_MIN_RELAY_TX_FEE: MAINNET_DEFAULT_MIN_RELAY_TX_FEE,
    minRelayTxFee: CFeeRate(nSatoshisPerK: MAINNET_DEFAULT_MIN_RELAY_TX_FEE),
    veilNetwork: NetworkType(
        messagePrefix: "\x19Veil Signed Message:\n",
        bip32: Bip32Type(
            public: mainNetBase58.EXT_PUBLIC_KEY,
            private: mainNetBase58.EXT_SECRET_KEY),
        pubKeyHash: mainNetBase58.PUBKEY_ADDRESS,
        scriptHash: mainNetBase58.SCRIPT_ADDRESS,
        wif: mainNetBase58.SECRET_KEY,
        bech32: mainNetBech32.BASE_ADDRESS));
