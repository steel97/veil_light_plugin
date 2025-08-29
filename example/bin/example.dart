// ignore_for_file: empty_catches, non_constant_identifier_names, constant_identifier_names, unused_local_variable, prefer_single_quotes, unnecessary_import
import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';
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

  print('init');
  var rawMnemonic = await File('./example_mnemonic.txt').readAsString();
  var key = hex.encode(hash256(utf8.encode(rawMnemonic))).substring(0, 32);
  print(key);
  var wallet =
      await Lightwallet.fromMnemonic(mainNetParams, rawMnemonic.split(' '),
          storageName: "default",
          encryptionKey: null, //key,
          storagePath: './test.storage');
  var account = LightwalletAccount(wallet);
  var mainAddress = account.getAddress(AccountType.STEALTH);

  print(mainAddress.getStringAddress());
  await account.syncWithNode([mainAddress]);
  print('sync with node ended!');
  print('Your balance ${await account.getBalanceFormatted([
        mainAddress
      ], List.empty(), fetchIfCacheExists: true)}');
//const mainBalance = await mainAddress.getBalance();
//console.log(`Main address balance: ${mainBalance}`);

  print('get utxo');
  var utxos = await mainAddress.getUnspentOutputs(fetchIfCacheExists: true);
  utxos.sort((a, b) =>
      a.getAmount(mainNetParams).compareTo(b.getAmount(mainNetParams)));
  List<CWatchOnlyTxWithIndex> selectedUtxos = [];
  double targetAmountToSend = 1500;
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
            "sv1qqp3hydaxd9lemnsmsta52tcaj66v2rt2v6kresn302amwdftwgp3acpqg2dsprdfen7zk72lsx96k2aujgmv7z9j3nusv5a5zf95de8qv6s6qqq276sh6")!, //sv1qqp3hydaxd9lemnsmsta52tcaj66v2rt2v6kresn302amwdftwgp3acpqg2dsprdfen7zk72lsx96k2aujgmv7z9j3nusv5a5zf95de8qv6s6qqq276sh6
        targetAmountToSend)
  ], selectedUtxos, true);
  print('done!');
  //print(tx.txdata);
  //var res = await Lightwallet.publishTransaction(tx.txdata!);
  //print(res.message);
}
