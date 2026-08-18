import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Drop-in replacement for `dart:developer`'s `log()` with the same
/// signature — import this instead and every existing `log(...)` call site
/// stays unchanged, but now only actually logs in debug builds.
void log(
  String message, {
  DateTime? time,
  int? sequenceNumber,
  int level = 0,
  String name = '',
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;
  developer.log(
    message,
    time: time,
    sequenceNumber: sequenceNumber,
    level: level,
    name: name,
    zone: zone,
    error: error,
    stackTrace: stackTrace,
  );
}
