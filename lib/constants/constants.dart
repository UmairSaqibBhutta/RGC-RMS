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

// const baseUrl = 'http://108.60.209.39:8030/api/';
const baseUrl = 'http://38.247.129.79:8030/api/';
// const imageBaseUrl = 'http://108.60.209.39:8030/api/';
// const apiBaseUrl = 'http://192.168.100.36:4000/api/';
// const apiBaseUrl =
//     'http://108.60.209.39:8030/api/'; //! window server testing url

// const apiBaseUrl = 'https://testleadmanagement.vercel.app/api/';
// const apiBaseUrl = 'http://192.168.100.124:4000/api/';
// const apiBaseUrl = 'https://testleadmanagement.vercel.app/api/'; ///! stagging for roofline crm

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
                          gradient: LinearGradient(
                              end: Alignment.topLeft,
                              begin: Alignment.topRight,
                              colors: [
                                Colors.blue.shade50,
                                Colors.blue.shade50
                              ]),
                          border: Border.all(color: Colors.black26),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 10),
                                child: Text('Update Account',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500)),
                              ),
                              CustomTextField(controller: name),
                              CustomTextField(controller: email),
                              CustomTextField(controller: phone),
                              const SizedBox(height: 5),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
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
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
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
                                ),
                              ),
                              Row(
                                children: [
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red),
                                        child: const Text('Cancel')),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                        controller.editManagersLoading == true
                                            ? const CircularProgressIndicator()
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
                                                    backgroundColor: appColor),
                                                child: const Text('Update')),
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
