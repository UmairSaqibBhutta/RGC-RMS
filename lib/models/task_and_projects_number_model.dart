class TaskAndProjectsNumberModel {
  bool? status;
  TasksNumberData? data;

  TaskAndProjectsNumberModel({this.status, this.data});

  TaskAndProjectsNumberModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? TasksNumberData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class TasksNumberData {
  int? taskNumber;
  int? projectsNumber;

  TasksNumberData({this.taskNumber, this.projectsNumber});

  TasksNumberData.fromJson(Map<String, dynamic> json) {
    taskNumber = json['taskNumber'];
    projectsNumber = json['projectsNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['taskNumber'] = taskNumber;
    data['projectsNumber'] = projectsNumber;
    return data;
  }
}
