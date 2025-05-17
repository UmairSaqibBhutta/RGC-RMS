import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/add_project_page.dart';
import 'package:leadmanagementsystem/admin_module/admin_home_page.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/controllers/location_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/screens/tasks_list_page.dart';
import 'package:leadmanagementsystem/screens/profile_screen.dart';
import 'package:leadmanagementsystem/services/background_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'reports/all_users_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  final screens = [
    const AdminHomePage(),
    TaskListPage(
      getTasksNyIndividualUsers: false,
    ),
    const AllUsersScreen(),
    const ProfileScreen(),
  ];

  int currentIndex = 0;

  LocationController locationCont = Get.put(LocationController());

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (kIsWeb) {
        Get.snackbar("⚠️ Use Mobile App",
            "Location tracking is not available on the web.");
        return;
      }

      // Check location permission status
      var status = await Permission.location.status;

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      // Log current permission and service status
      log("🔍 Location Permission Status: $status");
      log("📍 Location Service Enabled: $serviceEnabled");

      // If permission is denied, permanently denied, location service is off, or background service is not running
      if (status.isDenied ||
          status.isPermanentlyDenied ||
          !serviceEnabled ||
          !await bgService.isRunning()) {
        // Show location dialog only for non-web users and non-Group Director-CEO roles
        if (loginStorage.getUserRole() != UserRole.CEO) {
          waitForProjectLoadingToClose(context);
        }
      }
    });
  }

  void waitForProjectLoadingToClose(BuildContext context) {
    log("addProjectController.isProjectLoadingClosed = ${projectsController.isProjectLoadingClosed}");

    log("waitForProjectLoadingToClose is fired");
    Future.delayed(const Duration(seconds: 5), () {
      log("addProjectController.isProjectLoadingClosed = ${projectsController.isProjectLoadingClosed}");
      if (projectsController.isProjectLoadingClosed) {
        showLocationDialog(
            context); // Show the location dialog once first is closed
      } else {
        waitForProjectLoadingToClose(context); // Keep checking recursively
      }
    });
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

  Future<void> initializeLocation() async {
    if (loginStorage.getUserRole() != UserRole.CEO) {
      await BackgroundService.initBgService();
      await bgService.startService();

      var status = await Permission.location.status;

      if (status.isDenied) {
        // Ask for basic location access first

        status = await Permission.locationWhenInUse.request();

        if (status.isGranted) {
          // If basic access granted, request "always" access

          status = await Permission.locationAlways.request();
        }
      }
      if (!Get.isRegistered<LocationController>()) {
        locationCont = Get.put(LocationController());
      }
      locationCont.updateWorkerLocation();
    } else {
      await BackgroundService.stopService();
    }
  }

  void showLocationDialog(BuildContext context) {
    log("showLocationDialog is fired");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext locationCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 60,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Enable Location Tracking",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Allow background location tracking for monitoring and operational purposes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(locationCtx).pop();
                        BackgroundService.stopService();
                      },
                      child: const Text(
                        "Deny",
                        style: TextStyle(fontSize: 16, color: Colors.redAccent),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(locationCtx).pop();
                        initializeLocation();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text(
                          "Allow",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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
