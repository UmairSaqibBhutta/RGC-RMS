import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/companies_strings.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/controllers/drawer_controller.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/screens/login_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_decoration_container.dart';

import '../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  LoginController loginController = Get.put(LoginController());
  final drawerCont = Get.put(DrawersController());

  @override
  void initState() {
    super.initState();
    loginController.getProfileService();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: loginController,
        builder: (cont) {
          return Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: const Text(
                  'Profile',
                  style: TextStyle(color: Colors.black),
                ),
                elevation: 0,
              ),
              body: cont.profileData == null || cont.profileData == ''
                  ? showSpinkit()
                  : CustomDecorationContainer(
                      child: SafeArea(
                        child: Column(
                          children: [
                            CustomListTile(
                                title: 'Name',
                                subTitle: cont.profileData!.name,
                                iconData: CupertinoIcons.person),
                            CustomListTile(
                              title: 'Email',
                              subTitle: cont.profileData!.email,
                              iconData: CupertinoIcons.mail,
                            ),
                            CustomListTile(
                              title: 'Phone',
                              subTitle: cont.profileData!.phone,
                              iconData: CupertinoIcons.phone,
                            ),
                            CustomListTile(
                              title: 'Role',
                              subTitle: cont.profileData!.role,
                              iconData: CupertinoIcons.briefcase,
                            ),
                            if (cont.profileData?.role != UserRole.CEO)
                              CustomListTile(
                                title: 'Company',
                                subTitle: cont.profileData!.company,
                                iconData: CupertinoIcons.building_2_fill,
                              )
                            else
                              CustomListTile(
                                title: 'Company',
                                subTitle:
                                    "${Company.ROOFLINE}, ${Company.RADIANT}, ${Company.MAMZ}",
                                iconData: CupertinoIcons.building_2_fill,
                              ),
                            const SizedBox(height: 30),
                            InkWell(
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 13.0),
                                    child: Row(
                                      children: [
                                        Spacer(),
                                        Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Logout',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Spacer(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ));
        });
  }
}

class CustomListTile extends StatefulWidget {
  String? title;
  String? subTitle;
  IconData? iconData;

  CustomListTile({super.key, this.title, this.subTitle, this.iconData});

  @override
  State<CustomListTile> createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Icon(
              widget.iconData,
              color: Colors.black,
            ),
          ),
          title: Text(
            widget.title!,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(widget.subTitle!),
        ),
      ),
    );
  }
}
