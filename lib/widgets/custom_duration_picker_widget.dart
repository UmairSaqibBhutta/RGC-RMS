import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/task_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';

class CustomDurationPickerTile extends StatefulWidget {
  const CustomDurationPickerTile({
    super.key,
  });

  @override
  _CustomDurationPickerTileState createState() =>
      _CustomDurationPickerTileState();
}

class _CustomDurationPickerTileState extends State<CustomDurationPickerTile> {
  final taskCont = Get.find<TaskController>();

  int selectedMonths = 0;
  int selectedDays = 0;
  int selectedHours = 0;
  bool isEstimatedTimeError = false;
  String estimatedTimeErrorString = "Estimated time is required.";

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext builder) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            color: Colors.white,
          ),
          child: Column(
            children: [
              const Text(
                "Select Duration",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPicker("Months", 24, (int value) {
                      setState(() {
                        selectedMonths = value;
                      });
                    }),
                    _buildPicker("Days", 30, (int value) {
                      setState(() {
                        selectedDays = value;
                      });
                    }),
                    _buildPicker("Hours", 23, (int value) {
                      setState(() {
                        selectedHours = value;
                      });
                    }),
                  ],
                ),
              ),
              CustomButton(
                title: "Confirm",
                onTap: () {
                  Navigator.pop(context);
                  taskCont.update();
                  setState(() {
                    taskCont.estimatedTime.value =
                        "$selectedMonths Months, $selectedDays Days, $selectedHours Hours";
                    isEstimatedTimeError = false;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPicker(String label, int maxValue, Function(int) onSelected) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              onSelectedItemChanged: (int value) {
                onSelected(value);
              },
              children: List<Widget>.generate(
                maxValue + 1,
                (int index) => Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text("Estimated Time *"),
            subtitle: Text(
              taskCont.estimatedTime.value.isEmpty
                  ? "Select duration"
                  : taskCont.estimatedTime.value,
              style: TextStyle(
                color: taskCont.estimatedTime.value.isEmpty
                    ? Colors.grey
                    : Colors.black,
              ),
            ),
            trailing: const Icon(Icons.access_time, color: appColor),
            onTap: _showDurationPicker,
          ),
          if (isEstimatedTimeError)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 4.0),
              child: Text(
                estimatedTimeErrorString,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}
