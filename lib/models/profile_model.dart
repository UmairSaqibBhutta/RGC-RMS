class ProfileModel {
  bool? status;
  ProfileData? data;

  ProfileModel({this.status, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? ProfileData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProfileData {
  String? sId;
  String? name;
  String? fcmToken;
  String? email;
  String? password;
  String? role;
  String? status;
  String? phone;
  String? createdDate;
  String? company;

  ProfileData(
      {this.sId,
        this.name,
        this.fcmToken,
        this.email,
        this.password,
        this.role,
        this.status,
        this.phone,
        this.createdDate,
        this.company
        });

  ProfileData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    fcmToken = json['fcmToken'];
    email = json['email'];
    password = json['password'];
    role = json['role'];
    status = json['status'];
    phone = json['phone'];
    createdDate = json['createdDate'];
    company = json['company'];
    
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['fcmToken'] = fcmToken;
    data['email'] = email;
    data['password'] = password;
    data['role'] = role;
    data['status'] = status;
    data['phone'] = phone;
    data['createdDate'] = createdDate;
    data['company'] = company;
    return data;
  }
}
