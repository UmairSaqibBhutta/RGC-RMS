extension NullableStringCheck on String? {
  /// checks if string is null or empty
 bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}
