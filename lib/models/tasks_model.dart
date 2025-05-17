class TasksModel {
  bool status;
  List<TaskData> data;
  List<TaskData> assignedTasks;

  TasksModel(
      {required this.status, required this.data, required this.assignedTasks});

  factory TasksModel.fromJson(Map<String, dynamic> json) => TasksModel(
        status: json["status"],
        data:
            List<TaskData>.from(json["data"].map((x) => TaskData.fromJson(x))),
        assignedTasks: List<TaskData>.from(
            json["assignTasks"].map((x) => TaskData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "assignTasks": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class TaskData {
  String id;
  String title;
  String description;
  String? projectName;
  String? taskDateTime;
  String? startTime;
  String? location;
  String? checkOutLocation;
  String? endTime;
  String? priority;
  String? status;
  String? contactPersonName;
  String? contactPersonPhone;
  String? contactPersonCompany;
  String? file;
  String? estimatedDate;
  String? userId;
  String? creatorName;
  String? creatorRole;

  TaskData(
      {required this.id,
      required this.title,
      required this.description,
      this.projectName,
      this.taskDateTime,
      this.location,
      this.checkOutLocation,
      this.startTime,
      this.endTime,
      this.priority,
      this.status,
      this.contactPersonName,
      this.contactPersonPhone,
      this.contactPersonCompany,
      this.file,
      this.estimatedDate,
      this.userId,
      this.creatorName,
      this.creatorRole});

  factory TaskData.fromJson(Map<String, dynamic> json) => TaskData(
      id: json["_id"],
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      projectName: json["projectName"] ?? "",
      taskDateTime: json["date"] ?? "",
      startTime: json["startTime"],
      checkOutLocation: json["checkOutLocation"] ?? "",
      location: json["location"] ?? "",
      endTime: json["endTime"],
      priority: json["priority"] ?? "",
      status: json["status"] ?? "",
      contactPersonName: json["contactName"] ?? "",
      contactPersonPhone: json["contactPhone"] ?? "",
      contactPersonCompany: json["contactCompany"] ?? "",
      file: json["file"] ?? "",
      estimatedDate: json["estimatedDate"] ?? "",
      userId: json["userId"],
      creatorName: json['creatorName'],
      creatorRole: json['creatorRole']);

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "description": description,
        "projectName": projectName,
        "date": taskDateTime,
        "startTime": startTime,
        "location": location,
        "endTime": endTime,
        "priority": priority,
        "checkOutLocation": checkOutLocation,
        "status": status,
        "contactName": contactPersonName,
        "contactPhone": contactPersonPhone,
        "contactCompany": contactPersonCompany,
        "file": file,
        "estimatedDate": estimatedDate,
        "userId": userId,
        'creatorName': creatorName,
        'creatorRole': creatorRole
      };
}
