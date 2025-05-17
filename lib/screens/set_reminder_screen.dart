import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/constants/alarm_helper.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class SetReminderScreen extends StatefulWidget {
  const SetReminderScreen({super.key});

  @override
  State<SetReminderScreen> createState() => _SetReminderScreenState();
}

class _SetReminderScreenState extends State<SetReminderScreen> {
  final titleCont = TextEditingController();
  final descCont = TextEditingController();

  DateTime? selectedDateTime;

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: appColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              timePickerTheme: const TimePickerThemeData(
                backgroundColor: Colors.white,
                hourMinuteTextColor: appColor,
                dialHandColor: appColor,
              ),
              colorScheme: const ColorScheme.light(
                primary: appColor,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() => selectedDateTime = newDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mAppbar("Set Reminder"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: titleCont,
              hint: "Enter title for reminder",
            ),
            CustomTextField(
              controller: descCont,
              hint: "Enter main purpose of reminder",
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Pick Date & Time",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: _pickDateTime,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: appColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedDateTime != null
                        ? "${selectedDateTime!.day}/${selectedDateTime!.month}/${selectedDateTime!.year} "
                            "- ${TimeOfDay.fromDateTime(selectedDateTime!).format(context)}"
                        : "Tap to pick date and time",
                    style: const TextStyle(color: appColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              title: "Set Reminder",
              onTap: () {
                String title = titleCont.text.trim();
                String desc = descCont.text.trim();
                if (title.isEmpty || desc.isEmpty || selectedDateTime == null) {
                  customSnackBar("Error",
                      "Reminder title, purpose and datetime all are required");
                  return;
                } else {
                  AlarmHelper.setReminder(
                      title: title, desc: desc, dateTime: selectedDateTime!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
