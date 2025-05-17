class NotificationsModel {
  bool? status;
  List<NotificationData>? data;
  int? unreadCount;

  NotificationsModel({this.status, this.data, this.unreadCount});

  NotificationsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(NotificationData.fromJson(v));
      });
    }
    unreadCount = json['unreadCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['unreadCount'] = unreadCount;
    return data;
  }
}

class NotificationData {
  String? sId;
  String? senderId;
  String? senderName;
  String? projectId;
  String? type;
  List<String>? recieverId;
  String? comment;
  bool? isRead;
  String? createdDate;

  NotificationData({
    this.sId,
    this.senderId,
    this.senderName,
    this.projectId,
    this.type,
    this.recieverId,
    this.comment,
    this.isRead,
    this.createdDate,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'];
    senderName = json['senderName'];
    projectId = json['projectId'];
    type = json['type'];
    recieverId = json['recieverId'].cast<String>();
    comment = json['comment'];
    isRead = json['isRead'] ?? false;
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['senderId'] = senderId;
    data['senderName'] = senderName;
    data['projectId'] = projectId;
    data['type'] = type;
    data['recieverId'] = recieverId;
    data['comment'] = comment;
    data['isRead'] = isRead;
    data['createdDate'] = createdDate;
    return data;
  }
}
