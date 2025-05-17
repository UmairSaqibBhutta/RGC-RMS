import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:leadmanagementsystem/constants/constants.dart';

class CustomPostRequest {
  Future customPostRequest({required String url, required Map body}) async {
    try {
      var headers = {'accept': '*/*', 'Content-Type': 'application/json'};

      var urlPath = '$apiBaseUrl$url';

      log('url--->$urlPath');

      http.Response response = await http.post(Uri.parse(urlPath),
          body: json.encode(body), headers: headers);

      print('response--->${response.body}');

      log('body---${response.body}');
      log('statusCode---${response.statusCode}');

      var jsonDecoded = json.decode(response.body);

      return jsonDecoded;
    } catch (err) {
      log(err.toString());
    }
  }
}
