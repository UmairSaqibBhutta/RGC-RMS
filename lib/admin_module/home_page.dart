import 'dart:developer';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/admin_drawer.dart';
import 'package:leadmanagementsystem/constants/companies_strings.dart';
import 'package:leadmanagementsystem/constants/size_config.dart';
import 'package:leadmanagementsystem/controllers/filter_controller.dart';
import 'package:leadmanagementsystem/controllers/filter_variable_controller.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/projects/project_details_page.dart';
import 'package:leadmanagementsystem/projects/projects_widget.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/screens/notification_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  ProjectController projectController = Get.find();
  FilterController filterController = Get.put(FilterController());

  AnimationController? controller;
  Animation? animation;

  LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();

    loginController.getNotifications();
    projectController.getProjects(context);

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    animation = Tween<double>(begin: -1, end: 20).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.easeInOutCubicEmphasized,
      ),
    );
    controller!.forward().then((_) => controller!.reverse());
  }

  Future<bool> closeFunction() async {
    final result = await showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Do you want to close the app?'),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop(true);
              exit(0);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
    return result ?? false;
  }

  Map<int, Widget> dataWidget = {
    0: const Text('My Projects'),
    1: const Text('Assigned Projects'),
  };

  int currentIndex = 0;

  Future<void> onRefresh() async {
    [
      await projectController.getProjects(context),
      loginController.getNotifications()
    ];
  }

  FilterVariableController filterVariableController =
      Get.put(FilterVariableController());
  final GlobalKey filterShowcaseKey = GlobalKey();
  final GlobalKey showcaseKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: closeFunction,
      child: GetBuilder(
          init: loginController,
          builder: (cont) {
            return RefreshIndicator(
                color: appColor,
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                onRefresh: onRefresh,
                child: Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    actions: [
                      GetBuilder<FilterVariableController>(
                        init: filterVariableController,
                        builder: (filter) {
                          return InkWell(
                            onTap: () {
                              filter.onChanged();
                            },
                            child: Image.asset(
                              'images/filter.png',
                              width: 25,
                              height: 25,
                            ),
                          );
                        },
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(const NotificationScreen());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Badge.count(
                            count: cont.notificationCount ?? 0,
                            child: const Icon(
                              Icons.notifications,
                              size: 27,
                            ),
                          ),
                        ),
                      )
                    ],
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  drawer: const AdminDrawer(),
                  body: Container(
                      height: Get.height,
                      width: Get.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              colors: [
                            Colors.brown.withOpacity(.2),
                            Colors.blue.withOpacity(.1)
                          ])),
                      child: SafeArea(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const FilterUI(),
                              const PieChartSample2(),
                              const Divider(),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    CustomStatusButton(
                                        onTap: () {
                                          controller = AnimationController(
                                            vsync: this,
                                            duration:
                                                const Duration(seconds: 1),
                                          );

                                          animation =
                                              Tween<double>(begin: 0, end: 20)
                                                  .animate(
                                            CurvedAnimation(
                                              parent: controller!,
                                              curve: Curves.easeOutQuart,
                                            ),
                                          );
                                          controller!.forward().then(
                                              (_) => controller!.reverse());

                                          filterController.visible.value =
                                              false;
                                          projectController.leadB.value = false;
                                          projectController.contactedB.value =
                                              false;
                                          projectController.pitchedB.value =
                                              false;
                                          projectController.sentSampleB.value =
                                              false;
                                          projectController.negotiatingB.value =
                                              false;
                                          projectController.closeWonB.value =
                                              false;
                                          projectController.closedLostB.value =
                                              false;
                                          projectController
                                              .temporaryCloseB.value = false;

                                          print(projectController.leadB.value);
                                        },
                                        title: 'All Projects',
                                        color: appColor,
                                        image: 'team-lead.png'),
                                    CustomStatusButton(
                                        onTap: () {
                                          controller = AnimationController(
                                            vsync: this,
                                            duration:
                                                const Duration(seconds: 1),
                                          );

                                          animation =
                                              Tween<double>(begin: 0, end: 20)
                                                  .animate(
                                            CurvedAnimation(
                                              parent: controller!,
                                              curve: Curves
                                                  .easeInOutCubicEmphasized,
                                            ),
                                          );
                                          controller!.forward().then(
                                              (_) => controller!.reverse());

                                          filterController.visible.value =
                                              false;

                                          projectController.leadB.value = true;
                                          projectController.contactedB.value =
                                              false;
                                          projectController.pitchedB.value =
                                              false;
                                          projectController.sentSampleB.value =
                                              false;
                                          projectController.negotiatingB.value =
                                              false;
                                          projectController.closeWonB.value =
                                              false;
                                          projectController.closedLostB.value =
                                              false;
                                          projectController
                                              .temporaryCloseB.value = false;

                                          print(projectController.leadB.value);
                                        },
                                        title: 'Lead',
                                        color: leadColor,
                                        image: 'team-lead.png'),
                                    CustomStatusButton(
                                        onTap: () {
                                          controller = AnimationController(
                                            vsync: this,
                                            duration:
                                                const Duration(seconds: 1),
                                          );

                                          animation =
                                              Tween<double>(begin: -1, end: 20)
                                                  .animate(
                                            CurvedAnimation(
                                              parent: controller!,
                                              curve: Curves
                                                  .easeInOutCubicEmphasized,
                                            ),
                                          );
                                          controller!.forward().then(
                                              (_) => controller!.reverse());
                                          filterController.visible.value =
                                              false;

                                          projectController.leadB.value = false;
                                          projectController.contactedB.value =
                                              true;
                                          projectController.pitchedB.value =
                                              false;
                                          projectController.sentSampleB.value =
                                              false;
                                          projectController.negotiatingB.value =
                                              false;
                                          projectController.closeWonB.value =
                                              false;
                                          projectController.closedLostB.value =
                                              false;
                                          projectController
                                              .temporaryCloseB.value = false;

                                          print(projectController
                                              .contactedB.value);
                                        },
                                        title: 'Contacted',
                                        color: contactedColor,
                                        image: 'operator.png'),
                                    CustomStatusButton(
                                        onTap: () {
                                          controller = AnimationController(
                                            vsync: this,
                                            duration:
                                                const Duration(seconds: 1),
                                          );

                                          animation =
                                              Tween<double>(begin: -1, end: 20)
                                                  .animate(
                                            CurvedAnimation(
                                              parent: controller!,
                                              curve: Curves
                                                  .easeInOutCubicEmphasized,
                                            ),
                                          );
                                          controller!.forward().then(
                                              (_) => controller!.reverse());
                                          filterController.visible.value =
                                              false;

                                          projectController.leadB.value = false;
                                          projectController.contactedB.value =
                                              false;
                                          projectController.pitchedB.value =
                                              true;
                                          projectController.sentSampleB.value =
                                              false;
                                          projectController.negotiatingB.value =
                                              false;
                                          projectController.closeWonB.value =
                                              false;
                                          projectController.closedLostB.value =
                                              false;
                                        },
                                        title: 'Pitched',
                                        color: pitchedColor,
                                        image: 'agreement.png'),
                                    CustomStatusButton(
                                        title: 'Sent Sample',
                                        onTap: () {
                                          controller = AnimationController(
                                            vsync: this,
                                            duration:
                                                const Duration(seconds: 1),
                                          );

                                          animation =
                                              Tween<double>(begin: -1, end: 20)
                                                  .animate(
                                            CurvedAnimation(
                                              parent: controller!,
                                              curve: Curves
                                                  .easeInOutCubicEmphasized,
                                            ),
                                          );
                                          controller!.forward().then(
                                              (_) => controller!.reverse());
                                          filterController.visible.value =
                                              false;

                                          projectController.leadB.value = false;
                                          projectController.contactedB.value =
                                              false;
                                          projectController.pitchedB.value =
                                              false;
                                          projectController.sentSampleB.value =
                                              true;
                                          projectController.negotiatingB.value =
                                              false;
                                          projectController.closeWonB.value =
                                              false;
                                          projectController.closedLostB.value =
                                              false;
                                          projectController
                                              .temporaryCloseB.value = false;
                                        },
                                        color: sentSampleColor,
                                        image: 'sent.png'),
                                    CustomStatusButton(
                                        title: 'Negotiating',
                                        onTap: () {
                                          controller = AnimationController(
                                            vsync: this,
                                            duration:
                                                const Duration(seconds: 1),
                                          );

                                          animation =
                                              Tween<double>(begin: -1, end: 20)
                                                  .animate(
                                            CurvedAnimation(
                                              parent: controller!,
                                              curve: Curves
                                                  .easeInOutCubicEmphasized,
                                            ),
                                          );
                                          controller!.forward().then(
                                              (_) => controller!.reverse());
                                          filterController.visible.value =
                                              false;

                                          projectController.leadB.value = false;
                                          projectController.contactedB.value =
                                              false;
                                          projectController.pitchedB.value =
                                              false;
                                          projectController.sentSampleB.value =
                                              false;
                                          projectController.negotiatingB.value =
                                              true;
                                          projectController.closeWonB.value =
                                              false;
                                          projectController.closedLostB.value =
                                              false;
                                          projectController
                                              .temporaryCloseB.value = false;
                                        },
                                        color: negotiatingColor,
                                        image: 'presentation.png'),
                                    CustomStatusButton(
                                        title: 'Closed - Won',
                                        onTap: () {
                                          controller = AnimationController(
                                            vsync: this,
                                            duration:
                                                const Duration(seconds: 1),
                                          );

                                          animation =
                                              Tween<double>(begin: -1, end: 20)
                                                  .animate(
                                            CurvedAnimation(
                                              parent: controller!,
                                              curve: Curves
                                                  .easeInOutCubicEmphasized,
                                            ),
                                          );
                                          controller!.forward().then(
                                              (_) => controller!.reverse());
                                          filterController.visible.value =
                                              false;

                                          projectController.leadB.value = false;
                                          projectController.contactedB.value =
                                              false;
                                          projectController.pitchedB.value =
                                              false;
                                          projectController.sentSampleB.value =
                                              false;
                                          projectController.negotiatingB.value =
                                              false;
                                          projectController.closeWonB.value =
                                              true;
                                          projectController
                                              .temporaryCloseB.value = false;

                                          projectController.closedLostB.value =
                                              false;
                                        },
                                        color: wonColor,
                                        image: 'won.png'),
                                    CustomStatusButton(
                                        title: 'Closed - Lost',
                                        onTap: () {
                                          controller = AnimationController(
                                            vsync: this,
                                            duration:
                                                const Duration(seconds: 1),
                                          );

                                          animation =
                                              Tween<double>(begin: -1, end: 20)
                                                  .animate(
                                            CurvedAnimation(
                                              parent: controller!,
                                              curve: Curves
                                                  .easeInOutCubicEmphasized,
                                            ),
                                          );
                                          controller!.forward().then(
                                              (_) => controller!.reverse());
                                          filterController.visible.value =
                                              false;
                                          projectController
                                              .temporaryCloseB.value = false;

                                          projectController.leadB.value = false;
                                          projectController.contactedB.value =
                                              false;
                                          projectController.pitchedB.value =
                                              false;
                                          projectController.sentSampleB.value =
                                              false;
                                          projectController.negotiatingB.value =
                                              false;
                                          projectController.closeWonB.value =
                                              false;
                                          projectController.closedLostB.value =
                                              true;
                                        },
                                        color: lostColor,
                                        image: 'lost-items.png'),
                                    CustomStatusButton(
                                        title: 'Temporarily Closed',
                                        onTap: () {
                                          controller = AnimationController(
                                            vsync: this,
                                            duration:
                                                const Duration(seconds: 1),
                                          );

                                          animation =
                                              Tween<double>(begin: -1, end: 20)
                                                  .animate(
                                            CurvedAnimation(
                                              parent: controller!,
                                              curve: Curves
                                                  .easeInOutCubicEmphasized,
                                            ),
                                          );
                                          controller!.forward().then(
                                              (_) => controller!.reverse());
                                          filterController.visible.value =
                                              false;

                                          projectController.leadB.value = false;
                                          projectController
                                              .temporaryCloseB.value = true;
                                          projectController.contactedB.value =
                                              false;
                                          projectController.pitchedB.value =
                                              false;
                                          projectController.sentSampleB.value =
                                              false;
                                          projectController.negotiatingB.value =
                                              false;
                                          projectController.closeWonB.value =
                                              false;
                                          projectController.closedLostB.value =
                                              false;
                                        },
                                        color: Colors.orangeAccent.shade200,
                                        image: 'lost-items.png'),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Stack(
                                children: [
                                  SizedBox(
                                    width: Get.width,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CupertinoSlidingSegmentedControl(
                                          padding: const EdgeInsets.all(10),
                                          children: dataWidget,
                                          groupValue: currentIndex,
                                          onValueChanged: (val) {
                                            currentIndex = val!;
                                            setState(() {});
                                          }),
                                    ),
                                  ),
                                  Obx(() {
                                    return Positioned(
                                      right: 30,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.blueAccent,
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            projectController
                                                .projectAssignData.length
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  Obx(() {
                                    return Positioned(
                                      left: 30,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: appColor,
                                            shape: BoxShape.circle),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            projectController.projectData.length
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    );
                                  })
                                ],
                              ),
                              Obx(() {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13.0, vertical: 9),
                                  child: titleText(titleTextAll()),
                                );
                              }),
                              if (currentIndex == 1)
                                Obx(() {
                                  return Column(children: [
                                    for (var l in filterController.visible.value
                                        ? filterController.projectData
                                        : projectController.projectAssignData)
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: InkWell(
                                            onTap: () {
                                              Get.to(ProjectDetailsPage(
                                                updateProject: false,
                                                receverId: '',
                                                token: '',
                                                senderName: '',
                                                project: l,
                                              ));
                                            },
                                            child: AnimatedBuilder(
                                                animation: animation!,
                                                builder: (BuildContext context,
                                                    Widget? child) {
                                                  return Transform.translate(
                                                      offset: Offset(
                                                          0, animation!.value!),
                                                      child: ProjectsWidget(
                                                          project: l));
                                                })),
                                      )
                                  ]);
                                })
                              else
                                Obx(() {
                                  return Column(children: [
                                    for (var l in filterController.visible.value
                                        ? filterController.projectData
                                        : data(projectController))
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: InkWell(
                                            onTap: () {
                                              Get.to(ProjectDetailsPage(
                                                project: l,
                                                updateProject: false,
                                                receverId: '',
                                                token: '',
                                                senderName: '',
                                              ));
                                            },
                                            child: AnimatedBuilder(
                                                animation: animation!,
                                                builder: (BuildContext context,
                                                    Widget? child) {
                                                  return Transform.translate(
                                                      offset: Offset(
                                                          0, animation!.value!),
                                                      child: ProjectsWidget(
                                                          project: l));
                                                })),
                                      )
                                  ]);
                                }),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .then(delay: 200.ms) // baseline=800ms
                          .slideY()),
                ));
          }),
    );
  }

  String titleTextAll() {
    if (projectController.leadB.value) {
      return 'Lead';
    } else if (projectController.contactedB.value) {
      return 'Contacted';
    } else if (projectController.pitchedB.value) {
      return 'Pitched';
    } else if (projectController.sentSampleB.value) {
      return 'Sent Sample';
    } else if (projectController.negotiatingB.value) {
      return 'Negotiating';
    } else if (projectController.closeWonB.value) {
      return 'Close-Won';
    } else if (projectController.closedLostB.value) {
      return 'Close-Lost';
    } else if (projectController.temporaryCloseB.value) {
      return 'Temporary Close';
    } else {
      return 'All Projects';
    }
  }

  Iterable<ProjectData> data(ProjectController addProjectController) {
    if (addProjectController.leadB.value == true) {
      return addProjectController.lead;
    } else if (addProjectController.contactedB.value == true) {
      return addProjectController.contacted;
    } else if (addProjectController.pitchedB.value == true) {
      return addProjectController.pitched;
    } else if (addProjectController.sentSampleB.value == true) {
      return addProjectController.sentSample;
    } else if (addProjectController.negotiatingB.value == true) {
      return addProjectController.negotiating;
    } else if (addProjectController.closeWonB.value == true) {
      return addProjectController.closeWon;
    } else if (addProjectController.closedLostB.value == true) {
      return addProjectController.closedLost;
    } else if (addProjectController.temporaryCloseB.value == true) {
      return addProjectController.temporaryClose;
    } else {
      return addProjectController.projectData;
    }
  }
}

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;

  ProjectController addProjectController = Get.put(ProjectController());

  List<Map<String, dynamic>> pieData = [];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      pieData = [
        {
          'title': 'Lead',
          'count': addProjectController.lead.isEmpty
              ? 0
              : addProjectController.lead.length,
          'color': leadColor
        },
        {
          'title': 'Contacted',
          'count': addProjectController.contacted.isEmpty
              ? 0
              : addProjectController.contacted.length,
          'color': contactedColor
        },
        {
          'title': 'Pitched',
          'count': addProjectController.pitched.isEmpty
              ? 0
              : addProjectController.pitched.length,
          'color': pitchedColor
        },
        {
          'title': 'Sent Sample',
          'count': addProjectController.sentSample.isEmpty
              ? 0
              : addProjectController.sentSample.length,
          'color': sentSampleColor
        },
        {
          'title': 'Negotiating',
          'count': addProjectController.negotiating.isEmpty
              ? 0
              : addProjectController.negotiating.length,
          'color': negotiatingColor
        },
        {
          'title': 'Closed - Won',
          'count': addProjectController.closeWon.isEmpty
              ? 0
              : addProjectController.closeWon.length,
          'color': wonColor
        },
        {
          'title': 'Closed - Lost',
          'count': addProjectController.closedLost.isEmpty
              ? 0
              : addProjectController.closedLost.length,
          'color': lostColor
        },
        {
          'title': 'Temporary Close',
          'count': addProjectController.temporaryClose.isEmpty
              ? 0
              : addProjectController.temporaryClose.length,
          'color': Colors.orangeAccent.shade200
        },
      ];

      return SizedBox(
        height: kIsWeb ? Get.height / 2 : Get.height / 3,
        child: Stack(
          children: [
            Row(
              children: <Widget>[
                const SizedBox(
                  height: 18,
                ),

                addProjectController.projectData.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Container(
                          height: 180,
                          width: 180,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Center(
                            child: Text(
                              '0',
                              style: TextStyle(
                                  fontSize: 120,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: .8,
                        child: PieChart(
                          swapAnimationCurve: Curves.easeInSine,
                          PieChartData(
                            centerSpaceColor: Colors.white,
                            pieTouchData: PieTouchData(
                              touchCallback:
                                  (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    touchedIndex = -1;
                                    return;
                                  }
                                  touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(
                              show: true,
                            ),
                            sectionsSpace: 1.5,
                            centerSpaceRadius: 45,
                            sections: showingSections(pieData),
                          ),
                        ),
                      ),
             if(Platform.isIOS)   const SizedBox(
                  width: 10,
                ),

                addProjectController.projectData.isEmpty
                    ? const Spacer()
                    : const SizedBox.shrink(),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    for (var l in pieData)
                      Indicators(
                        color: l['color'],
                        title: l['title'],
                      )
                  ],
                )
              ],
            ),
            //! arrow line on pie chart
            if (!kIsWeb && !isIOSTablet(context))
              Positioned(
                left: 194,
                top: 40,
                right: 150,
                child: Transform.rotate(
                  angle: 100,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                ),
              ),
            Positioned(
              right: 70,
              top: -1,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Row(
                    children: [
                      Text('Total: ${addProjectController.projectData.length}')
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }

  List<PieChartSectionData> showingSections(
      List<Map<String, dynamic>> pieData) {
    return List.generate(pieData.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      final data = pieData[i];
      final count = data['count'];

      return PieChartSectionData(
        color: data['color'],
        value: double.tryParse(count.toString()),
        title: count.toString(),
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
}

class Indicators extends StatefulWidget {
  Color? color;
  String? title;

  Indicators({super.key, this.color, this.title});

  @override
  State<Indicators> createState() => _IndicatorsState();
}

class _IndicatorsState extends State<Indicators> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            Container(
              height: 12,
              width: 12,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: widget.color),
            ),
            const SizedBox(width: 8),
            Text(
              widget.title!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
            )
          ],
        ),
      ),
    );
  }
}

class CustomStatusButton extends StatefulWidget {
  String? image;
  Function()? onTap;
  String? title;
  Color? color;

  CustomStatusButton(
      {super.key, this.color, this.title, this.image, this.onTap});

  @override
  State<CustomStatusButton> createState() => _CustomStatusButtonState();
}

class _CustomStatusButtonState extends State<CustomStatusButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (widget.onTap),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            decoration: BoxDecoration(
                color: widget.color!.withOpacity(.6),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.black12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Image.asset(
                      'images/${widget.image!}',
                      height: 27,
                      width: 27,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    widget.title!,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
            )),
      ),
    );
  }
}

class FilterUI extends StatefulWidget {
  const FilterUI({super.key});

  @override
  State<FilterUI> createState() => _FilterUIState();
}

class _FilterUIState extends State<FilterUI> {
  bool expand = false;

  TextEditingController architectCont = TextEditingController();
  TextEditingController budgetCont = TextEditingController();
  TextEditingController projectNameCont = TextEditingController();

  String? groupValue;
  String? groupValue1;

  List<String> statuses = [
    'Lead',
    'Contracted',
    'Pitched',
    'Sent Sample',
    'Negotiating',
    'Closed-Won',
    'Closed-Lost',
    'Temporary Close'
  ];

  String? status;
  String? company;

  FilterController filterController = Get.put(FilterController());

  FilterVariableController filterVariableController =
      Get.put(FilterVariableController());

  @override
  Widget build(BuildContext context) {
    log("Company.getRoleBasedCompanies() = ${Company.getRoleBasedCompanies()}");
    return GetBuilder(
        init: filterVariableController,
        builder: (con) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: con.expand == false ? 0 : 10,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CustomStatusButton(
                  //   color: Colors.deepOrange.shade300,
                  //   onTap: () {
                  //     expand = !expand;
                  //     setState(() {});
                  //   },
                  //   image: 'filter.png',
                  //   title: 'Filter',
                  // ),
                  if (con.expand)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            hint: 'Architect',
                            controller: architectCont,
                          ),
                          CustomTextField(
                            hint: 'Project Title',
                            controller: projectNameCont,
                          ),
                          const SizedBox(height: 10),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'Project Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var l in statuses)
                                  CustomRadioButton(
                                    value: l,
                                    groupValue: groupValue,
                                    title: l,
                                    onChanged: (v) {
                                      groupValue = v;
                                      status = v;

                                      print(status);

                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ),
                          CustomTextField(
                            hint: 'Budget',
                            inputType: TextInputType.number,
                            controller: budgetCont,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (Company.getRoleBasedCompanies()
                                  .contains(Company.ROOFLINE))
                                RadioWithImage(
                                    groupValue: groupValue1,
                                    value: '1',
                                    onChanged: (val) {
                                      groupValue1 = val;
                                      company = Company.ROOFLINE;
                                      setState(() {});
                                    },
                                    image: 'roofline.jpg',
                                    title: Company.ROOFLINE),
                              if (Company.getRoleBasedCompanies()
                                  .contains(Company.RADIANT))
                                RadioWithImage(
                                    groupValue: groupValue1,
                                    value: '2',
                                    onChanged: (val) {
                                      groupValue1 = val;
                                      company = Company.RADIANT;

                                      setState(() {});
                                    },
                                    image: 'radiant.png',
                                    title: Company.RADIANT),
                              if (Company.getRoleBasedCompanies()
                                  .contains(Company.MAMZ))
                                RadioWithImage(
                                    groupValue: groupValue1,
                                    value: '3',
                                    onChanged: (val) {
                                      groupValue1 = val;
                                      company = Company.MAMZ;

                                      setState(() {});
                                    },
                                    image: 'mamz.png',
                                    title: Company.MAMZ)
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Obx(() {
                              return filterController.loading.value
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: showSpinkit())
                                  : CustomStatusButton(
                                      image: 'search.png',
                                      title: 'Search',
                                      onTap: () async {
                                        log("projectNameCont = ${projectNameCont.text}");
                                        await filterController
                                            .getProjectsFilter(
                                                architectCont.text.trim(),
                                                status,
                                                budgetCont.text.trim(),
                                                projectNameCont.text.trim(),
                                                company);

                                        con.expand = false;
                                        setState(() {});
                                      },
                                      color: Colors.blueAccent);
                            }),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          );
        });
  }
}

class CustomRadioButton extends StatefulWidget {
  String? value;
  String? groupValue;
  Function(String? val)? onChanged;
  String? title;

  CustomRadioButton(
      {super.key, this.value, this.onChanged, this.groupValue, this.title});

  @override
  State<CustomRadioButton> createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(
            value: widget.value!,
            groupValue: widget.groupValue,
            onChanged: (widget.onChanged!)),
        const SizedBox(width: 10),
        Text(
          widget.title!,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}

class RadioWithImage extends StatefulWidget {
  String? value;
  String? groupValue;
  void Function(String? val)? onChanged;

  String? title;
  String? image;

  RadioWithImage(
      {super.key,
      this.groupValue,
      this.onChanged,
      this.value,
      this.title,
      this.image});

  @override
  State<RadioWithImage> createState() => _RadioWithImageState();
}

class _RadioWithImageState extends State<RadioWithImage> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Radio(
              value: widget.value!,
              groupValue: widget.groupValue,
              onChanged: (widget.onChanged)),
          Padding(
            padding:
                EdgeInsets.only(bottom: widget.image == 'mamz.png' ? 1 : 7),
            child: Image.asset(
              'images/${widget.image}',
              height:
                  widget.image == 'radiant.png' || widget.image == 'mamz.png'
                      ? 50
                      : 50,
              width: widget.image == 'radiant.png' || widget.image == 'mamz.png'
                  ? 50
                  : 50,
            ),
          ),
        ],
      ),
    );
  }
}
