// ignore_for_file: non_constant_identifier_names

import 'package:veil_light_plugin/src/veil/chainparams.dart';

class CoinSelection {
  CoinSelection(Chainparams params) {
    MIN_CHANGE = params.CENT;
    MIN_FINAL_CHANGE = BigInt.from(MIN_CHANGE / BigInt.from(2));
  }
  //! target minimum change amount
  BigInt MIN_CHANGE = BigInt.from(0);
  //! final minimum change amount after paying for fees
  BigInt MIN_FINAL_CHANGE = BigInt.from(0);
}
