import 'dart:developer';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/controllers/leaves_controller.dart';
import 'package:leadmanagementsystem/extensions/string_extensions.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/leaves_model.dart';
import 'package:leadmanagementsystem/constants/my_extensions.dart';
import 'package:leadmanagementsystem/screens/admin_leave_actions.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/data_formatter.dart';

class LeavesPage extends StatefulWidget {
  const LeavesPage({super.key});

  @override
  _LeavesPageState createState() => _LeavesPageState();
}

class _LeavesPageState extends State<LeavesPage> {
  String? selectedLeaveType;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  final leavesController = Get.put(LeavesController());

  List<DateTime?> leaveSelectedDates = [];
  List<String?> selectedDatesStringList = [];

  @override
  void initState() {
    super.initState();
    leavesController.getLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Leaves"),
      body: GetBuilder<LeavesController>(
        init: leavesController,
        builder: (cont) {
          if (cont.getLeavesLoader) {
            return showSpinkit();
          } else if (cont.leavesList.isEmpty) {
            return const Center(
              child: Text(
                "No Leaves Found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return Column(
            children: [
              if (loginStorage.getUserRole() != UserRole.CEO)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Remaining Leaves: ${cont.remainingLeaves}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                ),
              //! add leaves filter for admin .
              //! like date, name, status
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cont.leavesList.length,
                  itemBuilder: (context, index) {
                    final leave = cont.leavesList[index];
                    final statusColor = getStatusColor(leave.leaveStatus);

                    return InkWell(
                      onTap: () {
                        log("leave.leaveStatus = ${leave.leaveStatus}");
                        // log("leave.leaveStatus = ${leave.leaveStatus}");
                        //! only show edit option if its created date is date of today and
                        //! status is also pending.
                        if (leave.leaveStatus == "Pending" &&
                            DateTime.parse(leave.createdAt!).isToday &&
                            loginStorage.getUserId() == leave.userId) {
                          // _showLeaveForm(leave: leave);
                          //! this will be used for update leave
                          //! no api for this
                        } else if (leave.leaveStatus?.toLowerCase() ==
                                "pending" &&
                            loginStorage.getUserRole() !=
                                UserRole.NEW_RECRUITS &&
                            loginStorage.getUserId() != leave.userId) {
                          Get.to(
                            AdminLeaveActionsPage(
                              leave: leave,
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // CircleAvatar(
                              //   radius: 26,
                              //   backgroundColor: appColor.withOpacity(0.2),
                              //   child: Icon(
                              //     leave.type == 'Sick Leave'
                              //         ? CupertinoIcons.heart_fill
                              //         : leave.type == 'Casual Leave'
                              //             ? CupertinoIcons.person_fill
                              //             : CupertinoIcons.money_dollar_circle,
                              //     color: appColor,
                              //     size: 30,
                              //   ),
                              // ),
                              // const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Title and Status
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        titleText(leave.title ?? "",
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            leave.leaveStatus ?? "Unknown",
                                            style: whiteStyle.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),

                                    /// **Leave Creator**
                                    if (leave.leaveCreatedBy.isNotNullOrEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          "Applied by: ${leave.leaveCreatedBy} - ${leave.leaveCreatorRole}",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),

                                    const SizedBox(height: 6),
                                    if (leave.createdAt.isNotNullOrEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 3),
                                        child: Text(
                                          "Applied at: ${DateFormatter.formatDate(leave.createdAt!)}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),

                                    const SizedBox(height: 6),

                                    /// Description
                                    Text(
                                      leave.description ?? "No Description",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),

                                    const SizedBox(height: 8),

                                    /// Leave Type and Date
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Type: ${leave.type}",
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),

                                    if (leave.leaveDates!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Wrap(
                                          children: [
                                            for (var date in leave.leaveDates!)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        CupertinoIcons.calendar,
                                                        size: 18,
                                                        color: Colors.teal),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      DateFormatter.formatDate(
                                                          date),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                    if (leave.updatedByName.isNotNullOrEmpty &&
                                        leave.updatedbyRole.isNotNullOrEmpty)
                                      RichText(
                                        text: TextSpan(
                                          text:
                                              'Leave ${leave.leaveStatus?.toLowerCase()} by ',
                                          style: const TextStyle(
                                              color: blackColor),
                                          children: [
                                            TextSpan(
                                                text: '${leave.updatedByName}',
                                                style: const TextStyle(
                                                    color: appColor)),
                                            TextSpan(
                                              text: ' - ${leave.updatedbyRole}',
                                            ),
                                          ],
                                        ),
                                      ),

                                    /// Comment Section (only if there is a comment)
                                    if (leave.comment.isNotNullOrEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.blue.shade200,
                                              width: 0.8),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                                CupertinoIcons
                                                    .chat_bubble_text_fill,
                                                size: 16,
                                                color: Colors.grey),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                leave.comment!,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black54,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: loginStorage.getUserRole() == UserRole.CEO
          ? const SizedBox.shrink()
          : FloatingActionButton(
              onPressed: () => _showLeaveForm(),
              backgroundColor: appColor,
              tooltip: "Add New Leave",
              child: const Icon(CupertinoIcons.add),
            ),
    );
  }

  /// Opens the bottom sheet for adding or updating a leave
  void _showLeaveForm({LeaveData? leave}) {
    // Prepopulate fields if editing
    // if (leave != null) {
    //   titleController.text = leave.title ?? "";
    //   descriptionController.text = leave.description ?? "";
    //   selectedLeaveType = leave.type;
    //   leaveSelectedDates = [DateTime.parse(leave.leaveCreatedDate!)];
    //   dateController.text =
    //       DateFormatter.formatDateTime(leave.leaveCreatedDate!);
    // } else {
    //   // Clear fields if adding
    titleController.clear();
    descriptionController.clear();
    selectedLeaveType = null;
    leaveSelectedDates.clear();
    selectedDatesStringList.clear();
    dateController.clear();
    // }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStatessss) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Wrap(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        leave != null ? "Update Leave" : "Add New Leave",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: const Icon(CupertinoIcons.clear),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    hint: 'Title',
                    prefixIcon: CupertinoIcons.pencil,
                    controller: titleController,
                    isRequiredField: true,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    hint: 'Description',
                    prefixIcon: CupertinoIcons.text_alignleft,
                    controller: descriptionController,
                    isRequiredField: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLeaveType,
                    decoration: InputDecoration(
                      labelText: 'Leave Type',
                      prefixIcon: const Icon(CupertinoIcons.list_bullet),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: [
                      'Sick Leave',
                      'Casual Leave',
                      'Unpaid Leave',
                    ].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedLeaveType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: _buildSelectedDatesUI(),
                  ),
                  GestureDetector(
                    onTap: () => _openDatePicker(setStatessss),
                    child: CustomTextField(
                      hint: 'Date',
                      prefixIcon: CupertinoIcons.calendar,
                      isEnabled: false,
                      controller: dateController,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GetBuilder<LeavesController>(
                    init: leavesController,
                    builder: (cont) {
                      return CustomButton(
                        title: leave != null ? "Update Leave" : "Add Leave +",
                        child: cont.addLeaveLoader
                            ? const CircularProgressIndicator(
                                color: whiteColor,
                              )
                            : Text(
                                leave != null ? "Update Leave" : "Add Leave +",
                                style: const TextStyle(color: whiteColor),
                              ),
                        onTap: () async {
                          if (titleController.text.isNotEmpty &&
                              descriptionController.text.isNotEmpty &&
                              selectedLeaveType != null &&
                              leaveSelectedDates.isNotEmpty) {
                            selectedDatesStringList.clear();
                            for (var element in leaveSelectedDates) {
                              if (element != null) {
                                selectedDatesStringList
                                    .add(element.toIso8601String());
                              }
                            }

                            Map body = {
                              "userId": loginStorage.getUserId(),
                              "title": titleController.text,
                              "description": descriptionController.text,
                              "type": selectedLeaveType!,
                              "leaveDates": selectedDatesStringList
                            };

                            bool isSuccessful = true;
                            if (leave != null) {
                              // Update existing leave
                              // isSuccessful = await cont.updateLeave(leave.id, body);
                            } else {
                              // Add new leave
                              isSuccessful = await cont.addLeave(body);
                            }

                            if (isSuccessful) {
                              clearLeaveFields();
                              cont.getLeaves();
                            }
                          } else {
                            Get.snackbar(
                              "Error",
                              "Please fill all required fields!",
                              backgroundColor: whiteColor,
                            );
                          }
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Displays selected leave dates in a modern pill-style UI
  Widget _buildSelectedDatesUI() {
    if (leaveSelectedDates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: leaveSelectedDates.map((date) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.teal.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(CupertinoIcons.calendar, size: 18, color: Colors.teal),
              const SizedBox(width: 6),
              Text(
                DateFormatter.formatDate(
                    date!.toIso8601String()), // Format date
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Opens the Date Picker
  void _openDatePicker(StateSetter setStatessss) async {
    showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
          width: Get.width / .9,
          height: Get.height / .9,
          child: Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  CalendarDatePicker2(
                    config: CalendarDatePicker2Config(
                      calendarType: CalendarDatePicker2Type.multi,
                      selectedDayHighlightColor: appColor,
                    ),
                    value: leaveSelectedDates,
                    onValueChanged: (dates) {
                      log("selectedDatesForLeaves = $leaveSelectedDates");
                      leaveSelectedDates = dates;
                      setStatessss(() {});
                    },
                  ),
                  const SizedBox(height: 15),
                  CustomButton(
                    title: "Done",
                    onTap: () {
                      Navigator.of(context).pop();
                      // setStatessss();
                      setState(() {});
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Returns a color based on leave status
  Color getStatusColor(String? status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void clearLeaveFields() {
    selectedLeaveType = null;
    titleController.clear();
    descriptionController.clear();
    dateController.clear();
    leaveSelectedDates.clear();
    selectedDatesStringList.clear();

    // If using GetX, update the controller state
  }
}
