import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/bottom_nav_screen.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/main.dart';

import 'package:leadmanagementsystem/models/common_model.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/models/task_assigned_users_model.dart';

import 'package:leadmanagementsystem/models/workscope_model.dart';

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

  var myProjects = <ProjectData>[].obs;
  var assignedProjects = <ProjectData>[].obs;
  var teamProjects = <ProjectData>[].obs;
  var allProjects = <ProjectData>[];

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
    final filePick = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (filePick != null && filePick.files.isNotEmpty) {
      final pickedFile = filePick.files.first;
      filePath.value = pickedFile.path ?? '';
      fileName.value = pickedFile.name;

      log(" filePath.value = = ${filePath.value}");
    }
  }

  addWorkScope(WorkScopeModel workScopeModel) {
    workScope.add(workScopeModel);
  }

  Future<bool> getProjects(BuildContext? context) async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      alertDialogueWithLoader(context);
    });

    String url = '';

    // try {
    url =
        'getProject?role=${loginStorage.getUserRole()}&company=${loginStorage.getUserCompany()}&userId=${loginStorage.getUserId()}';

    print('url--->$url');

    final res = await getRequest.customGetRequest(apiPath: url);
    Navigator.pop(context!);
    isProjectLoadingClosed = true;

    if (res != null && res['status'] != false) {
      ProjectModel projectModel = ProjectModel.fromJson(res);
      // projectData.clear();

      var mProjects = projectModel.myProjects ?? [];
      var aProjects = projectModel.assignedProjects ?? [];
      var tProjects = projectModel.teamProjects ?? [];

      allProjects = [...mProjects, ...aProjects, ...tProjects];

      myProjects.value = sortProjectsByStatus(mProjects);
      assignedProjects.value = sortProjectsByStatus(aProjects);
      teamProjects.value = sortProjectsByStatus(tProjects);

      log("myProjects length = ${myProjects.length}");
      log("assignedProjects length = ${assignedProjects.length}");
      log("teamProjects length = ${teamProjects.length}");

      _categorizeProjects(myProjects);

      return true;
    } else {
      Get.snackbar('Error', 'Failed to fetch projects');
      return false;
    }
    // } catch (e) {
    //   // Get.snackbar('Error', 'Something went wrong. Please try again later.');
    //   return false;
    // }
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
        default:
          myProjects.add(project);
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

        customSnackBar('Success', 'Project uploaded successfully');

        await getProjects(context);
        clearProjectContsData();

        return true;
      } else {
        Get.snackbar('Failed', 'Project could not be added');
        return false;
      }
    } catch (err) {
      loading.value = false;
      // Get.snackbar('Error', 'Something went wrong. Please try again later.');
      return false;
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
      customSnackBar('Success', res["message"]);
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
        customSnackBar('Success', 'Project Status Updated');

        return true;
      } else {
        Get.snackbar("Error", model.message);
        return false;
      }
    } else {
      Get.snackbar("Error", "Some error occured");
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
      customSnackBar('Success', res["message"]);

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

    // Handle file upload
    if (existingFilePath != null) {
      request.fields['file'] = existingFilePath;
    } else {
      request.files
          .add(await http.MultipartFile.fromPath('file', filePath.value));
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
      customSnackBar('Success', 'Project Updated Successfully');

      Get.offAll(const BottomNavScreen());
    } else {
      Get.snackbar('Failed', 'Project Update Failed');
    }
  }
}

customSnackBar(String? title, String? msg) {
  return Get.snackbar(title!, msg!, backgroundColor: CupertinoColors.white);
}
