import 'package:leadmanagementsystem/utils/dev_log.dart';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/controllers/manager_controller.dart';
import 'package:leadmanagementsystem/constants/size_config.dart';

import '../models/users_list_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_widgets.dart';

const appColor = Color(0xFF00a569);
const whiteColor = Colors.white;
const blackColor = Colors.black;
const greyColor = Colors.grey;

// Pipeline status colors, ordered to read as progress toward the brand green.
const leadColor = Color(0xFF64748B); // slate
const contactedColor = Color(0xFF3B82F6); // blue
const pitchedColor = Color(0xFF8B5CF6); // violet
const sentSampleColor = Color(0xFFF59E0B); // amber
const negotiatingColor = Color(0xFF0D9488); // teal
const wonColor = appColor;
const lostColor = Color(0xFFDC2626); // red

const String appName = "RGC RMS";

String checkInString = "CheckIn";
String checkOutString = "CheckOut";

const baseUrl = 'https://leadmanagementapi-production.up.railway.app/api/';

alertDialogueWithLoader(context) {
  log("alertDialogueWithLoader fired");
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) => const LoadingDialog(),
  );
}

Row formErrorText({required String error}) {
  return Row(
    children: [
      SvgPicture.asset(
        "images/Error.svg",
        height: getProportionateScreenWidth(14),
        width: getProportionateScreenWidth(14),
      ),
      SizedBox(
        width: getProportionateScreenWidth(10),
      ),
      Text(error),
    ],
  );
}

Widget showSpinkit() {
  return Center(
    child: const AppLoader()
        .animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: const Offset(.8, .8)),
  );
}

/// Full-screen version of the "Please wait..." card shown by
/// [alertDialogueWithLoader], for screens whose whole body depends on an
/// initial fetch completing â€” keeps that loading style consistent with Home.
Widget pleaseWaitLoader() {
  return Center(
    child: const PleaseWaitCard()
        .animate()
        .fadeIn(duration: 150.ms)
        .scale(begin: const Offset(.9, .9)),
  );
}

class PleaseWaitCard extends StatelessWidget {
  const PleaseWaitCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLoader(size: 40),
          SizedBox(height: 14),
          Text(
            'Please wait...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

/// Branded circular loader used everywhere in place of a bare
/// [CircularProgressIndicator], so every loading state in the app â€”
/// full-page, in-dialog, or inline in a button â€” looks like one
/// consistent design instead of Material's generic default spinner.
class AppLoader extends StatelessWidget {
  final double size;
  final Color color;
  final Color? trackColor;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.size = 44,
    this.color = appColor,
    this.trackColor,
    this.strokeWidth = 3.5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
        backgroundColor: trackColor ?? color.withValues(alpha: 0.15),
      ),
    );
  }
}

customRoutes(BuildContext context, Widget child) {
  Route route = PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, __, ___) {
        return child;
      });

  Navigator.of(context).push(route);
}

class CustomDialog extends StatefulWidget {
  final UserData manager;

  const CustomDialog({super.key, required this.manager});

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();

  String? role;
  String? status;

  List<String> statusList = ['Active', 'Deactive'];
  List<String> roleList = [
    'Group Director-CEO',
    'Company Director',
    'Country Head',
    'RSM (Regional Sales Manager)',
    'ASM (Area Sales Manager)',
    'New Recruits'
  ];

  @override
  void initState() {
    super.initState();

    name.text = widget.manager.name;
    email.text = widget.manager.email;
    phone.text = widget.manager.phone ?? '';
    role = widget.manager.role;
    status = widget.manager.status;

    print('role--->$role');
  }

  ManagerController managerController = Get.put(ManagerController());

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: GetBuilder<ManagerController>(
                init: managerController,
                builder: (controller) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE9EAEC)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            )
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Update Account',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 16),
                              CustomTextField(controller: name, hint: 'Name'),
                              CustomTextField(controller: email, hint: 'Email'),
                              CustomTextField(controller: phone, hint: 'Phone'),
                              CustomDropdownField<String>(
                                hint: 'Status',
                                value: status,
                                items: statusList,
                                itemLabel: (e) => e,
                                onChanged: (value) {
                                  setState(() => status = value);
                                },
                              ),
                              CustomDropdownField<String>(
                                hint: 'Role',
                                value: role,
                                items: roleList,
                                itemLabel: (e) => e,
                                onChanged: (value) {
                                  setState(() => role = value);
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 8),
                                  controller.editManagersLoading == true
                                      ? const AppLoader(
                                          size: 20, strokeWidth: 2)
                                      : SizedBox(
                                          width: 140,
                                          child: CustomButton(
                                            title: 'Update',
                                            fullWidth: false,
                                            onTap: () {
                                              Map<String, dynamic> body = {
                                                'userId': widget.manager.id,
                                                'email': email.text.trim(),
                                                'name': name.text.trim(),
                                                'role': role,
                                                'status': status,
                                                'phone': phone.text.trim(),
                                              };

                                              print('body-->$body');

                                              controller
                                                  .editProjectManager(body);
                                            },
                                          ),
                                        ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}
