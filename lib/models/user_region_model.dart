class UserRegionModel {
  bool? status;
  List<UserRegionData>? data;

  UserRegionModel({this.status, this.data});

  UserRegionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <UserRegionData>[];
      json['data'].forEach((v) {
        data!.add(UserRegionData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserRegionData {
  String? sId;
  String? name;
  String? email;
  String? password;
  String? role;
  String? status;
  String? phone;
  String? company;
  String? region;
  String? area;
  String? createdDate;
  String? fcmToken;
  int? iV;

  UserRegionData(
      {this.sId,
        this.name,
        this.email,
        this.password,
        this.role,
        this.status,
        this.phone,
        this.fcmToken,
        this.company,
        this.region,
        this.area,
        this.createdDate,
        this.iV});

  UserRegionData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    role = json['role'];
    status = json['status'];
    phone = json['phone'];
    fcmToken = json['fcmToken'];
    company = json['company'];
    region = json['region'];
    area = json['area'];
    createdDate = json['createdDate'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['role'] = role;
    data['status'] = status;
    data['phone'] = phone;
    data['fcmToken'] = fcmToken;
    data['company'] = company;
    data['region'] = region;
    data['area'] = area;
    data['createdDate'] = createdDate;
    data['__v'] = iV;
    return data;
  }
}
