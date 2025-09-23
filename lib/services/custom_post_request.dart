import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:leadmanagementsystem/constants/constants.dart';

class CustomPostRequest {
  Future customPostRequest({required String url, required Map body}) async {
    try {
      var headers = {'accept': '*/*', 'Content-Type': 'application/json'};

      var urlPath = '$baseUrl$url';
      if (kDebugMode) log('url--->$urlPath');

      http.Response response = await http.post(Uri.parse(urlPath),
          body: json.encode(body), headers: headers);
      if (kDebugMode) {
        print('response--->${response.body}');

        log('body---${response.body}');
        log('statusCode---${response.statusCode}');
      }

      var jsonDecoded = json.decode(response.body);

      return jsonDecoded;
    } catch (err) {
      log(err.toString());
    }
  }

  Future customFileUpload({
    required String url,
    required File file,
    String fileField = "file",
    Map<String, String>? fields,
  }) async {
    try {
      var urlPath = '$baseUrl$url';
      if (kDebugMode) log('url--->$urlPath');

      var request = http.MultipartRequest('POST', Uri.parse(urlPath));

      // Add extra fields if provided
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Attach file
      request.files
          .add(await http.MultipartFile.fromPath(fileField, file.path));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('response--->${response.body}');
        log('body---${response.body}');
        log('statusCode---${response.statusCode}');
      }

      var jsonDecoded = json.decode(response.body);
      return jsonDecoded;
    } catch (err) {
      log(err.toString());
      return null;
    }
  }
}
