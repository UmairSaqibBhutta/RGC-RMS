import 'package:leadmanagementsystem/models/project_model.dart';

class ProjectUpdateModel {
  bool? status;
  ProjectData? updateProjectData;

  ProjectUpdateModel({this.status, this.updateProjectData});

  ProjectUpdateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    updateProjectData = json['projectData'] != null
        ? ProjectData.fromJson(json[
            'projectData']) // Fixed: changed `projectData.fromJson` to `ProjectData.fromJson`
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (updateProjectData != null) {
      data['projectData'] = updateProjectData!.toJson();
    }
    return data;
  }
}
