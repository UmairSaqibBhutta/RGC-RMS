class VisitorDetail {
  final String id;
  final String companyName;
  final String personName;
  final String designation;
  final List<String> contacts;
  final String email;
  final String officeAddress;

  /// File name only; display with `baseUrl + image`.
  final String? image;
  final DateTime? createdAt;

  VisitorDetail({
    required this.id,
    required this.companyName,
    required this.personName,
    required this.designation,
    required this.contacts,
    required this.email,
    required this.officeAddress,
    this.image,
    this.createdAt,
  });

  bool get hasImage => image != null && image!.isNotEmpty;

  factory VisitorDetail.fromJson(Map<String, dynamic> json) {
    final c = json['contact'];
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
      image: json['image']?.toString(),
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
        ...contacts
      ].join(' ').toLowerCase();
}
