class LeavesModel {
  bool? status;
  String? message;
  num? remainingLeaves;
  List<LeaveData>? data;

  LeavesModel({this.status, this.message, this.remainingLeaves, this.data});

  LeavesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    remainingLeaves = json['leaveQuota'] ?? 0;

    if (json['data'] != null) {
      data = <LeaveData>[];
      json['data'].forEach((v) {
        data!.add(LeaveData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['leaveQuota'] = remainingLeaves;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LeaveData {
  String? sId;
  String? userId;
  String? title;
  String? description;
  String? type;
  String? leaveStatus;
  List<String>? leaveDates; 
  String? createdAt;
  String? updatedAt;
  String? comment;
  String? leaveCreatedBy;
  String? leaveCreatorRole;
  String? updatedByName;
  String? updatedbyRole;
  String? updateUserId;

  LeaveData({
    this.sId,
    this.userId,
    this.title,
    this.description,
    this.type,
    this.leaveStatus,
    this.leaveDates,
    this.createdAt,
    this.updatedAt,
    this.comment,
    this.leaveCreatedBy,
    this.leaveCreatorRole,
    this.updatedByName,
    this.updatedbyRole,
    this.updateUserId,
  });

  LeaveData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    title = json['title'];
    description = json['description'];
    type = json['type'];
    leaveStatus = json['leaveStatus'] ?? "Pending";

    if (json['leaveDates'] != null) {
      leaveDates = List<String>.from(json['leaveDates']);
    } else {
      leaveDates = [];
    }

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    comment = json['comment'];
    leaveCreatedBy = json['leaveCreatedBy'];
    leaveCreatorRole = json['leaveCreateRole'];
    updatedByName = json['updatedByName'];
    updatedbyRole = json['updateRole'];
    updateUserId = json['updateUserId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['title'] = title;
    data['description'] = description;
    data['type'] = type;
    data['leaveStatus'] = leaveStatus;
    data['leaveDates'] = leaveDates ?? []; 
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['comment'] = comment;
    data['leaveCreatedBy'] = leaveCreatedBy;
    data['leaveCreateRole'] = leaveCreatorRole;
    data['updatedByName'] = updatedByName;
    data['updateRole'] = updatedbyRole;
    data['updateUserId'] = updateUserId;
    return data;
  }
}
