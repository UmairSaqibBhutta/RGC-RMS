import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/task_controller.dart';
import 'package:leadmanagementsystem/screens/task_details_page.dart';
import 'package:leadmanagementsystem/screens/add_task_screen.dart';
import 'package:leadmanagementsystem/task_widget.dart';
import 'package:leadmanagementsystem/widgets/custom_decoration_container.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class TaskListPage extends StatefulWidget {
  bool getTasksNyIndividualUsers;

  bool isReportView;

  String? userId;

  TaskListPage(
      {super.key,
      required this.getTasksNyIndividualUsers,
      this.userId,
      this.isReportView = false});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final searchCont = TextEditingController();
  final taskCont = Get.put(TaskController());

  Map<int, Widget> dataWidget = {
    0: const Text('My Tasks'),
    1: const Text('Assigned Tasks'),
  };
  int currentIndex = 0;

  getTaskList() {
    if (widget.getTasksNyIndividualUsers == true) {
      taskCont.getTasks(widget.userId);
    } else {
      taskCont.getTasks(null);
    }
  }

  @override
  void initState() {
    super.initState();

    getTaskList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: mAppbar("Tasks List"),
        body: CustomDecorationContainer(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SafeArea(
              child: GetBuilder<TaskController>(
                init: taskCont,
                builder: (controller) {
                  if (controller.loading.isTrue) {
                    return pleaseWaitLoader();
                  }

                  final tasks = currentIndex == 0
                      ? controller.filteredTasksList
                      : controller.assignedTasksList;

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Stack(
                          children: [
                            SizedBox(
                              width: Get.width,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CupertinoSlidingSegmentedControl<int>(
                                  padding: const EdgeInsets.all(10),
                                  children: dataWidget,
                                  groupValue: currentIndex,
                                  onValueChanged: (val) {
                                    currentIndex = val!;
                                    taskCont
                                        .update(); // Notify GetBuilder to rebuild
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              left: 30,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: appColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    controller.filteredTasksList.length
                                        .toString(),
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 30,
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.blueAccent,
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    controller.assignedTasksList.length
                                        .toString(),
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SliverList.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          // Newest-first ordering (previously achieved via
                          // ListView `reverse: true`), without reversing the
                          // whole scroll view (which would flip the header too).
                          final task = tasks[tasks.length - 1 - index];
                          return GestureDetector(
                            onTap: () {
                              Get.to(TaskDetailPage(task: task));
                            },
                            child: TaskWidget(task: task),
                          )
                              .animate()
                              .untint()
                              .scale()
                              .move(delay: 300.ms, duration: 600.ms);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        floatingActionButton: widget.isReportView == true
            ? const SizedBox.shrink()
            : FloatingActionButton(
                heroTag: 'taskListAddTaskFAB',
                onPressed: () {
                  Get.to(const AddTaskScreen());
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(CupertinoIcons.add),
              ));
  }
}
