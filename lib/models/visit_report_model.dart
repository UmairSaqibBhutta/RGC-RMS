class VisitReportModel {
  bool? status;
  List<VisitData>? data;

  VisitReportModel({this.status, this.data});

  VisitReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <VisitData>[];
      json['data'].forEach((v) {
        data!.add(VisitData.fromJson(v));
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

class VisitData {
  String? sId;
  String? userId;
  String? townPahse;
  String? block;
  String? site;
  String? gco;
  String? keyPN;
  String? keyPC;
  String? architect;
  String? callResult;
  String? createdAt;
  String? updatedAt;
  int? iV;
  CheckIn? checkIn;
  CheckIn? checkOut;
  UserDetail? userDetail;

  VisitData(
      {this.sId,
      this.userId,
      this.townPahse,
      this.block,
      this.site,
      this.gco,
      this.keyPN,
      this.keyPC,
      this.architect,
      this.callResult,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.checkIn,
      this.checkOut,
      this.userDetail});

  VisitData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    townPahse = json['townPahse'];
    block = json['block'];
    site = json['site'];
    gco = json['gco'];
    keyPN = json['keyPN'];
    keyPC = json['keyPC'];
    architect = json['architect'];
    callResult = json['callResult'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    checkIn =
        json['checkIn'] != null ? CheckIn.fromJson(json['checkIn']) : null;
    checkOut =
        json['checkOut'] != null ? CheckIn.fromJson(json['checkOut']) : null;
    userDetail = json['userDetail'] != null
        ? UserDetail.fromJson(json['userDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['townPahse'] = townPahse;
    data['block'] = block;
    data['site'] = site;
    data['gco'] = gco;
    data['keyPN'] = keyPN;
    data['keyPC'] = keyPC;
    data['architect'] = architect;
    data['callResult'] = callResult;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (checkIn != null) {
      data['checkIn'] = checkIn!.toJson();
    }
    if (checkOut != null) {
      data['checkOut'] = checkOut!.toJson();
    }
    if (userDetail != null) {
      data['userDetail'] = userDetail!.toJson();
    }
    return data;
  }
}

class CheckIn {
  String? image;
  String? location;
  String? time;

  CheckIn({this.image, this.location, this.time});

  CheckIn.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    location = json['location'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['location'] = location;
    data['time'] = time;
    return data;
  }
}

class UserDetail {
  String? name;
  String? email;
  String? role;
  String? status;
  String? company;
  String? region;
  String? area;

  UserDetail(
      {this.name,
      this.email,
      this.role,
      this.status,
      this.company,
      this.region,
      this.area});

  UserDetail.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    role = json['role'];
    status = json['status'];
    company = json['company'];
    region = json['region'];
    area = json['area'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['status'] = status;
    data['company'] = company;
    data['region'] = region;
    data['area'] = area;
    return data;
  }
}
