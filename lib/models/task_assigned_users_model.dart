

/// model for users to whom this task is assigned
/// these users are fetched by task id
class ProjectOrTaskAssignedUsersModel {
  bool? status;
  List<Data>? data;

  ProjectOrTaskAssignedUsersModel({this.status, this.data});

  ProjectOrTaskAssignedUsersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  // String? sId;
  // String? senderUserId;
  // String? senderName;
  // List<String>? receiverUserIds;
  // String? taskId;
  // bool? assignStatus;
  // int? iV;
  List<Users>? users;

  Data(
      {
        // this.sId,
      // this.senderUserId,
      // this.senderName,
      // this.receiverUserIds,
      // this.taskId,
      // this.assignStatus,
      // this.iV,
      this.users});

  Data.fromJson(Map<String, dynamic> json) {
    // sId = json['_id'];
    // senderUserId = json['senderUserId'];
    // senderName = json['senderName'];
    // receiverUserIds = json['receiverUserIds'].cast<String>();
    // taskId = json['taskId'];
    // assignStatus = json['assignStatus'];
    // iV = json['__v'];
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['_id'] = sId;
    // data['senderUserId'] = senderUserId;
    // data['senderName'] = senderName;
    // data['receiverUserIds'] = receiverUserIds;
    // data['taskId'] = taskId;
    // data['assignStatus'] = assignStatus;
    // data['__v'] = iV;
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  String? sId;
  String? name;
  String? email;
  String? role;
  String? status;
  String? phone;
  String? company;
  String? region;
  String? area;


  Users(
      {this.sId,
      this.name,
      this.email,
      this.role,
      this.status,
      this.phone,
      this.company,
      this.region,
      this.area,
      });

  Users.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name']??"";
    email = json['email']??"";
    role = json['role']??"";
    status = json['status']??"";
    phone = json['phone']??"";
    company = json['company']??"";
    region = json['region']??"";
    area = json['area']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['role'] = role;
    data['status'] = status;
    data['phone'] = phone;
    data['company'] = company;
    data['region'] = region;
    data['area'] = area;
    return data;
  }
}
