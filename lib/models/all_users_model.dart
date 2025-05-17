class AllUserModel {
  bool? status;
  List<AllUsersData>? data;

  AllUserModel({this.status, this.data});

  AllUserModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <AllUsersData>[];
      json['data'].forEach((v) {
        data!.add(AllUsersData.fromJson(v));
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

class AllUsersData {
  String? sId;
  String? name;
  String? email;
  String? password;
  String? role;
  String? status;
  String? phone;
  String? createdDate;
  int? iV;
  String? company;
  String? region;
  String? area;
  String? fcmToken;

  AllUsersData(
      {this.sId,
        this.name,
        this.email,
        this.password,
        this.role,
        this.status,
        this.phone,
        this.createdDate,
        this.iV,
        this.company,
        this.region,
        this.area,
        this.fcmToken});

  AllUsersData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    role = json['role'];
    status = json['status'];
    phone = json['phone'];
    createdDate = json['createdDate'];
    iV = json['__v'];
    company = json['company'];
    region = json['region'];
    area = json['area'];
    fcmToken = json['fcmToken'];
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
    data['createdDate'] = createdDate;
    data['__v'] = iV;
    data['company'] = company;
    data['region'] = region;
    data['area'] = area;
    data['fcmToken'] = fcmToken;
    return data;
  }
}
