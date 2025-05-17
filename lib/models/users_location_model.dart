class UsersLocationModel {
  bool? status;
  List<LocationsData>? data;

  UsersLocationModel({this.status, this.data});

  UsersLocationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <LocationsData>[];
      json['data'].forEach((v) {
        data!.add(LocationsData.fromJson(v));
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

class LocationsData {
  String? sId;
  String? name;
  String? email;
  String? role;
  String? company;
  String? area;
  String? lat;
  String? long;
  String? areaName;
  String? updatedAt;

  LocationsData(
      {this.sId,
      this.name,
      this.email,
      this.role,
      this.company,
      this.area,
      this.lat,
      this.long,
      this.areaName,
      this.updatedAt});

  LocationsData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    role = json['role'];
    company = json['company'];
    area = json['area'];
    lat = json['lat'];
    long = json['long'];
    areaName = json['areaName'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['company'] = company;
    data['area'] = area;
    data['lat'] = lat;
    data['long'] = long;
    data['areaName'] = areaName;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
