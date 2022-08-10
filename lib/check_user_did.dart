import 'dart:convert';

import 'package:dio/dio.dart';

class CheckUserDID {
  Future<String> check(String userDID) async {
    try {
      var response =
          await Dio().get('http://10.0.2.2:8081/1.0/identifiers/$userDID');
      print(response);
      final object = json.decode(response.toString());
      final prettyString = const JsonEncoder.withIndent('  ').convert(object);

      return prettyString;
    } catch (e) {
      print(e);
      return '';
    }
  }
}
