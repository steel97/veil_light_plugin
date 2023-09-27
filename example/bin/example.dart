import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:example/example.dart' as example;
import 'package:veil_light_plugin/native/plugin.dart' as veil_light_plugin;

void main(List<String> arguments) {
  print('Hello world: ${example.calculate()}!');

  var pk = Uint8List(33);
  var sk = Uint8List(33);
  sk[0] = 2;

  veil_light_plugin.initializeContext();
  var res = veil_light_plugin.getKeyImage(pk, sk);

  if (res != null) {
    print('${hex.encode(res)}');
  }
}
