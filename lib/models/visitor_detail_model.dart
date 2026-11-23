class VisitorDetail {
  final String id;
  final String companyName;
  final String personName;
  final String designation;
  final List<String> contacts;
  final String email;
  final String officeAddress;

  final String comments;

  /// File names only; display each with `baseUrl + name`.
  final List<String> images;
  final DateTime? createdAt;

  VisitorDetail({
    required this.id,
    required this.companyName,
    required this.personName,
    required this.designation,
    required this.contacts,
    required this.email,
    required this.officeAddress,
    this.comments = '',
    this.images = const [],
    this.createdAt,
  });

  bool get hasImage => images.isNotEmpty;

  /// Best available heading, since every field is optional.
  String get title => companyName.isNotEmpty
      ? companyName
      : (personName.isNotEmpty ? personName : 'Visiting Card');

  factory VisitorDetail.fromJson(Map<String, dynamic> json) {
    final c = json['contact'];
    final imgs = json['images'];
    final legacy = json['image']?.toString();
    return VisitorDetail(
      id: (json['_id'] ?? '').toString(),
      companyName: json['company_name']?.toString() ?? '',
      personName: json['person_name']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',
      contacts: c is List
          ? c.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : (c == null || c.toString().isEmpty ? [] : [c.toString()]),
      email: json['email']?.toString() ?? '',
      officeAddress: json['office_address']?.toString() ?? '',
      comments: json['comments']?.toString() ?? '',
      images: imgs is List
          ? imgs.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : (legacy != null && legacy.isNotEmpty ? [legacy] : []),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal()
          : null,
    );
  }

  /// Text used for client-side search.
  String get searchText => [
        companyName,
        personName,
        designation,
        email,
        officeAddress,
        comments,
        ...contacts
      ].join(' ').toLowerCase();
}
