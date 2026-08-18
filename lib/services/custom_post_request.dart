import 'dart:convert';
import 'package:leadmanagementsystem/utils/dev_log.dart';
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

  /// Multipart POST where the file is optional â€” used for endpoints like
  /// follow-ups where an image may or may not be attached alongside text
  /// fields.
  Future customMultipartPost({
    required String url,
    required Map<String, String> fields,
    File? file,
    String fileField = "image",
  }) async {
    try {
      var urlPath = '$baseUrl$url';
      if (kDebugMode) log('url--->$urlPath');

      var request = http.MultipartRequest('POST', Uri.parse(urlPath));
      request.fields.addAll(fields);

      if (file != null) {
        request.files
            .add(await http.MultipartFile.fromPath(fileField, file.path));
      }

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
