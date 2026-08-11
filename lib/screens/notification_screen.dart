import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/controllers/update_project_controller.dart';
import 'package:leadmanagementsystem/projects/project_details_page.dart';
import 'package:leadmanagementsystem/screens/leaves_page.dart';
import 'package:leadmanagementsystem/screens/tasks_list_page.dart';
import 'package:leadmanagementsystem/widgets/custom_decoration_container.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final LoginController loginController = Get.put(LoginController());
  final UpdateProjectController updateProjectController =
      Get.put(UpdateProjectController());

  @override
  void initState() {
    super.initState();
    loginController.getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: CustomDecorationContainer(
        child: GetBuilder<LoginController>(
          init: loginController,
          builder: (controller) {
            var notifications = controller.notificationsList;

            if (notifications.isEmpty && !controller.emptyList) {
              return showSpinkit();
            } else if (controller.emptyList) {
              return const Center(
                child: Text(
                  'No Notifications Found',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              );
            } else {
              return SafeArea(
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    var notification = notifications[index];
                    bool isRead = notification.isRead ?? true;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      color: isRead
                          ? Colors.white
                          : Colors.blue[50], // Highlight unread
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: isRead ? 1 : 3,
                      child: ListTile(
                        onTap: () async {
                          log("notification.type = ${notification.type}");

                          // showDialog(
                          //     context: context,
                          //     builder: (context) => const AlertDialog(
                          //             content: Column(
                          //                 mainAxisSize: MainAxisSize.min,
                          //                 children: [
                          //               CircularProgressIndicator()
                          //             ])));
                          if (!notification.isRead!) {
                            await loginController
                                .markReadNotification(notification.sId);
                          }

                          if (!context.mounted) return;

                          // Handle different notification types
                          if (notification.type == "Project") {
                            alertDialogueWithLoader(context);

                            final project = await updateProjectController
                                .getProjectById(notification.projectId);

                            if (!context.mounted) return;
                            Navigator.pop(context); // dismiss loader

                            if (project == null) {
                              CustomSnackbar.error(
                                  'Unable to load project details');
                              return;
                            }

                            final comment = notification.comment ?? '';

                            Get.to(() => ProjectDetailsPage(
                                  projectId: project.sId!,
                                  updateProject: !(comment.contains(
                                          'project assignment!') ||
                                      comment.contains('is updated')),
                                  receverId: notification.senderId ?? '',
                                  token: '',
                                  senderName: notification.senderName ?? '',
                                ));
                          } else if (notification.type == "Task") {
                            Get.to(TaskListPage(
                              getTasksNyIndividualUsers: true,
                            ));
                          } else if (notification.type == "Leave") {
                            // Navigator.pop(context);
                            Get.to(const LeavesPage());
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor:
                              isRead ? Colors.grey[300] : Colors.blue,
                          child: Icon(
                            _getNotificationIcon(notification.type),
                            color: Colors.white,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              notification.senderName.toString(),
                              style: TextStyle(
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('dd MMM yy').format(DateTime.parse(
                                  notification.createdDate.toString())),
                              style: TextStyle(
                                fontSize: 12,
                                color: isRead ? Colors.grey : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          notification.comment ?? '',
                          style: TextStyle(
                            fontWeight:
                                isRead ? FontWeight.normal : FontWeight.w500,
                          ),
                        ),
                        trailing: !isRead
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'New',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }

  /// Returns appropriate icon based on notification type
  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case "Project":
        return Icons.assignment;
      case "Task":
        return Icons.task;
      case "Leave":
        return Icons.event_note;
      default:
        return Icons.notifications;
    }
  }
}
