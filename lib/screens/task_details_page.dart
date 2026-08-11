import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/controllers/task_controller.dart';
import 'package:leadmanagementsystem/extensions/string_extensions.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/tasks_model.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/data_formatter.dart';
import 'package:location/location.dart' as loc;
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:url_launcher/url_launcher.dart';

import 'login_screen.dart';

class TaskDetailPage extends StatefulWidget {
  final TaskData task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final taskCont = Get.find<TaskController>();
  final loginController = Get.find<LoginController>();

  final projectCont = Get.find<ProjectController>();

  loc.Location? location;

  bool _serviceEnabled = false;
  loc.PermissionStatus? _permissionGranted;
  loc.LocationData? _locationData;

  /// user details to whom task will be assigned
  String? workerName;
  String? workerRole;
  String? recieverId;

  String? workerFCMToken;

  /// list of users to assign task.

  @override
  void initState() {
    super.initState();
    // Initialize the location object
    location = loc.Location();
    taskCont.getAssignedTaskUserList(widget.task.id, context);

    if (loginStorage.getUserRole() != UserRole.NEW_RECRUITS) {
      loginController.getMyAssignableUsers();
    }
  }

  @override
  dispose() {
    super.dispose();

    taskCont.taskselectedUsers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Task Details"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GetBuilder<TaskController>(
              init: taskCont,
              builder: (taskCont) {
                if (!taskCont.isAssigneesLoaded) {
                  return showSpinkit();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: GetBuilder<LoginController>(
                      init: loginController,
                      builder: (controller) {
                        log("Pre-selected Users: ${taskCont.taskselectedUsers}");

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: MultiSelectDialogField(
                            // ✅ Ensure initial value is a list of valid user IDs
                            initialValue:
                                List<String>.from(taskCont.taskselectedUsers),

                            isDismissible: true,
                            dialogHeight: Get.height * .5,
                            searchable: true,
                            searchHint: "Search",
                            items: controller.assignableUsersList
                                .where(
                                    (e) => loginStorage.getUserName() != e.name)
                                .map((e) => MultiSelectItem<String>(
                                    e.sId!, "${e.name} - ${e.role}"))
                                .toList(),
                            title: const Text("Assign Task To"),
                            selectedColor: appColor,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.black45, width: 1),
                            ),
                            buttonIcon: const Icon(
                              CupertinoIcons.chevron_down,
                              color: Colors.black54,
                            ),
                            buttonText: const Text(
                                "Select Users to assign task",
                                style: TextStyle(color: Colors.black54)),

                            onConfirm: (values) async {
                              log("Selected Users: $values");

                              // ✅ Prevent duplicate selections
                              taskCont.taskselectedUsers.clear();
                              taskCont.taskselectedUsers.addAll(values);

                              taskCont.update(); // ✅ Refresh UI

                              Map<String, dynamic> body = {
                                'senderUserId': loginStorage.getUserId(),
                                'senderName': loginStorage.getUserName(),
                                'receiverUserIds': taskCont.taskselectedUsers,
                                'taskId': widget.task.id,
                                'assignStatus': true,
                              };

                              log("Assigning Task to: $body");
                              await taskCont.assignTask(context, body);

                              await taskCont.getAssignedTaskUserList(
                                  widget.task.id,
                                  context); // ✅ Ensure assigned users reload
                            },
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            _buildTimelineHeader(context, widget.task.title),
            _buildTimelineItem(context, CupertinoIcons.text_quote,
                'Description', widget.task.description),
            if (widget.task.projectName.isNotNullOrEmpty)
              _buildTimelineItem(context, CupertinoIcons.briefcase,
                  'Project Name', widget.task.projectName!),


                   if (widget.task.creatorName.isNotNullOrEmpty && widget.task.creatorRole.isNotNullOrEmpty)
              _buildTimelineItem(context, CupertinoIcons.person,
                  'Task created by', "${widget.task.creatorName!} - ${widget.task.creatorRole}"),
            if (widget.task.priority.isNotNullOrEmpty)
              _buildTimelineItem(context, CupertinoIcons.exclamationmark_circle,
                  'Priority', widget.task.priority!),
            if (widget.task.status.isNotNullOrEmpty)
              _buildTimelineItem(
                  context, CupertinoIcons.flag, 'Status', widget.task.status!),
            if (widget.task.taskDateTime.isNotNullOrEmpty)
              _buildTimelineItem(
                  context,
                  CupertinoIcons.calendar,
                  'Task Date Time',
                  DateFormatter.formatDateTime(widget.task.taskDateTime!)),
            if (widget.task.estimatedDate.isNotNullOrEmpty)
              _buildTimelineItem(context, CupertinoIcons.time, 'Estimated Time',
                  widget.task.estimatedDate!),
            if (widget.task.contactPersonName.isNotNullOrEmpty)
              _buildTimelineItem(context, CupertinoIcons.person,
                  'Contact Person', widget.task.contactPersonName!),
            if (widget.task.contactPersonPhone.isNotNullOrEmpty)
              _buildTimelineItem(context, CupertinoIcons.phone, 'Contact Phone',
                  widget.task.contactPersonPhone!),
            if (widget.task.contactPersonCompany.isNotNullOrEmpty)
              _buildTimelineItem(context, CupertinoIcons.building_2_fill,
                  'Contact Company', widget.task.contactPersonCompany!),
            if (widget.task.startTime.isNotNullOrEmpty)
              _buildTimelineItem(
                  context,
                  CupertinoIcons.clock,
                  'Task Started at',
                  DateFormatter.formatDateTime(widget.task.startTime!)),
            if (widget.task.endTime != null && widget.task.endTime != "")
              _buildTimelineItem(
                  context,
                  CupertinoIcons.clock_fill,
                  'Task Completed at',
                  DateFormatter.formatDateTime(widget.task.endTime!)),
            if (widget.task.file != null && widget.task.file!.isNotEmpty)
              _buildFileCard(context, widget.task.file!),
            if (widget.task.location != null && widget.task.location != "")
              _buildTimelineItem(context, CupertinoIcons.location, 'Location',
                  widget.task.location.toString()),
            if (widget.task.checkOutLocation != null &&
                widget.task.checkOutLocation != "")
              _buildTimelineItem(context, CupertinoIcons.location,
                  'Checkout Location', widget.task.checkOutLocation.toString()),
            const SizedBox(height: 20),
            Obx(() {
              if (widget.task.startTime == null) {
                return CustomButton(
                  title: "Check in",
                  onTap: () => checkIn(),
                  child: taskCont.loading.value ? customCircleLoader() : null,
                );
              } else if (widget.task.endTime == null) {
                return CustomButton(
                  title: "Check Out",
                  onTap: () => checkOut(),
                  child: taskCont.loading.value ? customCircleLoader() : null,
                );
              } else {
                return CustomButton(
                  title: "Completed",
                  child: taskCont.loading.value ? customCircleLoader() : null,
                );
              }
            })
          ],
        ).animate().untint().scale().move(delay: 300.ms, duration: 600.ms),
      ),
    );
  }

  Widget _buildTimelineHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(CupertinoIcons.checkmark_alt_circle,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            ),
            Container(
              width: 2,
              height: 50,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 20.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileCard(BuildContext context, String filePath) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.doc_text,
                  color: Colors.blue, size: 20),
            ),
            Container(
              width: 2,
              height: 20,
              color: Theme.of(context).primaryColor.withOpacity(0.5),
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: GestureDetector(
            onTap: () => _downloadFile(filePath),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: ListTile(
                leading: const Icon(CupertinoIcons.cloud_download,
                    color: Colors.blue),
                title: const Text('Attached File'),
                subtitle: Text(filePath.split("amazonaws.com/").last),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadFile(String filePath) async {
    print('Downloading file from: $filePath');
    await launchUrl(Uri.parse(filePath), mode: LaunchMode.externalApplication);
  }

  Future<void> checkIn() async {
    if (location == null) {
      CustomSnackbar.error("Location service is not initialized.");
      return;
    }

    _serviceEnabled = await location!.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location!.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location!.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location!.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location!.getLocation();

    if (_locationData == null) {
      CustomSnackbar.error(
          "You need to allow location permission to check in.");
      return;
    }

    List<geoCoding.Placemark> placemarks =
        await geoCoding.placemarkFromCoordinates(
            _locationData!.latitude!, _locationData!.longitude!);

    Map body = {
      "taskId": widget.task.id,
      "userId": loginStorage.getUserId(),
      "startTime": DateTime.now().toIso8601String(),
      "location":
          "${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}",
      "lat": _locationData!.latitude,
      "long": _locationData!.longitude,
      "notes": "",
    };

    log("body at check in = $body");
  await  taskCont.checkIn(body);
  }

  Future<void> checkOut() async {
    if (location == null) {
      CustomSnackbar.error("Location service is not initialized.");
      return;
    }

    _serviceEnabled = await location!.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location!.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location!.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location!.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location!.getLocation();

    if (_locationData == null) {
      CustomSnackbar.error(
          "You need to allow location permission to check out.");
      return;
    }

    List<geoCoding.Placemark> placemarks =
        await geoCoding.placemarkFromCoordinates(
            _locationData!.latitude!, _locationData!.longitude!);

    Map body = {
      "taskId": widget.task.id,
      "userId": loginStorage.getUserId(),
      "endTime": DateTime.now().toIso8601String(),
      "location":
          "${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}",
      "checkOutLocation":
          "${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}",
      "lat": _locationData!.latitude,
      "long": _locationData!.longitude,
      "notes": "",
    };

    log("body at check out = $body");
   await taskCont.checkOut(body);
  }
}
