import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/admin_drawer.dart';
import 'package:leadmanagementsystem/controllers/chat_controller.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/projects/project_details_page.dart';
import 'package:leadmanagementsystem/projects/projects_widget.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/models/project_model.dart';
import 'package:leadmanagementsystem/screens/chat/chat_page.dart';
import 'package:leadmanagementsystem/screens/notification_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/random_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  ProjectController projectController = Get.find();

  AnimationController? controller;
  Animation? animation;

  LoginController loginController = Get.put(LoginController());

  final chatCont = Get.put(MyChatController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    loginController.getNotifications();
    projectController.getProjects(context);

    _scrollController.addListener(_onScroll);

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final type = currentIndex == 0
          ? 'my'
          : currentIndex == 1
              ? 'assigned'
              : 'team';
      projectController.loadMoreProjects(type);
    }
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
    1: const Text('Assigned'),
    2: const Text('Team'),
  };

  int currentIndex = 0;

  Future<void> onRefresh() async {
    [
      await projectController.getProjects(context),
      loginController.getNotifications()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) closeFunction();
      },
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
                      InkWell(
                        onTap: () {
                          Get.to(const NotificationScreen());
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 16),
                          child: Badge.count(
                            count: cont.notificationCount ?? 0,
                            child: const Icon(
                              Icons.notifications_outlined,
                              size: 24,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          await chatCont.getChatMembers();
                          Get.to(const ChatPage());
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 16),
                          child: Image.asset("images/chat.png", height: 24),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    elevation: 0,
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    title: const Text(
                      'Dashboard',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    bottom: const PreferredSize(
                      preferredSize: Size.fromHeight(1),
                      child: Divider(height: 1, color: Color(0xFFE9EAEC)),
                    ),
                  ),
                  drawer: const AdminDrawer(),
                  body: SafeArea(
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PieChartSample2(
                                projects: getProjects(),
                              ),
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

                                          // filterController.visible.value =
                                          //     false;

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
                                            setState(() {
                                              currentIndex = val!;
                                              log("current index of switch = $currentIndex");
                                            });
                                          }),
                                    ),
                                  ),
                                  Obx(() {
                                    return Positioned(
                                      right: 24,
                                      top: 4,
                                      child: _countBadge(
                                        projectController.teamProjectsCount.value,
                                        const Color(0xFF6366F1),
                                      ),
                                    );
                                  }),
                                  Obx(() {
                                    return Positioned(
                                      left: Get.width * .44,
                                      top: 4,
                                      child: _countBadge(
                                        projectController.assignedProjectsCount.value,
                                        const Color(0xFFF59E0B),
                                      ),
                                    );
                                  }),
                                  Obx(() {
                                    return Positioned(
                                      left: 24,
                                      top: 4,
                                      child: _countBadge(
                                        projectController.myProjectsCount.value,
                                        appColor,
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
                              if (currentIndex == 0)
                                Obx(() {
                                  log("currentIndex in obx 0 = $currentIndex");
                                  return Column(children: [
                                    for (var l in
                                        // filterController.visible.value
                                        // ? filterController.projectData
                                        // :
                                        projectController.myProjects)
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
                                }),
                              if (currentIndex == 1)
                                Obx(() {
                                  log("currentIndex in obx 1 = $currentIndex");

                                  return Column(children: [
                                    for (var l in
                                        //  filterController.visible.value
                                        //     ? filterController.projectData
                                        // :
                                        projectController.assignedProjects)
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
                                }),
                              if (currentIndex == 2)
                                Obx(() {
                                  log("currentIndex in obx 2 = $currentIndex");

                                  return Column(children: [
                                    for (var l in
                                        // filterController.visible.value
                                        //     ? filterController.projectData
                                        // :
                                        projectController.teamProjects)
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
                              Obx(() {
                                final isLoading = currentIndex == 0
                                    ? projectController
                                        .isLoadingMoreMyProjects.value
                                    : currentIndex == 1
                                        ? projectController
                                            .isLoadingMoreAssigned.value
                                        : projectController
                                            .isLoadingMoreTeam.value;
                                return isLoading
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .then(delay: 200.ms) // baseline=800ms
                          .slideY(),
                ));
          }),
    );
  }

  Widget _countBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
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
      return '';
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
      return addProjectController.myProjects;
    }
  }

  getProjects() {
    if (currentIndex == 0) {
      return projectController.myProjects;
    } else if (currentIndex == 1) {
      return projectController.assignedProjects;
    } else {
      return projectController.teamProjects;
    }
  }
}
