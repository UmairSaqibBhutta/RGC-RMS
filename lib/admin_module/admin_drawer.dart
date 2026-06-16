import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/view_users_screen.dart';
import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/controllers/drawer_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/projects/projects_list_page.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/reports/reports_main_screen.dart';
import 'package:leadmanagementsystem/screens/attendance/employess_list_screen.dart';
import 'package:leadmanagementsystem/screens/attendance/mark_attendance_screen.dart';
import 'package:leadmanagementsystem/screens/daily_distance_screen.dart';
import 'package:leadmanagementsystem/screens/leaves_page.dart';
import 'package:leadmanagementsystem/screens/login_screen.dart';
import 'package:leadmanagementsystem/screens/visit_report_screen.dart';
import 'package:leadmanagementsystem/screens/reminders_list_page.dart';
import 'package:leadmanagementsystem/screens/tasks_list_page.dart';
import 'package:leadmanagementsystem/screens/add_user_screen.dart';
import 'package:leadmanagementsystem/screens/profile_screen.dart';
import 'package:leadmanagementsystem/screens/change_password_screen.dart';
import 'package:leadmanagementsystem/projects/post_work_stages_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_decoration_container.dart';
import 'package:leadmanagementsystem/widgets/custom_drawer_item.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  final drawerCont = Get.put(DrawersController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomDecorationContainer(
        isDrawer: true,
        child: SingleChildScrollView(
          child: Scrollbar(
            thickness: 6,
            // thumbVisibility: true,
            interactive: true,
            trackVisibility: true,
            child: Column(
              children: [
                DrawerHeader(
                  child: Image.asset('images/main-logo.png'),
                ),
                CustomDrawerItem(
                  icon: CupertinoIcons.home,
                  onTap: () {
                    Get.back();
                  },
                  title: "Dashboard",
                ),
                CustomDrawerItem(
                  icon: CupertinoIcons.person,
                  onTap: () {
                    Get.to(const ProfileScreen());
                  },
                  title: "Profile",
                ),
                CustomDrawerItem(
                  icon: CupertinoIcons.doc,
                  onTap: () {
                    Get.back();
                    Get.to(ProjectListPage(
                      userName: "",
                      findProjectsByUsers: false,
                      userId: '',
                    ));
                  },
                  title: "Project",
                ),
                CustomDrawerItem(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  onTap: () {
                    Get.to(const VisitListScreen());
                    // Get.to(const AddVisitScreen());
                    //
                  },
                  title: "Visit Plan / Reports",
                ),
                CustomDrawerItem(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  onTap: () {
                    Get.to(const DailyDistanceScreen());
                    //
                  },
                  title: "Distance Calculation",
                ),
                //
                CustomDrawerItem(
                  icon: CupertinoIcons.checkmark_alt,
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.to(TaskListPage(
                      getTasksNyIndividualUsers: false,
                    ));
                  },
                  title: "Tasks",
                ),
                if (loginStorage.getUserRole() != UserRole.CEO)
                  CustomDrawerItem(
                    icon: CupertinoIcons.clock,
                    onTap: () {
                      Get.to(const MarkAttendanceScreen());
                    },
                    title: "Mark Attendance",
                  ),
                if (loginStorage.getUserRole() == UserRole.CEO)
                  CustomDrawerItem(
                    icon: CupertinoIcons.group_solid,
                    onTap: () {
                      Get.to(const EmployeeListScreen());
                    },
                    title: "View Employees Attendance",
                  ),
                CustomDrawerItem(
                  icon: CupertinoIcons.chart_bar,
                  onTap: () {
                    Get.to(const ReportsMainScreen());
                  },
                  title: "Reports",
                ),
                CustomDrawerItem(
                  icon: Icons.work_off,
                  onTap: () {
                    Get.to(const LeavesPage());
                  },
                  title: "Leaves",
                ),
                CustomDrawerItem(
                  icon: Icons.alarm,
                  onTap: () {
                    // Get.to(const SetReminderScreen());
                    Get.to(const ReminderListScreen());
                  },
                  title: "Set Reminder",
                ),
                // if (loginStorage.getUserRole() == UserRole.CEO)
                //   CustomDrawerItem(
                //     icon: CupertinoIcons.location,
                //     onTap: () {
                //       Get.to(const AdminTrackUsers());
                //     },
                //     title: "Locate Workers",
                //   ),
                if (loginStorage.getUserRole() == UserRole.CEO)
                  CustomDrawerItem(
                    icon: CupertinoIcons.group,
                    onTap: () {
                      Get.back();
                      Get.to(const ManagersPage());
                    },
                    title: "View Users",
                  ),
                if (loginStorage.getUserRole() == UserRole.CEO ||
                    loginStorage.getUserRole() == UserRole.COMPANY_DIRECTOR ||
                    loginStorage.getUserRole() == UserRole.COUNTRY_HEAD)
                  CustomDrawerItem(
                    icon: CupertinoIcons.person_add,
                    onTap: () {
                      Get.back();
                      Get.to(const AddUserScreen());
                    },
                    title: "Add User",
                  ),
                CustomDrawerItem(
                  icon: CupertinoIcons.layers_alt,
                  onTap: () {
                    Get.back();
                    Get.to(const PostWorkStagesScreen());
                  },
                  title: "Post Work Stages",
                ),
                CustomDrawerItem(
                  icon: CupertinoIcons.lock,
                  onTap: () {
                    Get.back();
                    Get.to(const ChangePasswordScreen());
                  },
                  title: "Change Password",
                ),
                CustomDrawerItem(
                  icon: CupertinoIcons.square_arrow_right,
                  onTap: () async {
                    alertDialogueWithLoader(context);
                    bool isLoggedOut = await drawerCont.doLogout();
                    Navigator.of(context).pop();

                    if (isLoggedOut) {
                      loginStorage.clearStorageData();
                      if (!kIsWeb) {
                        // await BackgroundService.stopService();
                      }

                      Get.offAll(const LoginScreen());
                    }
                  },
                  title: "Logout",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
