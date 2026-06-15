import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/controllers/manager_controller.dart';
import 'package:leadmanagementsystem/constants/size_config.dart';

import '../models/users_list_model.dart';
import '../widgets/custom_text_field.dart';

const appColor = Color(0xFF00a569);
const whiteColor = Colors.white;
const blackColor = Colors.black;
const greyColor = Colors.grey;

const leadColor = Colors.amber;
const contactedColor = Colors.indigo;
const pitchedColor = Colors.purple;
const sentSampleColor = Colors.purpleAccent;
const negotiatingColor = Colors.blueGrey;
const wonColor = Colors.green;
const lostColor = Colors.red;

const String appName = "RGC RMS";

String checkInString = "CheckIn";
String checkOutString = "CheckOut";

const baseUrl = 'http://38.247.129.79:8030/api/';

alertDialogueWithLoader(context) {
  log("alertDialogueWithLoader fired");
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return Container(
        // height: 300,
        color: Colors.transparent,
        child: Center(
            child: SizedBox(
                // height: 60,
                // width: 60,
                child: showSpinkit())),
      );
    },
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
  return const Center(
    child: SpinKitWaveSpinner(
      color: appColor,
      size: 50.0,
    ),
  );
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
                              const Text('Update Account',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF111827))),
                              const SizedBox(height: 16),
                              CustomTextField(controller: name, hint: 'Name'),
                              CustomTextField(controller: email, hint: 'Email'),
                              CustomTextField(controller: phone, hint: 'Phone'),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB))),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: DropdownButton(
                                    underline: const SizedBox.shrink(),
                                    isExpanded: true,
                                    hint: Text(status ?? ''),
                                    items: statusList.map((e) {
                                      return DropdownMenuItem(
                                          onTap: () {
                                            status = e;
                                            setState(() {});
                                          },
                                          value: e,
                                          child: Text(e));
                                    }).toList(),
                                    onChanged: (_) {}),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB))),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: DropdownButton(
                                    underline: const SizedBox.shrink(),
                                    isExpanded: true,
                                    hint: Text(role ?? ''),
                                    items: roleList.map((e) {
                                      return DropdownMenuItem(
                                          onTap: () {
                                            role = e;
                                            setState(() {});
                                          },
                                          value: e,
                                          child: Text(e));
                                    }).toList(),
                                    onChanged: (_) {}),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const Text('Cancel',
                                        style: TextStyle(
                                            color: Color(0xFF6B7280))),
                                  ),
                                  const SizedBox(width: 8),
                                  controller.editManagersLoading == true
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2, color: appColor))
                                      : ElevatedButton(
                                          onPressed: () {
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
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: appColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: const Text('Update',
                                              style: TextStyle(
                                                  color: Colors.white))),
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

// Custom dropdown decoration
InputDecoration dropdownDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: appColor),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: appColor, width: 2),
    ),
  );
}
