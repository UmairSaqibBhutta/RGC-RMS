import 'dart:developer';

import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/models/update_project_model.dart';

class UpdateProjectController extends GetxController {
  ProjectUpdateModel? projectUpdateModel;
  bool isProjectDetailLoading = false;

  /// Fetches a single project's full details from the `project-detail/:id` API.
  Future<ProjectData?> getProjectById(String? projectId) async {
    if (projectId == null || projectId.isEmpty) return null;

    try {
      isProjectDetailLoading = true;
      update();

      final res = await getRequest.customGetRequest(
          apiPath: '${ApiUrls.getProjectDetail}/$projectId');

      log("📥 Project Detail Raw: $res");

      if (res == null || res['status'] != true || res['data'] == null) {
        projectUpdateModel = null;
        return null;
      }

      projectUpdateModel = ProjectUpdateModel.fromJson(res);
      return projectUpdateModel?.updateProjectData;
    } catch (e) {
      log("❌ getProjectById Exception: $e");
      projectUpdateModel = null;
      return null;
    } finally {
      isProjectDetailLoading = false;
      update();
    }
  }
}
