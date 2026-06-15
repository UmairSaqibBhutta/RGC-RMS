class VisitPagination {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;

  VisitPagination.fromJson(Map<String, dynamic> json)
      : page = json['page'] ?? 1,
        limit = json['limit'] ?? 10,
        totalCount = json['totalCount'] ?? 0,
        totalPages = json['totalPages'] ?? 1;
}

class VisitReportModel {
  bool? status;
  VisitPagination? pagination;
  List<VisitData>? data;

  VisitReportModel({this.status, this.pagination, this.data});

  VisitReportModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    pagination = json['pagination'] != null
        ? VisitPagination.fromJson(json['pagination'])
        : null;
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
  List<CheckIn>? checkIn;
  String? createdAt;
  String? updatedAt;
  int? iV;
  CheckIn? checkOut;
  UserDetail? userDetail;

  VisitData({
    this.sId,
    this.userId,
    this.townPahse,
    this.block,
    this.site,
    this.gco,
    this.keyPN,
    this.keyPC,
    this.architect,
    this.callResult,
    this.checkIn,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.checkOut,
    this.userDetail,
  });

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

    if (json['checkIn'] != null) {
      checkIn = <CheckIn>[];
      json['checkIn'].forEach((v) {
        checkIn!.add(CheckIn.fromJson(v));
      });
    }

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];

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

    if (checkIn != null) {
      data['checkIn'] = checkIn!.map((v) => v.toJson()).toList();
    }

    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;

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
  String? sId;
  String? time;
  String? lat;
  String? long;

  CheckIn({
    this.sId,
    this.time,
    this.lat,
    this.long,
  });

  CheckIn.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    time = json['time'];
    lat = json['lat'];
    long = json['long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['time'] = time;
    data['lat'] = lat;
    data['long'] = long;
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

  UserDetail({
    this.name,
    this.email,
    this.role,
    this.status,
    this.company,
    this.region,
    this.area,
  });

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
