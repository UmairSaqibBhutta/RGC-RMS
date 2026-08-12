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
import 'package:leadmanagementsystem/screens/chat/chat_page.dart';
import 'package:leadmanagementsystem/screens/notification_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/debug_delete_project_tile.dart';
import 'package:leadmanagementsystem/widgets/random_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProjectController projectController = Get.find();

  LoginController loginController = Get.put(LoginController());

  final chatCont = Get.put(MyChatController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    loginController.getNotifications();
    projectController.getProjects(context);
    projectController.getProjectStatusCounts();

    _scrollController.addListener(_onScroll);
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

  static final List<
      ({String title, Color color, String image, String status})> _statusFilters = [
    (title: 'All Projects', color: appColor, image: 'team-lead.png', status: ''),
    (title: 'Lead', color: leadColor, image: 'team-lead.png', status: 'lead'),
    (
      title: 'Contacted',
      color: contactedColor,
      image: 'operator.png',
      status: 'contacted'
    ),
    (
      title: 'Pitched',
      color: pitchedColor,
      image: 'agreement.png',
      status: 'pitched'
    ),
    (
      title: 'Sent Sample',
      color: sentSampleColor,
      image: 'sent.png',
      status: 'sentSample'
    ),
    (
      title: 'Negotiating',
      color: negotiatingColor,
      image: 'presentation.png',
      status: 'negotiating'
    ),
    (title: 'Closed - Won', color: wonColor, image: 'won.png', status: 'closeWon'),
    (
      title: 'Closed - Lost',
      color: lostColor,
      image: 'lost-items.png',
      status: 'closedLost'
    ),
    (
      title: 'Temporarily Closed',
      color: Color(0xFFFFB74D),
      image: 'lost-items.png',
      status: 'temporaryClose'
    ),
  ];

  void _selectStatusFilter(String status) {
    projectController.leadB.value = status == 'lead';
    projectController.contactedB.value = status == 'contacted';
    projectController.pitchedB.value = status == 'pitched';
    projectController.sentSampleB.value = status == 'sentSample';
    projectController.negotiatingB.value = status == 'negotiating';
    projectController.closeWonB.value = status == 'closeWon';
    projectController.closedLostB.value = status == 'closedLost';
    projectController.temporaryCloseB.value = status == 'temporaryClose';
  }

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
                  appBar: mAppbar(
                    'Dashboard',
                    action: [
                      InkWell(
                        onTap: () {
                          Get.to(const NotificationScreen());
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 16),
                          child: Badge.count(
                            count: cont.notificationCount ?? 0,
                            isLabelVisible: (cont.notificationCount ?? 0) > 0,
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
                                statusCounts:
                                    projectController.projectStatusCounts,
                              ),
                              const Divider(),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _statusFilters
                                      .map((filter) => CustomStatusButton(
                                            title: filter.title,
                                            color: filter.color,
                                            image: filter.image,
                                            onTap: () =>
                                                _selectStatusFilter(filter.status),
                                          ))
                                      .toList(),
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
                                  final myProjects = projectController.myProjects;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: myProjects.length,
                                    itemBuilder: (context, index) {
                                      final l = myProjects[index];
                                      return DebugDeleteProjectTile(
                                        projectId: l.sId!,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: InkWell(
                                              onTap: () {
                                                Get.to(ProjectDetailsPage(
                                                  updateProject: false,
                                                  receverId: '',
                                                  token: '',
                                                  senderName: '',
                                                  projectId: l.sId!,
                                                ));
                                              },
                                              child: ProjectsWidget(project: l)),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              if (currentIndex == 1)
                                Obx(() {
                                  log("currentIndex in obx 1 = $currentIndex");

                                  final assignedProjects =
                                      projectController.assignedProjects;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: assignedProjects.length,
                                    itemBuilder: (context, index) {
                                      final l = assignedProjects[index];
                                      return DebugDeleteProjectTile(
                                        projectId: l.sId!,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: InkWell(
                                              onTap: () {
                                                Get.to(ProjectDetailsPage(
                                                  updateProject: false,
                                                  receverId: '',
                                                  token: '',
                                                  senderName: '',
                                                  projectId: l.sId!,
                                                ));
                                              },
                                              child: ProjectsWidget(project: l)),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              if (currentIndex == 2)
                                Obx(() {
                                  log("currentIndex in obx 2 = $currentIndex");

                                  final teamProjects = projectController.teamProjects;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: teamProjects.length,
                                    itemBuilder: (context, index) {
                                      final l = teamProjects[index];
                                      return DebugDeleteProjectTile(
                                        projectId: l.sId!,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: InkWell(
                                              onTap: () {
                                                Get.to(ProjectDetailsPage(
                                                  projectId: l.sId!,
                                                  updateProject: false,
                                                  receverId: '',
                                                  token: '',
                                                  senderName: '',
                                                ));
                                              },
                                              child: ProjectsWidget(project: l)),
                                        ),
                                      );
                                    },
                                  );
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
                                        child: Center(child: AppLoader(size: 28)),
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
}
