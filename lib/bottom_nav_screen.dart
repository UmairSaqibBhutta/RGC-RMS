import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/add_project_page.dart';
import 'package:leadmanagementsystem/admin_module/home_page.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/screens/tasks_list_page.dart';
import 'package:leadmanagementsystem/screens/profile_screen.dart';

import 'reports/all_users_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final screens = [
    const HomePage(),
    TaskListPage(
      getTasksNyIndividualUsers: false,
    ),
    const AllUsersScreen(),
    const ProfileScreen(),
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          currentIndex = 0;
        });
        return false;
      },
      child: Scaffold(
        body: screens[currentIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: showFloating(),
        bottomNavigationBar: SizedBox(
          height: 100,
          child: BottomAppBar(
            color: Colors.blueAccent.withOpacity(.2),
            elevation: 1,
            notchMargin: 7,
            shape: const CircularNotchedRectangle(),
            child: Row(
              children: [
                SizedBox(
                  width: Get.width * .04,
                ),
                BottomAppBarWidget(
                  changeIndex: currentIndex == 0 ? true : false,
                  checkImg: 'home',
                  unCheckImg: 'unHome',
                  onTap: () {
                    currentIndex = 0;
                    setState(() {});
                  },
                  title: 'Home',
                ),
                const Spacer(),
                BottomAppBarWidget(
                  changeIndex: currentIndex == 1 ? true : false,
                  checkImg: 'task',
                  unCheckImg: 'newTask',
                  onTap: () {
                    currentIndex = 1;
                    setState(() {});
                  },
                  title: 'Task',
                ),
                SizedBox(
                  width: Get.width * .04,
                ),
                const Spacer(),
                SizedBox(
                  width: Get.width * .04,
                ),
                BottomAppBarWidget(
                  changeIndex: currentIndex == 2 ? true : false,
                  checkImg: 'unReports',
                  unCheckImg: 'reports',
                  onTap: () {
                    currentIndex = 2;
                    setState(() {});
                  },
                  title: 'Reports',
                ),
                const Spacer(),
                BottomAppBarWidget(
                  changeIndex: currentIndex == 3 ? true : false,
                  checkImg: 'profile',
                  unCheckImg: 'unProfile',
                  onTap: () {
                    currentIndex = 3;
                    setState(() {});
                  },
                  title: 'Profile',
                ),
                SizedBox(
                  width: Get.width * .04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? showFloating() {
    if (currentIndex == 1) {
      return null;
    } else if (currentIndex == 2) {
      return null;
    } else if (currentIndex == 3) {
      return null;
    } else {
      return FloatingActionButton(
          backgroundColor: appColor,
          elevation: 0,
          onPressed: () {
            Get.to(AddProjectPage(
              reciverId: '',
              token: '',
              senderName: '',
            ));
          },
          child: const Icon(Icons.add));
    }
  }

}

class BottomAppBarWidget extends StatefulWidget {
  String? checkImg;
  String? unCheckImg;

  bool changeIndex;
  String? title;

  Function()? onTap;

  BottomAppBarWidget(
      {super.key,
      this.title,
      this.checkImg,
      this.unCheckImg,
      this.onTap,
      required this.changeIndex});

  @override
  State<BottomAppBarWidget> createState() => _BottomAppBarWidgetState();
}

class _BottomAppBarWidgetState extends State<BottomAppBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: (widget.onTap),
        child: Column(
          children: [
            Image.asset(
              widget.changeIndex == true
                  ? 'images/${widget.checkImg!}.png'
                  : 'images/${widget.unCheckImg!}.png',
              height: 28,
              width: 28,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 4),
            Text(
              widget.title!,
              style: TextStyle(
                  color: widget.changeIndex ? Colors.white : Colors.black26,
                  fontSize: 12),
            )
          ],
        ),
      ),
    );
  }
}
