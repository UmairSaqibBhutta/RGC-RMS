import 'package:leadmanagementsystem/utils/dev_log.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/admin_module/add_project_page.dart';
import 'package:leadmanagementsystem/constants/companies_strings.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/user_roles.dart';
import 'package:leadmanagementsystem/controllers/manager_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController manualRegionController = TextEditingController();

  bool isRole = false;

  List<String> roles = [
    UserRole.CEO,
    UserRole.COMPANY_DIRECTOR,
    UserRole.COUNTRY_HEAD,
    UserRole.RSM,
    UserRole.ASM,
    UserRole.NEW_RECRUITS
  ];

  List<String> area = ['Centre', 'North', 'South'];

  String? selectedRole;
  String? selectedCompany;
  String? selectedArea;

  bool roleB = false;
  bool compB = false;
  bool regionB = false;
  bool areaB = false;

  ManagerController managerController = Get.put(ManagerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: mAppbar('Add New User'),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SafeArea(
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: nameController,
                              hint: 'Name',
                              prefixIcon: Icons.person,
                            ),
                            CustomTextField(
                              controller: emailController,
                              hint: 'Email',
                              inputType: TextInputType.emailAddress,
                              prefixIcon: Icons.mail,
                            ),
                            CustomTextField(
                              controller: passwordController,
                              hint: 'Password',
                              prefixIcon: Icons.lock,
                            ),
                            CustomTextField(
                              controller: phoneController,
                              hint: 'Phone',
                              inputType: TextInputType.number,
                              prefixIcon: Icons.phone,
                            ),
                            CustomExpansion(
                              title: selectedRole ?? 'Select Role',
                              onTap: () {
                                roleB = !roleB;
                                setState(() {});
                              },
                              openData: roleB,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Wrap(
                                    children: [
                                      for (var l in roles)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 8),
                                          child: InkWell(
                                            onTap: () {
                                              roleB = !roleB;

                                              selectedRole = l;

                                              if (selectedRole ==
                                                  UserRole.CEO) {
                                                isRole = true;
                                                log('role-->$isRole');
                                              } else {
                                                isRole = false;
                                                log('role-->$isRole');
                                              }
                                              setState(() {});
                                            },
                                            child: Chip(
                                                label: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Text(l),
                                            )),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (selectedRole != null &&
                                selectedRole != UserRole.CEO)
                              CustomExpansion(
                                title: selectedCompany ?? 'Select Company',
                                onTap: () {
                                  compB = !compB;
                                  setState(() {});
                                },
                                openData: compB,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Wrap(
                                      children: [
                                        for (var l
                                            in Company.getRoleBasedCompanies())
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 8),
                                            child: InkWell(
                                              onTap: () {
                                                selectedCompany = l;
                                                compB = !compB;

                                                setState(() {});
                                              },
                                              child: Chip(
                                                  label: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Text(l),
                                              )),
                                            ),
                                          )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            if (selectedRole != null &&
                                selectedCompany != null &&
                                selectedRole != UserRole.CEO &&
                                selectedRole != UserRole.COMPANY_DIRECTOR &&
                                selectedRole != UserRole.COUNTRY_HEAD)
                              CustomExpansion(
                                title: selectedArea ?? 'Select Region',
                                onTap: () {
                                  regionB = !regionB;
                                  setState(() {});
                                },
                                openData: regionB,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Wrap(
                                      children: [
                                        for (var l in area)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 8),
                                            child: InkWell(
                                              onTap: () {
                                                selectedArea = l;
                                                regionB = !regionB;

                                                manualRegionController.clear();

                                                setState(() {});
                                              },
                                              child: Chip(
                                                  label: Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Text(l),
                                              )),
                                            ),
                                          )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            if (selectedRole == UserRole.ASM &&
                                    selectedArea != null ||
                                selectedRole == UserRole.NEW_RECRUITS &&
                                    selectedArea != null)
                              CustomExpansion(
                                title: 'Area',
                                openData: areaB,
                                onTap: () {
                                  areaB = !areaB;
                                  setState(() {});
                                },
                                children: [
                                  CustomTextField(
                                    onChanged: (val) {
                                      manualRegionController.text = val;
                                      setState(() {});
                                    },
                                    controller: manualRegionController,
                                    hint: 'Area',
                                  )
                                ],
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GetBuilder(
                  init: managerController,
                  builder: (controller) {
                    if (controller.addManagersLoading) {
                      return showSpinkit();
                    } else {
                      return CustomButton(
                        title: 'Save',
                        onTap: () {
                          if (selectedRole == UserRole.CEO) {
                            Map<String, dynamic> body = {
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'password': passwordController.text.trim(),
                              'role': selectedRole,
                              'phone': phoneController.text.trim(),
                              // 'fcmToken': fcmToken,
                            };

                            if (validateFields()) {
                              managerController.addManager(body);
                            }
                          } else if (selectedRole ==
                                  UserRole.COMPANY_DIRECTOR ||
                              selectedRole == UserRole.COUNTRY_HEAD) {
                            Map<String, dynamic> body = {
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'password': passwordController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'role': selectedRole,
                              'company': selectedCompany ?? '',
                            };
                            if (validateFields()) {
                              managerController.addManager(body);
                            }
                          } else if (selectedArea != null &&
                              selectedRole != null) {
                            Map<String, dynamic> body = {
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'password': passwordController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'role': selectedRole,
                              'company': selectedCompany ?? '',
                              'region': selectedArea ?? '',
                              'area': manualRegionController.text.trim(),
                              // 'fcmToken': fcmToken
                            };

                            if (validateFields()) {
                              managerController.addManager(body);
                            }
                          }
                        },
                      );
                    }
                  })
            ],
          ),
        ));
  }

  // Validation method
  bool validateFields() {
    log("selected role = $selectedRole");

    if (nameController.text.trim().isEmpty) {
      CustomSnackbar.error('Name is required');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      CustomSnackbar.error('Email is required');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      CustomSnackbar.error('Password is required');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      CustomSnackbar.error('Phone number is required');
      return false;
    }
    if (selectedRole == null) {
      CustomSnackbar.error('Please select a role');
      return false;
    }

    // Company is required for all roles except CEO
    if (selectedRole != UserRole.CEO) {
      if (selectedCompany == null) {
        CustomSnackbar.error('Please select a company');
        return false;
      }
    }

    // Region is required for roles other than CEO & Company Director
    if (selectedRole != UserRole.CEO &&
        selectedRole != UserRole.COMPANY_DIRECTOR &&
        selectedRole != UserRole.COUNTRY_HEAD) {
      if (selectedArea == null) {
        CustomSnackbar.error('Please select a region');
        return false;
      }
    }

    if ((selectedRole == UserRole.ASM ||
            selectedRole == UserRole.NEW_RECRUITS) &&
        manualRegionController.text.trim().isEmpty) {
      CustomSnackbar.error('Area is required for the selected role');
      return false;
    }

    return true;
  }

  void clearFormFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    manualRegionController.clear();

    selectedRole = null;
    selectedCompany = null;
    selectedArea = null;
  }
}
