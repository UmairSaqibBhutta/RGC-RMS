import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/bottom_nav_screen.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/main.dart';

import 'package:leadmanagementsystem/models/common_model.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/models/task_assigned_users_model.dart';

import 'package:leadmanagementsystem/models/workscope_model.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

class ProjectController extends GetxController {
  RxBool leadB = false.obs;
  RxBool contactedB = false.obs;
  RxBool pitchedB = false.obs;
  RxBool sentSampleB = false.obs;
  RxBool negotiatingB = false.obs;
  RxBool closeWonB = false.obs;
  RxBool closedLostB = false.obs;
  RxBool temporaryCloseB = false.obs;

  bool isProjectLoadingClosed = false;

  /// for assign project and update assignees
  bool isAssigneesLoaded = false;

  /// loader during project assignment
  bool assignmentLoader = false;

  /// list of user ids to whom this project will be / is assigned
  List<String> projectselectedUsers = [];

  /// users to whom this project is already assigned
  List<Users> projectAssignedUserList = [];

  var loading = false.obs;

  var workScope = <WorkScopeModel>[].obs;

  var myProjects = <ProjectCardModel>[].obs;
  var assignedProjects = <ProjectCardModel>[].obs;
  var teamProjects = <ProjectCardModel>[].obs;
  var allProjects = <ProjectData>[];

  // Genuine counts from API (not affected by pagination)
  var myProjectsCount = 0.obs;
  var assignedProjectsCount = 0.obs;
  var teamProjectsCount = 0.obs;

  // Pagination tracking per tab
  int _myProjectsPage = 1;
  int _assignedProjectsPage = 1;
  int _teamProjectsPage = 1;

  int _myProjectsTotalPages = 1;
  int _assignedProjectsTotalPages = 0;
  int _teamProjectsTotalPages = 1;

  var isLoadingMoreMyProjects = false.obs;
  var isLoadingMoreAssigned = false.obs;
  var isLoadingMoreTeam = false.obs;

  var lead = <ProjectData>[].obs;
  var contacted = <ProjectData>[].obs;
  var pitched = <ProjectData>[].obs;
  var sentSample = <ProjectData>[].obs;
  var negotiating = <ProjectData>[].obs;
  var closeWon = <ProjectData>[].obs;
  var closedLost = <ProjectData>[].obs;
  var temporaryClose = <ProjectData>[].obs;

  final TextEditingController projectNameControl = TextEditingController();
  final TextEditingController clientNameControl = TextEditingController();
  final TextEditingController descriptionControl = TextEditingController();
  final TextEditingController projectManagerCont = TextEditingController();
  final TextEditingController timeDurationControl = TextEditingController();
  final TextEditingController workForceControl = TextEditingController();
  final TextEditingController budgetCont = TextEditingController();
  final TextEditingController tentativeCostCont = TextEditingController();
  final TextEditingController locationCont = TextEditingController();
  final TextEditingController notesCont = TextEditingController();
  final TextEditingController contactPersonPhoneCont = TextEditingController();
  final TextEditingController contactPersonNameCont = TextEditingController();

  final TextEditingController consultReControl = TextEditingController();
  final TextEditingController consultMeControl = TextEditingController();

  final TextEditingController consultNameCont = TextEditingController();
  final TextEditingController consultReNameCont = TextEditingController();
  final TextEditingController consultRePhoneCont = TextEditingController();
  final TextEditingController consultantMeNameCont = TextEditingController();
  final TextEditingController consultantMePhoneCont = TextEditingController();

  final TextEditingController contractorNameCont = TextEditingController();

  final TextEditingController contractorReControl = TextEditingController();
  final TextEditingController contractorReNameCont = TextEditingController();
  final TextEditingController contractorRePhoneCont = TextEditingController();
  final TextEditingController contractorMeControl = TextEditingController();
  final TextEditingController contractorMeNameCont = TextEditingController();
  final TextEditingController contractorMePhoneCont = TextEditingController();

  final TextEditingController precurementNameCont = TextEditingController();
  final TextEditingController precurementPhoneCont = TextEditingController();

  final TextEditingController accountNameCont = TextEditingController();
  final TextEditingController accountPhoneCont = TextEditingController();

  final TextEditingController projectOwnerNameControl = TextEditingController();
  final TextEditingController projectOwnerMeControl = TextEditingController();
  final TextEditingController projectOwnerPhoneControl =
      TextEditingController();
  final TextEditingController productPriceCont = TextEditingController();

  var priority = ''.obs;
  var company = ''.obs;
  var filePath = ''.obs; //this
  var fileName = ''.obs;

  Future<void> addFileFunction() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        filePath.value = pickedImage.path;
        fileName.value = pickedImage.name;

        log(" filePath.value = = ${filePath.value}");
      }
    } catch (e) {
      log("error in addFileFunction = ${e.toString()}");
      CustomSnackbar.error('Could not access the camera: $e');
    }
  }

  addWorkScope(WorkScopeModel workScopeModel) {
    workScope.add(workScopeModel);
  }

  Future<bool> getProjects(BuildContext? context) async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      alertDialogueWithLoader(context);
    });

    // Reset pagination to page 1
    _myProjectsPage = 1;
    _assignedProjectsPage = 1;
    _teamProjectsPage = 1;

    final url =
        'getProject?role=${loginStorage.getUserRole()}&company=${loginStorage.getUserCompany()}&userId=${loginStorage.getUserId()}&page=1&limit=10';

    final res = await getRequest.customGetRequest(apiPath: url);
    Navigator.pop(context!);
    isProjectLoadingClosed = true;

    if (res != null && res['status'] != false) {
      final projectModel = ProjectModel.fromJson(res);

      // Store pagination totals
      if (projectModel.pagination != null) {
        _myProjectsTotalPages = projectModel.pagination!.myProjectsTotalPages;
        _assignedProjectsTotalPages =
            projectModel.pagination!.assignProjectsTotalPages;
        _teamProjectsTotalPages =
            projectModel.pagination!.teamProjectsTotalPages;
      }

      // Store genuine counts from API
      if (projectModel.counts != null) {
        myProjectsCount.value = projectModel.counts!.myProjectsCount;
        assignedProjectsCount.value = projectModel.counts!.assignProjectsCount;
        teamProjectsCount.value = projectModel.counts!.teamProjectsCount;
      }

      final mProjects = projectModel.myProjects ?? [];
      final aProjects = projectModel.assignedProjects ?? [];
      final tProjects = projectModel.teamProjects ?? [];

      allProjects = [...mProjects, ...aProjects, ...tProjects];

      final sortedMyProjects = sortProjectsByStatus(mProjects);
      myProjects.value = sortedMyProjects
          .map((e) => ProjectCardModel.fromProjectData(e))
          .toList();
      assignedProjects.value = sortProjectsByStatus(aProjects)
          .map((e) => ProjectCardModel.fromProjectData(e))
          .toList();
      teamProjects.value = sortProjectsByStatus(tProjects)
          .map((e) => ProjectCardModel.fromProjectData(e))
          .toList();

      log("myProjects length = ${myProjects.length}, total = ${myProjectsCount.value}");
      log("assignedProjects length = ${assignedProjects.length}, total = ${assignedProjectsCount.value}");
      log("teamProjects length = ${teamProjects.length}, total = ${teamProjectsCount.value}");

      _categorizeProjects(sortedMyProjects);

      return true;
    } else {
      CustomSnackbar.error('Failed to fetch projects');
      return false;
    }
  }

  /// Per-status project counts for the home screen pie chart, from
  /// `getProjectStatusCounts/:userId` — computed server-side across the
  /// user's whole portfolio, unlike [myProjects]/[assignedProjects]/
  /// [teamProjects] which only ever hold one paginated page.
  var projectStatusCounts = <String, int>{}.obs;

  Future<void> getProjectStatusCounts() async {
    final res = await getRequest.customGetRequest(
      apiPath:
          '${ApiUrls.getProjectStatusCounts}/${loginStorage.getUserId()}',
    );

    if (res != null && res['status'] != false) {
      projectStatusCounts.value =
          ProjectStatusCountsModel.fromJson(res).data;
    } else {
      log('getProjectStatusCounts failed: $res');
    }
  }

  /// Debug-only: permanently deletes a project via `delete-project/:id` and
  /// removes it from [myProjects]/[assignedProjects]/[teamProjects]/
  /// [allProjects] so every screen watching those reactive lists updates
  /// immediately. See [DebugDeleteProjectTile].
  Future<bool> deleteProject(String projectId) async {
    final res = await postRequest.customPostRequest(
      url: '${ApiUrls.deleteProject}/$projectId',
      body: {},
    );

    final message = res?['message'];
    final messageText =
        message is String && message.isNotEmpty ? message : null;

    if (res != null && res['status'] != false) {
      myProjects.removeWhere((p) => p.sId == projectId);
      assignedProjects.removeWhere((p) => p.sId == projectId);
      teamProjects.removeWhere((p) => p.sId == projectId);
      allProjects.removeWhere((p) => p.sId == projectId);
      CustomSnackbar.success(messageText ?? 'Project deleted');
      return true;
    } else {
      CustomSnackbar.error(messageText ?? 'Failed to delete project');
      return false;
    }
  }

  Future<void> loadMoreProjects(String type) async {
    int page;

    if (type == 'my') {
      if (_myProjectsPage >= _myProjectsTotalPages ||
          isLoadingMoreMyProjects.value) {
        return;
      }
      _myProjectsPage++;
      isLoadingMoreMyProjects.value = true;
      page = _myProjectsPage;
    } else if (type == 'assigned') {
      if (_assignedProjectsPage >= _assignedProjectsTotalPages ||
          isLoadingMoreAssigned.value) {
        return;
      }
      _assignedProjectsPage++;
      isLoadingMoreAssigned.value = true;
      page = _assignedProjectsPage;
    } else {
      if (_teamProjectsPage >= _teamProjectsTotalPages ||
          isLoadingMoreTeam.value) {
        return;
      }
      _teamProjectsPage++;
      isLoadingMoreTeam.value = true;
      page = _teamProjectsPage;
    }

    final url =
        'getProject?role=${loginStorage.getUserRole()}&company=${loginStorage.getUserCompany()}&userId=${loginStorage.getUserId()}&page=$page&limit=10';

    final res = await getRequest.customGetRequest(apiPath: url);

    if (res != null && res['status'] != false) {
      final projectModel = ProjectModel.fromJson(res);

      if (type == 'my') {
        final mProjects = projectModel.myProjects ?? [];
        final sorted = sortProjectsByStatus(mProjects);
        myProjects
            .addAll(sorted.map((e) => ProjectCardModel.fromProjectData(e)));
        allProjects = [...allProjects, ...mProjects];
        isLoadingMoreMyProjects.value = false;
      } else if (type == 'assigned') {
        final aProjects = projectModel.assignedProjects ?? [];
        final sorted = sortProjectsByStatus(aProjects);
        assignedProjects
            .addAll(sorted.map((e) => ProjectCardModel.fromProjectData(e)));
        allProjects = [...allProjects, ...aProjects];
        isLoadingMoreAssigned.value = false;
      } else {
        final tProjects = projectModel.teamProjects ?? [];
        final sorted = sortProjectsByStatus(tProjects);
        teamProjects
            .addAll(sorted.map((e) => ProjectCardModel.fromProjectData(e)));
        allProjects = [...allProjects, ...tProjects];
        isLoadingMoreTeam.value = false;
      }
    } else {
      // Revert page on failure
      if (type == 'my') {
        _myProjectsPage--;
        isLoadingMoreMyProjects.value = false;
      } else if (type == 'assigned') {
        _assignedProjectsPage--;
        isLoadingMoreAssigned.value = false;
      } else {
        _teamProjectsPage--;
        isLoadingMoreTeam.value = false;
      }
    }
  }

  List<ProjectData> sortProjectsByStatus(List<ProjectData> projects) {
    const List<String> statusOrder = [
      'Lead',
      'Pitched',
      'Contacted',
      'Sent Sample',
      'Negotiating',
      'Closed-Won',
      'Closed-Lost',
      'Temporary Close',
    ];

    final Map<String, int> orderMap = {
      for (int i = 0; i < statusOrder.length; i++) statusOrder[i]: i
    };

    projects.sort((a, b) {
      final aIndex = orderMap[a.status] ?? statusOrder.length;
      final bIndex = orderMap[b.status] ?? statusOrder.length;
      return aIndex.compareTo(bIndex);
    });

    return projects;
  }

  void _categorizeProjects(List<ProjectData> projects) {
    lead.clear();
    contacted.clear();
    pitched.clear();
    sentSample.clear();
    negotiating.clear();
    closeWon.clear();
    closedLost.clear();
    temporaryClose.clear();

    for (var project in projects) {
      switch (project.status) {
        case 'Lead':
          lead.add(project);
          break;
        case 'Contacted':
          contacted.add(project);
          break;
        case 'Pitched':
          pitched.add(project);
          break;
        case 'Sent Sample':
          sentSample.add(project);
          break;
        case 'Negotiating':
          negotiating.add(project);
          break;
        case 'Closed-Won':
          closeWon.add(project);
          break;
        case 'Closed-Lost':
          closedLost.add(project);
          break;
        case 'Temporary Close':
          temporaryClose.add(project);
          break;
      }
    }
  }

  Future<bool> addProject(BuildContext context) async {
    try {
      loading.value = true;

      final multipartRequest = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}addProject'),
      );

      multipartRequest.fields.addAll({
        'userId': loginStorage.getUserId().toString(),
        'name': projectNameControl.text,
        'consultName': consultReControl.text,
        'consultPhone': consultMeControl.text,
        'ownerMe': projectOwnerMeControl.text,
        'ownerName': projectOwnerNameControl.text,
        'ownerContact': projectOwnerPhoneControl.text,
        'title': projectNameControl.text,
        'description': descriptionControl.text,
        'projectManager': projectManagerCont.text,
        'duration': timeDurationControl.text,
        'workForce': workForceControl.text,
        'budget': budgetCont.text,
        'tentativeCode': tentativeCostCont.text,
        'location': locationCont.text.trim(),
        'notes': notesCont.text.trim(),
        'status': 'Lead',
        'role': loginStorage.getUserRole().toString(),
        "company": company.value.toString().trim(),
        'personName': contactPersonNameCont.text.trim(),
        'clientName': clientNameControl.text.trim(),
        'personContacts': contactPersonPhoneCont.text.trim(),
        'contractorName': contractorNameCont.text.trim(),
        'contractorREName': contractorReNameCont.text.trim(),
        'contractorREPhone': contractorRePhoneCont.text.trim(),
        'contractorMEName': contractorMeNameCont.text.trim(),
        'contractorMEPhone': contractorMePhoneCont.text.trim(),
        'consultantName': consultNameCont.text.trim(),
        'consultantREName': consultReNameCont.text.trim(),
        'consultantREPhone': consultRePhoneCont.text.trim(),
        'consultantMEName': consultantMeNameCont.text.trim(),
        'consultantMEPhone': consultantMePhoneCont.text.trim(),
        'precourmentName': precurementNameCont.text.trim(),
        'precourmentPhone': precurementPhoneCont.text.trim(),
        'accountOfficerName': accountNameCont.text.trim(),
        'accountOfficerPhone': accountPhoneCont.text.trim(),
        'priceValue': productPriceCont.text.trim(),
        'projectCreatedDate': DateTime.now().toIso8601String(),
        'workScope':
            jsonEncode(workScope.map((element) => element.toJson()).toList()),
        'projectPriority': priority.value,
      });

      if (filePath.value.isNotEmpty) {
        multipartRequest.files
            .add(await http.MultipartFile.fromPath('file', filePath.value));
      }

      final streamedResponse = await multipartRequest.send();

      loading.value = false;
      var body = await streamedResponse.stream.bytesToString();
      log("responce = $body");
      if (streamedResponse.statusCode == 201) {
        print('statusCode--->${streamedResponse.statusCode}');

        CustomSnackbar.success('Project uploaded successfully');

        await getProjects(context);
        clearProjectContsData();

        return true;
      } else {
        CustomSnackbar.error('Project could not be added');
        return false;
      }
    } catch (err) {
      loading.value = false;
      // Get.snackbar('Error', 'Something went wrong. Please try again later.');
      return false;
    }
  }

  /// loader for the "add follow up" action on the project details screen
  bool followUpLoader = false;

  /// Adds a follow up note (with an optional image) to a project via
  /// `/follow-up-project`.
  Future<bool> addProjectFollowUp({
    required String projectId,
    required String text,
    File? image,
  }) async {
    try {
      followUpLoader = true;
      update();

      final res = await postRequest.customMultipartPost(
        url: ApiUrls.followUpProject,
        fields: {
          'user_id': loginStorage.getUserId() ?? '',
          'project_id': projectId,
          'text': text,
        },
        file: image,
      );

      if (res == null) {
        CustomSnackbar.error('No response from server');
        return false;
      }

      if (res['status'] == false || res['success'] == false) {
        CustomSnackbar.error(res['message'] ?? 'Failed to add follow up');
        return false;
      }

      CustomSnackbar.success(res['message'] ?? 'Follow up added successfully');
      return true;
    } catch (err) {
      log('addProjectFollowUp error: $err');
      CustomSnackbar.error('Something went wrong. Please try again later.');
      return false;
    } finally {
      followUpLoader = false;
      update();
    }
  }

  getAssignedProjectUserList(String projectId, BuildContext context) async {
    // update();
    try {
      var res = await getRequest.customGetRequest(
          apiPath: '${ApiUrls.getAssignProjects}/$projectId');

      // update();
      if (res['status'] == true) {
        ProjectOrTaskAssignedUsersModel model =
            ProjectOrTaskAssignedUsersModel.fromJson(res);

        projectAssignedUserList = model.data?.first.users ?? [];
        projectselectedUsers.clear();
        for (var element in projectAssignedUserList) {
          projectselectedUsers.add(element.sId!);
        }
        isAssigneesLoaded = true;
      } else {
        projectAssignedUserList = [];
        isAssigneesLoaded = true;
      }

      update();
    } catch (error, stack) {
      projectAssignedUserList = [];
      isAssigneesLoaded = true;
      update();
      FirebaseCrashlytics.instance.recordError(error, stack,
          fatal: true, reason: "Getting assigned project user list failed");
    }
  }

  Future<bool> assignProject(BuildContext context, Map body) async {
    log("body in assignProject $body");
    assignmentLoader = true;

    update();
    var res = await postRequest.customPostRequest(
        url: ApiUrls.assignProject, body: body);
    assignmentLoader = false;
    update();
    if (res['status'] == true) {
      CustomSnackbar.success(res["message"]);
      return true;
    } else {
      return false;
    }
  }

  // Method to clear all project-related data and reset controllers
  void clearProjectContsData() {
    // Clear TextEditingControllers
    projectNameControl.clear();
    descriptionControl.clear();
    projectManagerCont.clear();
    timeDurationControl.clear();
    workForceControl.clear();
    budgetCont.clear();
    tentativeCostCont.clear();
    locationCont.clear();
    notesCont.clear();
    contactPersonPhoneCont.clear();
    contactPersonNameCont.clear();

    // Clear Observable Strings
    priority.value = '';
    company.value = '';
    filePath.value = '';
    fileName.value = '';

    // Clear Observable Lists
    // projectData.clear();
    // lead.clear();
    // contacted.clear();
    // pitched.clear();
    // sentSample.clear();
    // negotiating.clear();
    // closeWon.clear();
    // closedLost.clear();

    // Reset the Boolean Observables
    // leadB.value = false;
    // contactedB.value = false;
    // pitchedB.value = false;
    // sentSampleB.value = false;
    // negotiatingB.value = false;
    // closeWonB.value = false;
    // closedLostB.value = false;

    // Reset loading state
    loading.value = false;
  }

  Future<bool> updateProjectStatus(Map body) async {
    log("body = $body");
    var responce = await postRequest.customPostRequest(
        url: ApiUrls.updateProjectStatus, body: body);

    if (responce != null) {
      CommonResponse model = CommonResponse.fromJson(responce);

      if (model.status) {
        CustomSnackbar.success('Project Status Updated');

        return true;
      } else {
        CustomSnackbar.error(model.message);
        return false;
      }
    } else {
      CustomSnackbar.error("Some error occured");
      return false;
    }
  }

  assignTaskOrProject(BuildContext context, Map body) async {
    assignmentLoader = true;

    update();

    var res =
        await postRequest.customPostRequest(url: 'assignProject', body: body);

    assignmentLoader = false;

    update();

    if (res['status'] == true) {
      CustomSnackbar.success(res["message"]);

      return true;
    } else {
      return false;
    }
  }

  updateProjectFunction(String? existingFilePath, String? id) async {
    assignmentLoader = true;
    update();

    // Create the multipart request
    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse('${baseUrl}updateProject'));

    // Add fields to the request
    request.fields.addAll({
      'id': id!,
      'name': projectNameControl.text,
      'consultName': consultReControl.text,
      'consultPhone': consultMeControl.text,
      'ownerMe': projectOwnerMeControl.text,
      'ownerName': projectOwnerNameControl.text,
      'ownerContact': projectOwnerPhoneControl.text,
      'title': projectNameControl.text,
      'description': descriptionControl.text,
      'projectManager': projectManagerCont.text,
      'duration': timeDurationControl.text,
      'workForce': workForceControl.text,
      'budget': budgetCont.text,
      'company': company.value.toString(),
      'tentativeCode': tentativeCostCont.text,
      'location': locationCont.text,
      'notes': notesCont.text,
      'status': 'Lead',
      'personName': contactPersonNameCont.text,
      'clientName': clientNameControl.text,
      'personContacts': contactPersonPhoneCont.text,
      'contractorName': contractorNameCont.text,
      'contractorREName': contractorReNameCont.text,
      'contractorREPhone': contractorRePhoneCont.text,
      'contractorMEName': contractorMeNameCont.text,
      'contractorMEPhone': contractorMePhoneCont.text,
      'consultantName': consultNameCont.text,
      'consultantREName': consultReNameCont.text,
      'consultantREPhone': consultRePhoneCont.text,
      'consultantMEName': consultantMeNameCont.text,
      'consultantMEPhone': consultantMePhoneCont.text,
      'precourmentName': precurementNameCont.text,
      'precourmentPhone': precurementPhoneCont.text,
      'accountOfficerName': accountNameCont.text,
      'accountOfficerPhone': accountPhoneCont.text,
      'priceValue': productPriceCont.text,
      'workScope':
          jsonEncode(workScope.map((element) => element.toJson()).toList()),
      'projectPriority': priority.value,
    });

    // Handle file upload: prefer a newly picked file, otherwise keep the existing one
    if (filePath.value.isNotEmpty) {
      request.files
          .add(await http.MultipartFile.fromPath('file', filePath.value));
    } else if (existingFilePath != null && existingFilePath.isNotEmpty) {
      request.fields['file'] = existingFilePath;
    }

    // Send the request
    var response = await request.send();

    // Read the response body
    var responseBody = await response.stream.bytesToString();

    assignmentLoader = false;
    update();

    // Print the response body for debugging
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: $responseBody');

    // getProjects(context as BuildContext?);
    // Handle the response
    if (response.statusCode == 200) {
      CustomSnackbar.success('Project Updated Successfully');

      Get.offAll(const BottomNavScreen());
    } else {
      CustomSnackbar.error('Project Update Failed');
    }
  }
}
