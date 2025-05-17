import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:leadmanagementsystem/constants/constants.dart';

class CustomGetRequest {
  Future customGetRequest({required String apiPath}) async {
    try {
      final api = '$apiBaseUrl$apiPath';

      log('api-->$api');

      http.Response response = await http.get(Uri.parse(api));

      log('apiPath--->$apiPath');


      log('response--->${response.body}');
      log('statusResponse--->${response.statusCode}');

      var jsonDecoded = json.decode(response.body);

      if (response.statusCode == 200) {
        return jsonDecoded;
      } else {
        return null;
      }
    } catch (err) {
      log(err.toString());
      return null;
    }
  }
}
