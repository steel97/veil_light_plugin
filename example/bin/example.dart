//import 'dart:typed_data';
//import 'package:convert/convert.dart';
//import 'package:example/example.dart' as example;
//import 'package:veil_light_plugin/native/plugin.dart' as veil_light_plugin;
import 'package:veil_light_plugin/src/veil/lightwallet.dart';
import 'package:veil_light_plugin/src/veil/lightwallet_account.dart';
import 'package:veil_light_plugin/src/veil/cveil_address.dart';
import 'package:veil_light_plugin/src/veil/cveil_recipient.dart';
import 'package:veil_light_plugin/veil_light.dart';
import 'package:veil_light_plugin/src/veil/tx/cwatch_only_tx_with_index.dart';

Future<void> main(List<String> arguments) async {
  var newMnemonic = [
    'crowd',
    'carpet',
    'box',
    'unique',
    'machine',
    'legend',
    'crane',
    'frost',
    'village',
    'cradle',
    'evoke',
    'output',
    'universe',
    'until',
    'gravity',
    'unable',
    'hint',
    'chef',
    'check',
    'lava',
    'flavor',
    'razor',
    'address',
    'silk'
  ];
// sv1qqpn9yl9nkj5vkfqqwd8vfn4np35uds8q99azar62w63xpwal8k92lgpq0jq89492m2eaj4w28spmwnguf3ust48ttvwac4z745fy7p6w8ctsqqqgwp49j
  var wallet = Lightwallet.fromMnemonic(mainNetParams, newMnemonic);
  var account = LightwalletAccount(wallet);
  var mainAddress = account.getAddress(AccountType.STEALTH);

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
  ], selectedUtxos, true
      //targetAmountToSend,
      //selectedUtxos
      );
//const res = await Lightwallet.publishTransaction(tx!);
  print(tx);
  /*if (res != null) {
    print('${hex.encode(res)}');
  }*/
}
