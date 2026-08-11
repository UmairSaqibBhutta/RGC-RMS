import 'package:leadmanagementsystem/models/project_model.dart';

class ProjectUpdateModel {
  bool? status;
  ProjectData? updateProjectData;

  ProjectUpdateModel({this.status, this.updateProjectData});

  ProjectUpdateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    updateProjectData =
        json['data'] != null ? ProjectData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (updateProjectData != null) {
      data['data'] = updateProjectData!.toJson();
    }
    return data;
  }
}
