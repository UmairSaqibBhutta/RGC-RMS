import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/models/all_users_model.dart';
import 'package:leadmanagementsystem/models/get_project_by_user_id_model.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/models/task_and_projects_number_model.dart';
import 'package:leadmanagementsystem/projects/projects_list_page.dart';

import '../main.dart';

class ReportController extends GetxController {
  List<AllUsersData> usersData = [];
  List<AllUsersData> allUsersExceptCeo = [];
  List<ProjectData> projectsData = [];

  TasksNumberData? tasksNumberData;

  getAllUsersService() async {
    var res = await getRequest.customGetRequest(
        apiPath:
            'getAllUsers?role=${loginStorage.getUserRole()}&company=${loginStorage.getUserCompany()}');

    if (res['status'] != false) {
      AllUserModel allUserModel = AllUserModel.fromJson(res);

      usersData = allUserModel.data!;
      update();
    }
  }

    getAllUsersExceptCeo() async {
    var res = await getRequest.customGetRequest(
        apiPath:
            'getAllUserExceptCeo?role=${loginStorage.getUserRole()}&company=${loginStorage.getUserCompany()}');

    if (res['status'] != false) {
      AllUserModel allUserModel = AllUserModel.fromJson(res);

      allUsersExceptCeo = allUserModel.data!;
      update();
    }
  }

  getTasksNumberService(String? userId, BuildContext context) async {
    alertDialogueWithLoader(context);

    var res = await getRequest.customGetRequest(
        apiPath: 'getUserProjectsAndTaskLength/$userId');
    Navigator.pop(context);

    if (res['status'] != false) {
      TaskAndProjectsNumberModel taskAndProjectsNumberModel =
          TaskAndProjectsNumberModel.fromJson(res);

      tasksNumberData = taskAndProjectsNumberModel.data;

      update();
    }
  }

  getProjectData(BuildContext context, String userId) async {
    alertDialogueWithLoader(context);

    var res = await getRequest.customGetRequest(
        apiPath: 'getProjectsByUserId/$userId');
    Navigator.pop(context);

    if (res['status'] != false) {
      GetProjectByUserIdModel getProjectByUserIdModel =
          GetProjectByUserIdModel.fromJson(res);

      Get.to(ProjectListPage(
        findProjectsByUsers: true,
        userId: userId,
      ));
      projectsData = getProjectByUserIdModel.projectData!;
      update();
    }
  }
}
