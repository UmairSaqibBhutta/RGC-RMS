import 'package:leadmanagementsystem/models/project_model.dart';

class GetProjectByUserIdModel {
  bool? status;
  List<ProjectData>? projectData;

  GetProjectByUserIdModel({this.status, this.projectData});

  GetProjectByUserIdModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['projectData'] != null) {
      projectData = <ProjectData>[];
      json['projectData'].forEach((v) {
        projectData!.add(ProjectData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (projectData != null) {
      data['projectData'] = projectData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
