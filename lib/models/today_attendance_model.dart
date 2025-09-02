class TodayAttendanceModel {
  bool? status;
  List<AttendanceData>? data;

  TodayAttendanceModel({this.status, this.data});

  TodayAttendanceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <AttendanceData>[];
      json['data'].forEach((v) {
        data!.add(AttendanceData.fromJson(v));
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

class AttendanceData {
  String? sId;
  String? userId;
  String? dateTime;
  String? attendanceType;
  String? location;
  String? lat;
  String? long;

  AttendanceData({
    this.sId,
    this.userId,
    this.dateTime,
    this.attendanceType,
    this.location,
    this.lat,
    this.long,
  });

  AttendanceData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    dateTime = json['dateTime'];
    attendanceType = json['attendanceType'];
    location = json['location'];
    lat = json['lat'] ?? "";
    long = json['long'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['dateTime'] = dateTime;
    data['attendanceType'] = attendanceType;
    data['location'] = location;
    data['lat'] = lat;
    data['long'] = long;
    return data;
  }
}
