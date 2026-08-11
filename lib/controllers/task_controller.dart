import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/task_assigned_users_model.dart';
import 'package:leadmanagementsystem/models/tasks_model.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

class TaskController extends GetxController {
  RxBool loading = false.obs;

  RxList<TaskData> filteredTasksList = <TaskData>[].obs;
  RxList<TaskData> assignedTasksList = <TaskData>[].obs;

  /// if user select other in estimated time

  TextEditingController taskNameCont = TextEditingController();
  TextEditingController taskDescCont = TextEditingController();
  TextEditingController projectManagerCont = TextEditingController();
  TextEditingController timeDurationControl = TextEditingController();
  TextEditingController workForceControl = TextEditingController();
  TextEditingController locationControl = TextEditingController();
  TextEditingController notesControl = TextEditingController();
  TextEditingController contactPersonCont = TextEditingController();
  TextEditingController contactPersonPhoneCont = TextEditingController();
  TextEditingController contactPersonCompanyCont = TextEditingController();
  TextEditingController endDateCont = TextEditingController();

  RxString priority = ''.obs;
  // RxString status = ''.obs;
  RxString company = ''.obs;
  RxString filePath = ''.obs;
  RxString fileName = ''.obs;
  RxString estimatedTime = ''.obs;
  RxString taskDateTime = DateTime.now().toIso8601String().obs;
  RxString project = ''.obs;

  List<String> taskselectedUsers = [];

  bool assignmentLoader = false;
  bool isAssigneesLoaded = false;

  List<Users> taskAssignedUserList = [];
  // List<AssignedTaskData> assignedTaskList = [];

  Future<void> getTasks(String? userId) async {
    try {
      loading.value = true;

      var response = await getRequest.customGetRequest(
          apiPath: "getTaskById/${userId ?? loginStorage.getUserId()}");
      loading.value = false;

      if (response != null && response["status"] == true) {
        TasksModel model = TasksModel.fromJson(response);

        filteredTasksList.value = model.data;
        assignedTasksList.value = model.assignedTasks;

        update();
      } else {
        filteredTasksList.clear();
        assignedTasksList.clear();
        loading.value = false;
        update();
      }
    } catch (e) {
      filteredTasksList.clear();
      assignedTasksList.clear();

      loading.value = false;
      CustomSnackbar.error(e.toString());
      update();
    }
  }

  // Function to filter tasks based on search query
  // void searchTasks(String query) {
  //   if (query.isEmpty) {
  //     filteredTasksList.value = tasksList; // Show all tasks if query is empty
  //   } else {
  //     final lowerCaseQuery = query.toLowerCase();
  //     filteredTasksList.value = tasksList.where((task) {
  //       return task.title.toLowerCase().contains(lowerCaseQuery) ||
  //           task.description.toLowerCase().contains(lowerCaseQuery) ||
  //           task.projectName!.toLowerCase().contains(lowerCaseQuery);
  //     }).toList();
  //     update();
  //   }
  // }

  Future<void> addTask() async {
    // Check for required field validations
    if (taskNameCont.text.trim().isEmpty) {
      CustomSnackbar.error('Task title is required');
      return;
    }

    if (taskDescCont.text.trim().isEmpty) {
      CustomSnackbar.error('Task description is required');
      return;
    }

    if (project.value.isEmpty) {
      CustomSnackbar.error('Project selection is required');
      return;
    }

    if (priority.value.isEmpty) {
      CustomSnackbar.error('Priority selection is required');
      return;
    }

    if (estimatedTime.value.isEmpty) {
      CustomSnackbar.error('Estimated time is required');
      return;
    }

    http.MultipartRequest request =
        http.MultipartRequest('POST', Uri.parse('${baseUrl}addTask'));

    loading.value = true;

    log('Loading: ${loading.value}');
    log("taskDateTime.value = ${taskDateTime.value}");

    if (taskDateTime.value == '') {
      taskDateTime.value = DateTime.now().toIso8601String();
    }

    // return;
    Map<String, String> body = {
      'userId': loginStorage.getUserId()!,
      'title': taskNameCont.text.trim(),
      'description': taskDescCont.text.trim(),
      'projectName': project.value.trim(),
      'priority': priority.value.trim(),
      'status': "Not Started",
      'date': taskDateTime.value.trim(),
      'contactName': contactPersonCont.text.trim(),
      'contactPhone': contactPersonPhoneCont.text.trim(),
      'contactCompany': contactPersonCompanyCont.text.trim(),
      'estimatedDate': estimatedTime.value.trim(),
      'projectManager': projectManagerCont.text.trim(),
      'workForce': workForceControl.text.trim(),
    };

    log("body in add task = $body");

    request.fields.addAll(body);

    log("filePath.value = ${filePath.value}");

    if (filePath.value.isNotEmpty) {
      request.files
          .add(await http.MultipartFile.fromPath('fileData', filePath.value));
    }

    http.StreamedResponse response = await request.send();

    loading.value = false;

    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final responseData = json.decode(responseString);

      log('Response Code: ${response.statusCode}');
      log('Response Data: $responseData');

      CustomSnackbar.success('Task added successfully');
      clearAllFields();
      getTasks(null);
      Navigator.of(Get.context!).pop();
    } else {
      log('Response Code: ${response.statusCode}');
      log('Error: ${response.reasonPhrase}');

      CustomSnackbar.error("Please try again");
    }
  }

  Future<void> checkIn(Map body) async {
    log("body in checkIn = $body");
    try {
      loading.value = true;

      var response = await postRequest.customPostRequest(
          url: ApiUrls.taskCheckIn, body: body);
      loading.value = false;

      if (response != null && response["status"] == true) {
        CustomSnackbar.success('Task checked in successfully');
        getTasks(null);
        Navigator.of(Get.context!).pop();
      } else {
        loading.value = false;
        CustomSnackbar.error('Please try again');
      }
    } catch (e) {
      loading.value = false;
      CustomSnackbar.error(e.toString());
    }
  }

  Future<void> checkOut(Map body) async {
    log("body in checkOut = $body");
    try {
      loading.value = true;

      var response = await postRequest.customPostRequest(
          url: ApiUrls.taskCheckOut, body: body);
      loading.value = false;

      if (response != null && response["status"] == true) {
        CustomSnackbar.success('Task checked out successfully');
        getTasks(null);
        Navigator.of(Get.context!).pop();
      } else {
        loading.value = false;
        CustomSnackbar.error('Please try again');
      }
    } catch (e) {
      loading.value = false;
      CustomSnackbar.error(e.toString());
    }
  }

  assignTask(BuildContext context, Map body) async {
    log("body in assignTask $body");
    assignmentLoader = true;

    update();
    var res = await postRequest.customPostRequest(
        url: ApiUrls.assignTask, body: body);
    assignmentLoader = false;
    update();
    if (res['status'] == true) {
      CustomSnackbar.success(res["message"]);
      return true;
    } else {
      return false;
    }
  }

  getAssignedTaskUserList(String taskId, BuildContext context) async {
    // update();

    var res = await getRequest.customGetRequest(
        apiPath: '${ApiUrls.getAssignedTask}/$taskId');

    // update();
    if (res['status'] == true) {
      ProjectOrTaskAssignedUsersModel model =
          ProjectOrTaskAssignedUsersModel.fromJson(res);

      taskAssignedUserList = model.data?.first.users ?? [];
      taskselectedUsers.clear();
      for (var element in taskAssignedUserList) {
        taskselectedUsers.add(element.sId!);
      }
      isAssigneesLoaded = true;
    } else {
      taskAssignedUserList = [];
      isAssigneesLoaded = true;
    }

    update();
  }

  void clearAllFields() {
    // Clear all TextEditingController values
    taskNameCont.clear();
    taskDescCont.clear();
    projectManagerCont.clear();
    timeDurationControl.clear();
    workForceControl.clear();
    locationControl.clear();
    notesControl.clear();
    contactPersonCont.clear();
    contactPersonPhoneCont.clear();
    contactPersonCompanyCont.clear();
    endDateCont.clear();

    // Reset all RxString values
    priority.value = '';
    // status.value = '';
    company.value = '';
    filePath.value = '';
    fileName.value = '';
    estimatedTime.value = '';
  }
}
