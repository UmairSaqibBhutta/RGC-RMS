import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:leadmanagementsystem/constants/constants.dart';

class CustomGetRequest {
  Future customGetRequest({required String apiPath}) async {
    try {
      final api = '$baseUrl$apiPath';

      if (kDebugMode) log('api-->$api');

      http.Response response = await http.get(Uri.parse(api));

      if (kDebugMode) {
        log('apiPath--->$apiPath');
        log('statusResponse--->${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return _decodeBody(response.body);
      } else {
        return null;
      }
    } catch (err) {
      log(err.toString());
      return null;
    }
  }

  /// Tries to decode [raw] as JSON. If it fails due to unescaped `"` characters
  /// inside string values (a common server-side serialisation bug), it applies a
  /// state-machine sanitiser that escapes those inner quotes and retries.
  dynamic _decodeBody(String raw) {
    try {
      return json.decode(raw);
    } on FormatException catch (e) {
      log('⚠️ JSON FormatException: $e — attempting sanitisation');
      try {
        final sanitized = _sanitizeJson(raw);
        return json.decode(sanitized);
      } catch (e2) {
        log('❌ Sanitisation also failed: $e2');
        return null;
      }
    }
  }

  /// Scans the raw JSON string character-by-character. When inside a quoted
  /// string value, any `"` that is NOT followed by `,`, `}`, `]`, `:`, or
  /// end-of-input (after optional whitespace) is treated as an unescaped inner
  /// quote and replaced with `\"`.
  String _sanitizeJson(String raw) {
    final buf = StringBuffer();
    bool inString = false;
    bool prevEscape = false;

    for (int i = 0; i < raw.length; i++) {
      final ch = raw[i];

      if (prevEscape) {
        buf.write(ch);
        prevEscape = false;
        continue;
      }

      if (ch == '\\' && inString) {
        buf.write(ch);
        prevEscape = true;
        continue;
      }

      if (ch == '"') {
        if (!inString) {
          inString = true;
          buf.write(ch);
          continue;
        }

        // Already in a string — decide: closing quote or unescaped inner quote?
        // Peek at the next non-whitespace character.
        int j = i + 1;
        while (j < raw.length &&
            (raw[j] == ' ' ||
                raw[j] == '\t' ||
                raw[j] == '\n' ||
                raw[j] == '\r')) {
          j++;
        }
        final next = j < raw.length ? raw[j] : '\x00';

        if (next == ',' ||
            next == '}' ||
            next == ']' ||
            next == ':' ||
            next == '\x00') {
          // Legitimate closing quote.
          inString = false;
          buf.write(ch);
        } else {
          // Unescaped inner quote — escape it.
          buf.write(r'\"');
        }
        continue;
      }

      buf.write(ch);
    }

    return buf.toString();
  }
}
