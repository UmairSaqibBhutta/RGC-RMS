import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/leaves_controller.dart';
import 'package:leadmanagementsystem/extensions/string_extensions.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/leaves_model.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/data_formatter.dart';

class AdminLeaveActionsPage extends StatefulWidget {
  final LeaveData leave;

  const AdminLeaveActionsPage({Key? key, required this.leave})
      : super(key: key);

  @override
  State<AdminLeaveActionsPage> createState() => _AdminLeaveActionsPageState();
}

class _AdminLeaveActionsPageState extends State<AdminLeaveActionsPage> {
  String selectedAction = "Pending"; // Default action
  final TextEditingController commentController = TextEditingController();

  final leaveCont = Get.find<LeavesController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Leave Actions"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLeaveDetails(),
              const SizedBox(height: 20),
              _buildActionSelection(),
              const SizedBox(height: 20),
              _buildCommentField(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays the leave details
  Widget _buildLeaveDetails() {
    return SizedBox(
      width: Get.width,
      child: Card(
        elevation: 6,
        shadowColor: Colors.teal.shade300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.teal.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderRow(),

                const Divider(thickness: 1, height: 20),
                _buildDetailRow(
                    CupertinoIcons.doc_text, "Title", widget.leave.title ?? ""),
                _buildDetailRow(CupertinoIcons.text_quote, "Description",
                    widget.leave.description ?? ""),
                _buildDetailRow(CupertinoIcons.list_bullet, "Type",
                    widget.leave.type ?? ""),
                // _buildDetailRow(CupertinoIcons.calendar_today, "Created on",
                //     DateFormatter.formatDateTime(widget.leave.leaveCreatedDate!)),
                _buildDetailRow(CupertinoIcons.clock, "Submitted at",
                    DateFormatter.formatDateTime(widget.leave.createdAt!)),

                if (widget.leave.leaveDates!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      children: [
                        for (var date in widget.leave.leaveDates!)
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.calendar,
                                    size: 18, color: Colors.teal),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormatter.formatDate(date),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_triangle,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${widget.leave.leaveDates!.length} day(s) ${widget.leave.type}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to build details with an icon
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: appColor, size: 22),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to build header row with larger text
  Widget _buildHeaderRow() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.leave.leaveCreatedBy.isNotNullOrEmpty)
          Text(
            widget.leave.leaveCreatedBy!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        if (widget.leave.leaveCreatorRole.isNotNullOrEmpty)
          Text(
            widget.leave.leaveCreatorRole!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// Displays action selection options
  Widget _buildActionSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Action:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildRadioOption("Approve", Colors.green),
            const SizedBox(width: 10),
            _buildRadioOption("Reject", Colors.red),
          ],
        ),
      ],
    );
  }

  /// Builds a single radio option
  Widget _buildRadioOption(String action, Color color) {
    return Row(
      children: [
        Radio<String>(
          value: action,
          groupValue: selectedAction,
          onChanged: (value) {
            setState(() {
              selectedAction = value!;
            });
          },
          activeColor: color,
        ),
        Text(
          action,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// Displays the comment field
  Widget _buildCommentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Add Comment:",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: commentController,
          maxLines: 3,
          minLines: 3,
          decoration: InputDecoration(
            hintText: "Write your comment here...",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.teal.shade50,
          ),
        ),
      ],
    );
  }

  /// Displays the submit button
  Widget _buildSubmitButton() {
    return CustomButton(
      title: "Submit",
      onTap: _submitAction,
    );
  }

  /// Formats the date for display
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Submits the selected action and comment
  Future<void> _submitAction() async {
    String comment = commentController.text.trim();
    String action = selectedAction;

    // You can pass `action` and `comment` to your API here
    print("Action: $action");
    print("Comment: $comment");
    String leaveActionTaken = "";

    if (action.isEmpty) {
      Get.snackbar("Error", "Please approve or reject the leave first");
      return;
    }

    if (action == "Approve") {
      leaveActionTaken = "Approved";
    } else {
      leaveActionTaken = "Rejected";
    }

    Map body = {
      "leaveId": widget.leave.sId,
      "leaveStatus": leaveActionTaken,
      "comment": commentController.text.trim(),
      "updateUserId": loginStorage.getUserId()
    };

    log("body for update leave $body ");
    alertDialogueWithLoader(context);

    bool isUpdated = await leaveCont.adminLeaveActions(body);

    Navigator.of(context).pop();

    if (isUpdated) {
      commentController.clear();

      leaveCont.getLeaves();
      Navigator.of(context).pop();
    } else {}

    // Clear inputs and navigate back
    // Navigator.of(context).pop();
  }
}
