class CommonResponse {
  final bool status;
  final String message;

  CommonResponse({required this.status, required this.message});

  // Factory constructor to create an instance from JSON
  factory CommonResponse.fromJson(Map<String, dynamic> json) {
    return CommonResponse(
      status: json['status'],
      message: json['message'],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}
