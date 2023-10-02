import 'dart:io';

import 'package:veil_light_plugin/src/veil/lightwallet.dart';
import 'package:veil_light_plugin/src/veil/lightwallet_account.dart';
import 'package:veil_light_plugin/src/veil/cveil_address.dart';
import 'package:veil_light_plugin/src/veil/cveil_recipient.dart';
import 'package:veil_light_plugin/veil_light.dart';
import 'package:veil_light_plugin/src/veil/tx/cwatch_only_tx_with_index.dart';

Future<void> main(List<String> arguments) async {
  //sv1qqp3hydaxd9lemnsmsta52tcaj66v2rt2v6kresn302amwdftwgp3acpqg2dsprdfen7zk72lsx96k2aujgmv7z9j3nusv5a5zf95de8qv6s6qqq276sh6
  /*var addr = CVeilAddress.parse(mainNetParams,
      "sv1qqp3hydaxd9lemnsmsta52tcaj66v2rt2v6kresn302amwdftwgp3acpqg2dsprdfen7zk72lsx96k2aujgmv7z9j3nusv5a5zf95de8qv6s6qqq276sh6");
  print(addr!.isValid());
  print(addr!.isValidStealthAddress());
  return;*/
  var rawMnemonic = await File('./example_mnemonic.txt').readAsString();
  var wallet = Lightwallet.fromMnemonic(mainNetParams, rawMnemonic.split(' '));
  var account = LightwalletAccount(wallet);
  var mainAddress = account.getAddress(AccountType.STEALTH);

  print(mainAddress.getStringAddress());
  print('Your balance ${await account.getBalanceFormatted([
        mainAddress
      ], List.empty())}');
//const mainBalance = await mainAddress.getBalance();
//console.log(`Main address balance: ${mainBalance}`);

  var utxos = await mainAddress.getUnspentOutputs();
  List<CWatchOnlyTxWithIndex> selectedUtxos = [];
  double targetAmountToSend = 3;
  double curAmount = 0;
  for (var utxo in utxos) {
    curAmount += utxo.getAmount(wallet.getChainParams());
    selectedUtxos.add(utxo);
    if (curAmount > targetAmountToSend) {
      break;
    }
  }
  print('selected utxos: ${selectedUtxos.length}');
  var tx = await mainAddress.buildTransaction([
    CVeilRecipient(
        CVeilAddress.parse(wallet.getChainParams(),
            "sv1qqp3hydaxd9lemnsmsta52tcaj66v2rt2v6kresn302amwdftwgp3acpqg2dsprdfen7zk72lsx96k2aujgmv7z9j3nusv5a5zf95de8qv6s6qqq276sh6")!,
        targetAmountToSend)
  ], selectedUtxos, true);
  //var res = await Lightwallet.publishTransaction(tx.txdata!);
  //print(res.txid);
}
