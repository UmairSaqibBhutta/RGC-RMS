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
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

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
              backgroundColor: Colors.white,
              appBar: mAppbar('Profile'),
              body: cont.profileData == null || cont.profileData == ''
                  ? pleaseWaitLoader()
                  : SafeArea(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00a569).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(CupertinoIcons.person_fill,
                                size: 30, color: Color(0xFF00a569)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cont.profileData!.name ?? '',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cont.profileData!.role ?? '',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: SingleChildScrollView(
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
                                  const SizedBox(height: 24),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: SizedBox(
                                      height: 48,
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          alertDialogueWithLoader(context);
                                          bool isLoggedOut =
                                              await drawerCont.doLogout();
                                          Navigator.of(context).pop();
                                          if (isLoggedOut) {
                                            loginStorage.clearStorageData();
                                            if (!kIsWeb) {}
                                            Get.offAll(const LoginScreen());
                                          }
                                        },
                                        icon: const Icon(Icons.logout,
                                            size: 18,
                                            color: Color(0xFFEF4444)),
                                        label: const Text(
                                          'Sign Out',
                                          style: TextStyle(
                                            color: Color(0xFFEF4444),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: Color(0xFFEF4444)),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE9EAEC)),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.iconData,
              color: const Color(0xFF374151),
              size: 18,
            ),
          ),
          title: Text(
            widget.title!,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          subtitle: Text(
            widget.subTitle ?? '—',
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
