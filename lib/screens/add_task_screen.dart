import 'package:leadmanagementsystem/utils/dev_log.dart';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/controllers/task_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_duration_picker_widget.dart';
import 'package:leadmanagementsystem/screens/login_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  bool expand = false;

  List<String> estimationTime = [
    '2 hr',
    '4 hr',
    '1 day',
    '2 day',
    '3 day',
    '4 day',
    'other'
  ];
  List<String> priorityList = ['Low', 'Medium', 'High'];

  // List<String> statusList = ['Not Started', 'In Progress', 'Completed'];

  int? currentIndex;
  String? filePath;

  uploadDocument() async {
    final filePicker =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (filePicker != null) {
      for (var element in filePicker.files) {
        taskCont.filePath.value = element.path.toString();
        taskCont.fileName.value = element.name.toString();
        setState(() {});
      }
    }
  }

  final taskCont = Get.put(TaskController());
  final projCont = Get.find<ProjectController>();

  bool isTaskNameError = false;
  bool isDescriptionError = false;
  bool isDateTimeError = false;
  bool isEstimatedTimeError = false;
  bool isProjectError = false;
  bool isPriorityError = false;

  // bool isStatusError = false;

  String taskNameErrorString = '';
  String descriptionErrorString = '';
  String dateTimeErrorString = '';
  String estimatedTimeErrorString = '';
  String projectErrorString = '';
  String priorityErrorString = '';

  // String statusErrorString = '';
  ValueNotifier<String> estimatedTime = ValueNotifier("");

  /// for task estimated time
  ///
  int selectedMonths = 0;
  int selectedDays = 0;
  int selectedHours = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: mAppbar("Add Task"),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hint: 'Task *',
                  controller: taskCont.taskNameCont,
                  prefixIcon: CupertinoIcons.text_quote,
                  prefixColor: Theme.of(context).primaryColor,
                ),
                if (isTaskNameError) formErrorText(error: taskNameErrorString),
                CustomTextField(
                  hint: 'Description *',
                  controller: taskCont.taskDescCont,
                  maxLines: 3,
                  prefixIcon: CupertinoIcons.text_quote,
                  prefixColor: Theme.of(context).primaryColor,
                ),
                if (isDescriptionError)
                  formErrorText(error: descriptionErrorString),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      primaryColor: appColor,
                      hintColor: appColor,
                      colorScheme: const ColorScheme.light(primary: appColor),
                    ),
                    child: DateTimePicker(
                      dateHintText: "Select Date",
                      fieldHintText: "Select Datetime",
                      timeHintText: "Select Time",
                      type: DateTimePickerType.dateTimeSeparate,
                      dateMask: 'd MMM, yyyy',
                      cursorColor: appColor,
                      decoration: InputDecoration(
                        focusColor: appColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: appColor),
                        ),
                      ),
                      initialValue: "Select DateTime",
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2026),
                      icon:
                          const Icon(CupertinoIcons.calendar, color: appColor),
                      dateLabelText: 'Date',
                      timeLabelText: "Hour",
                      onChanged: (val) {
                        log('object-->$val');

                        if (val != '') {
                          taskCont.taskDateTime.value = val;
                        }
                      },
                      validator: (val) {
                        log(val!);
                        return null;
                      },
                      onSaved: (val) => log(val!),
                    ),
                  ),
                ),
                if (isDateTimeError) formErrorText(error: dateTimeErrorString),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CustomDurationPickerTile(),
                ),
                if (isEstimatedTimeError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                    child: Text(
                      estimatedTimeErrorString,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4),
                      child: DropdownButton(
                        underline: const SizedBox.shrink(),
                        isExpanded: true,
                        hint: Text(taskCont.project.value == ''
                            ? "Select Project *"
                            : taskCont.project.value),
                        items: [
                          ...projCont.myProjects.map((e) {
                            return DropdownMenuItem(
                                value: e.title,
                                child: Text(e.title.toString()));
                          }).toList(),
                          ...projCont.assignedProjects.map((e) {
                            return DropdownMenuItem(
                                value: e.title,
                                child: Column(
                                  children: [
                                    Text(e.title.toString()),
                                  ],
                                ));
                          }).toList(),
                        ],
                        onChanged: (e) {
                          taskCont.project.value = e!;
                        },
                      ),
                    ),
                  ),
                ),
                if (isProjectError) formErrorText(error: projectErrorString),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: appColor, width: 1.5),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Select Priority *',
                    ),
                    items: priorityList.map((String priority) {
                      return DropdownMenuItem<String>(
                        value: priority,
                        child: Text(priority),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        taskCont.priority.value = newValue!;

                        log('priority-->${taskCont.priority.value}');
                      });
                    },
                    icon: const Icon(CupertinoIcons.exclamationmark_circle,
                        color: Colors.red), // Same color as in TaskDetailPage
                  ),
                ),
                if (isPriorityError) formErrorText(error: priorityErrorString),
                CustomTextField(
                  hint: 'Contact Person Name',
                  controller: taskCont.contactPersonCont,
                  prefixIcon: CupertinoIcons.person,
                  prefixColor: Theme.of(context).primaryColor,
                ),
                CustomTextField(
                  hint: 'Contact Person Phone',
                  controller: taskCont.contactPersonPhoneCont,
                  prefixIcon: CupertinoIcons.phone,
                  inputType: TextInputType.phone,
                  prefixColor: Theme.of(context).primaryColor,
                ),
                CustomTextField(
                  hint: 'Contact Person Company',
                  controller: taskCont.contactPersonCompanyCont,
                  prefixIcon: CupertinoIcons.building_2_fill,
                  prefixColor: Theme.of(context).primaryColor,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: uploadDocument,
                    child: Container(
                      height: 88,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: taskCont.filePath.value.isNotEmpty
                              ? appColor
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.cloud_upload,
                            color: taskCont.filePath.value.isNotEmpty
                                ? appColor
                                : const Color(0xFF9CA3AF),
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            taskCont.fileName.value.isEmpty
                                ? 'Tap to upload document'
                                : taskCont.fileName.value,
                            style: TextStyle(
                              fontSize: 13,
                              color: taskCont.filePath.value.isNotEmpty
                                  ? appColor
                                  : const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomButton(
                  onTap: () {
                    if (isFormValid()) {
                      taskCont.addTask();
                    }
                  },
                  title: 'Save ',
                  child: taskCont.loading.value == true
                      ? customCircleLoader()
                      : null,
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      );
    });
  }

  bool isFormValid() {
    bool isValid = true;
    resetErrors();

    if (taskCont.taskNameCont.text.isEmpty) {
      taskNameErrorString = 'Please enter the task name';
      isTaskNameError = true;
      isValid = false;
    }
    if (taskCont.taskDescCont.text.isEmpty) {
      descriptionErrorString = 'Please enter a description';
      isDescriptionError = true;
      isValid = false;
    }

    if (taskCont.taskDateTime.value.isEmpty) {
      dateTimeErrorString = 'Please select task date time';
      isDateTimeError = true;
      isValid = false;
    }

    if (taskCont.estimatedTime.value.isEmpty) {
      estimatedTimeErrorString = 'Please select an estimated time';
      isEstimatedTimeError = true;
      isValid = false;
    }
    if (taskCont.project.value.isEmpty) {
      projectErrorString = 'Please select a project';
      isProjectError = true;
      isValid = false;
    }
    if (taskCont.priority.value.isEmpty) {
      priorityErrorString = 'Please select a priority';
      isPriorityError = true;
      isValid = false;
    }
    // if (taskCont.status.value.isEmpty) {
    //   statusErrorString = 'Please select a status';
    //   isStatusError = true;
    //   isValid = false;
    // }

    setState(() {});
    return isValid;
  }

  void resetErrors() {
    isTaskNameError = false;
    isDescriptionError = false;
    isDateTimeError = false;
    isEstimatedTimeError = false;
    isProjectError = false;
    isPriorityError = false;
    // isStatusError = false;

    taskNameErrorString = '';
    descriptionErrorString = '';
    dateTimeErrorString = '';
    estimatedTimeErrorString = '';
    projectErrorString = '';
    priorityErrorString = '';
    // statusErrorString = '';
  }

  void showDurationPicker() {
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
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
}

class EstimationTimeWidget extends StatefulWidget {
  bool color;
  String? txt;
  Function()? onTap;

  EstimationTimeWidget({super.key, this.onTap, required this.color, this.txt});

  @override
  State<EstimationTimeWidget> createState() => _EstimationTimeWidgetState();
}

class _EstimationTimeWidgetState extends State<EstimationTimeWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (widget.onTap),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Card(
          elevation: widget.color == true ? 10 : 0,
          color: widget.color == true ? appColor : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Text(
              widget.txt!,
              style:
                  TextStyle(color: widget.color ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
