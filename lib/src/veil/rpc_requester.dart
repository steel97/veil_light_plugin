// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:veil_light_plugin/src/models/rpc/rpc_request.dart";

class RpcRequester {
  static String NODE_URL = "https://explorer-api.veil-project.com";
  static String NODE_PASSWORD = "";

  static Future<T> send<T>(RpcRequest request) async {
    Map<String, String> headers = {};
    //var useCredentials = false;
    if (RpcRequester.NODE_PASSWORD != "") {
      headers = {'Authorization': "Basic ${RpcRequester.NODE_PASSWORD}"};
      //useCredentials = true;
    }

    var url = Uri.parse(NODE_URL);
    var rawResponse = await http.post(url,
        headers: headers, body: jsonEncode(request.toJson()));

    Map<String, dynamic> data = jsonDecode(rawResponse.body);
    T resp = ((T) as dynamic).fromJson(data);
    return resp;
  }
}
