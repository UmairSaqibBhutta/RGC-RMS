class LoginModel {
  bool? status;
  String? message;
  String? token;
  UserData? userData;

  LoginModel({this.status, this.message, this.token, this.userData});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    token = json['token'];
    userData = json['userData'] != null
        ? UserData.fromJson(json['userData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['token'] = token;
    if (userData != null) {
      data['userData'] = userData!.toJson();
    }
    return data;
  }
}

class UserData {
  String? sId;
  String? name;
  String? email;
  String? password;
  String? role;
  String? status;
  String? company;
  String? fcmToken;
  String? region;
  String? createdDate;
  int? iV;

  UserData(
      {this.sId,
        this.name,
        this.email,
        this.password,
        this.role,
        this.status,
        this.fcmToken,
        this.company,
        this.region,
        this.createdDate,
        this.iV});

  UserData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    fcmToken = json['fcmToken'];
    role = json['role'];
    status = json['status'];
    company = json['company'];
    region = json['region'];
    createdDate = json['createdDate'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['fcmToken'] = fcmToken;
    data['role'] = role;
    data['status'] = status;
    data['company'] = company;
    data['region'] = region;
    data['createdDate'] = createdDate;
    data['__v'] = iV;
    return data;
  }
}
