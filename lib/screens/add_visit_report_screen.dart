import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/custom_alert_dialog.dart';
import 'package:leadmanagementsystem/controllers/visit_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class VisitEntry {
  final TextEditingController clientName = TextEditingController();
  final TextEditingController contactPerson = TextEditingController();
  final TextEditingController contactNumber = TextEditingController();
  final TextEditingController visitPlan = TextEditingController();
}

class AddVisitReportScreen extends StatefulWidget {
  const AddVisitReportScreen({super.key});

  @override
  _AddVisitReportScreenState createState() => _AddVisitReportScreenState();
}

class _AddVisitReportScreenState extends State<AddVisitReportScreen> {
  DateTime? visitDate;
  final List<VisitEntry> visitEntries = [VisitEntry()];
  final VisitController visitController = Get.put(VisitController());

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: appColor,
            colorScheme: const ColorScheme.light(primary: appColor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        visitDate = picked;
      });
    }
  }

  void _addVisitEntry() {
    setState(() {
      visitEntries.add(VisitEntry());
    });
  }

  void _submitVisitReport() async {
    alertDialogueWithLoader(context);
    final body = {
      "visitDate": visitDate!.toIso8601String(),
      "userId": loginStorage.getUserId(),
      "visitDetail": visitEntries
          .map((entry) => {
                "siteName": entry.clientName.text,
                "contactPerson": entry.contactPerson.text,
                "contactNumber": entry.contactNumber.text,
                "visitPlan": entry.visitPlan.text,
              })
          .toList(),
    };

    log("visit report body = $body");

    final success = await visitController.addvisit(body);
    Navigator.pop(context);
    if (success) {
      Get.snackbar("Success", "Visit Plan / Report submitted successfully");
      visitController.getVisitReport();

      // Navigator.pop(context);
      setState(() {
        visitDate = null;
        for (var entry in visitEntries) {
          entry.clientName.clear();
          entry.contactPerson.clear();
          entry.contactNumber.clear();
          entry.visitPlan.clear();
        }
      });
    } else {
      Get.snackbar("Error", "Failed to submit visit Plan / Report");
    }
  }

  final dateFormatter = DateFormat('dd MMM yyyy');

  @override
  initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        visitController.getVisitReport();
      },
    );
  }

  /// for handling dots in textfield.
  String previousText = '';
  bool shouldAllowExit() {
    log("visitEntries length = ${visitEntries.length}");

    for (int i = 0; i < visitEntries.length; i++) {
      final element = visitEntries[i];
      log("Entry [$i] - clientName: '${element.clientName.text.trim()}', "
          "contactNumber: '${element.contactNumber.text.trim()}', "
          "visitPlan: '${element.visitPlan.text.trim()}', "
          "contactPerson: '${element.contactPerson.text.trim()}'");

      if (element.clientName.text.trim().isNotEmpty ||
          element.contactNumber.text.trim().isNotEmpty ||
          element.visitPlan.text.trim().isNotEmpty ||
          element.contactPerson.text.trim().isNotEmpty) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    log("shouldAllowExit = ${shouldAllowExit()}");
    return WillPopScope(
      onWillPop: () async {
        if (shouldAllowExit()) {
          return true;
        } else {
          final shouldLeave = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => CustomAlertDialog(
              title: "Do you want to leave this screen?",
              description: "All entered data will be lost on screen exit.",
              negativeText: "Cancel",
              positiveText: "Ok",
              onNegativeTap: () => Navigator.of(ctx).pop(false),
              onPositiveTap: () => Navigator.of(ctx).pop(true),
            ),
          );
          return shouldLeave ?? false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: mAppbar("Visit Plan / Report Form"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black12,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Visit Date",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 18),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: appColor, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              visitDate == null
                                  ? "Select Visit Date"
                                  : dateFormatter.format(visitDate!),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today_outlined,
                                color: Colors.teal, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListView.builder(
                      itemCount: visitEntries.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final entry = visitEntries[index];
                        return Stack(
                          children: [
                            if (index > 0)
                              Positioned(
                                  right: 10,
                                  child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          visitEntries.removeAt(index);
                                        });
                                      },
                                      child: const Icon(CupertinoIcons.clear,
                                          color: Colors.redAccent))),
                            _buildVisitEntry(entry, index),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: _addVisitEntry,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Another Visit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      title: "Submit",
                      onTap: () {
                        if (visitDate == null) {
                          Get.snackbar(
                              "Validation Error", "Please select a visit date");
                          return;
                        }
                        bool isValid = true;
                        for (var entry in visitEntries) {
                          if (entry.clientName.text.trim().isEmpty ||
                              entry.visitPlan.text.trim().isEmpty) {
                            Get.snackbar("Validation Error",
                                "Please fill all required fields");
                            isValid = false;
                            break;
                          }
                        }

                        if (!isValid) return;
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Submission Summary"),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date: ${dateFormatter.format(visitDate ?? DateTime.now())}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  ...visitEntries.asMap().entries.map((e) {
                                    final i = e.key + 1;
                                    final entry = e.value;
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Visit $i",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              "Client: ${entry.clientName.text}"),
                                          Text(
                                              "Contact: ${entry.contactPerson.text}"),
                                          Text(
                                              "Phone: ${entry.contactNumber.text}"),
                                          Text(
                                              "Visit details: ${entry.visitPlan.text}"),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _submitVisitReport();
                                },
                                child: const Text("Confirm & Submit"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitEntry(VisitEntry entry, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index > 0) const Divider(height: 32, thickness: 1),
        Text("Visit ${index + 1}",
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87)),
        const SizedBox(height: 16),
        const Text("Client / Site Name *",
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        CustomTextField(
          controller: entry.clientName,
          hint: "Enter client or site name",
        ),
        const SizedBox(height: 16),
        const Text("Contact Person",
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        CustomTextField(
          controller: entry.contactPerson,
          hint: "Enter contact person",
        ),
        const SizedBox(height: 16),
        const Text("Contact Number",
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        CustomTextField(
          controller: entry.contactNumber,
          hint: "Enter phone number",
          inputType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        const Text("Visit Details *",
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        CustomTextField(
          controller: entry.visitPlan,
          hint: "Enter visit details",
          maxLines: 4,
          inputType: TextInputType.multiline,
          suffix: entry.visitPlan.text.isNotEmpty ? Icons.clear : null,
          suffixOnTap: () {
            entry.visitPlan.clear();
            setState(() {}); // update suffix
          },
          onChanged: (text) {
            final controller = entry.visitPlan;

            // Update UI for suffix icon
            if (text.isEmpty || text.length == 1) setState(() {});

            final isDeleting = text.length < previousText.length;

            // User cleared text completely
            if (text.isEmpty) {
              previousText = text;
              return;
            }

            // If user is deleting — do nothing special
            if (isDeleting) {
              previousText = text;
              return;
            }

            // If user hits Enter (inserting new line)
            if (text.endsWith('\n')) {
              final cursorPosition = controller.selection.baseOffset;

              // Prevent adding multiple bullets after same line
              if (cursorPosition > 1 &&
                  text.substring(cursorPosition - 2, cursorPosition) == '• ') {
                previousText = text;
                return;
              }

              final newText =
                  '${text.substring(0, cursorPosition)}• ${text.substring(cursorPosition)}';

              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: cursorPosition + 2);
              previousText = newText;
              return;
            }

            // Insert first bullet at beginning (if not there)
            if (!text.startsWith('• ') && previousText.isEmpty) {
              controller.text = '• $text';
              controller.selection =
                  TextSelection.collapsed(offset: controller.text.length);
              previousText = controller.text;
              return;
            }

            previousText = text; // Always update at end
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
