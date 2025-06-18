import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/alarm_helper.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/models/reminder_model.dart';
import 'package:leadmanagementsystem/screens/set_reminder_screen.dart';
import 'package:leadmanagementsystem/storage/reminder_storage.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class ReminderListScreen extends StatefulWidget {
  const ReminderListScreen({super.key});

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  List<ReminderModel> reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    final data = ReminderStorage.getReminders();
    setState(() {
      reminders = data.reversed.toList();
    });
  }

  void _deleteReminder(ReminderModel reminder) async {
    bool isDeleted = await AlarmHelper.deleteAlarm(reminder.id);
    if (isDeleted) {
      await ReminderStorage.deleteReminder(reminder.id);
      setState(() {
        reminders.removeWhere((r) => r.id == reminder.id);
      });
      customSnackBar("Success", "Alarm deleted successfully");
    } else {
      customSnackBar("Failure", "Alarm could not be deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: mAppbar("Reminders", action: [
        IconButton(
          icon: const Icon(CupertinoIcons.refresh),
          onPressed: _loadReminders,
        ),
      ]),
      body: reminders.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.bell_slash, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No reminders found",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Dismissible(
                    key: Key(reminder.id.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _deleteReminder(reminder),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.redAccent,
                      ),
                      child: const Icon(CupertinoIcons.delete_solid,
                          color: Colors.white),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: appColor.withOpacity(.2),
                          child:
                              const Icon(CupertinoIcons.alarm, color: appColor),
                        ),
                        title: Text(
                          reminder.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              reminder.description,
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${reminder.dateTime.day}/${reminder.dateTime.month}/${reminder.dateTime.year}  •  ${TimeOfDay.fromDateTime(reminder.dateTime).format(context)}",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blueGrey),
                              ),
                            )
                          ],
                        ),
                        trailing: const Icon(CupertinoIcons.chevron_right,
                            size: 18, color: Colors.black26),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(CupertinoIcons.add, color: Colors.white),
        onPressed: () async {
          await Get.to(const SetReminderScreen());
          _loadReminders();
        },
      ),
    );
  }
}
