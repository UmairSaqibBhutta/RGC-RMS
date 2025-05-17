
class UsersListModel {
  bool status;
  List<UserData>? data;

  UsersListModel({
    required this.status,
    this.data,
  });

  factory UsersListModel.fromJson(Map<String, dynamic> json) => UsersListModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<UserData>.from(
                json["data"].map((x) => UserData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null
            ? []
            : List<UserData>.from(data!.map((x) => x.toJson())),
      };
}

class UserData {
  String id;
  String name;
  String email;
  String password;
  String role;
  String status;
  DateTime createdDate;
  String? phone; // Nullable phone field

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.status,
    required this.createdDate,
    this.phone, // Phone field is optional
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        password: json["password"],
        role: json["role"],
        status: json["status"],
        createdDate: DateTime.parse(json["createdDate"]),
        phone: json["phone"], // Parse the phone field
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "password": password,
        "role": role,
        "status": status,
        "createdDate": createdDate.toIso8601String(),
        "phone": phone, // Include the phone field
      };
}
