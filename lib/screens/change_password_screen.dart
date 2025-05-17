import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/screens/login_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();

  LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CustomTextField(
                controller: oldPassword,
                onChanged: (val) {
                  oldPassword.text = val;
                  setState(() {});
                },
                hint: 'Old Password',
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 5),
              CustomTextField(
                controller: newPassword,
                hint: 'New Password',
                onChanged: (val) {
                  newPassword.text = val;
                  setState(() {});
                },
                prefixIcon: Icons.lock,
              ),
              const SizedBox(height: 20),
              GetBuilder(
                  init: loginController,
                  builder: (controller) {
                    return CustomButton(
                        title: 'Save',
                        onTap:
                            oldPassword.text.isEmpty || newPassword.text.isEmpty
                                ? null
                                : () {
                                    Map<String, dynamic> body = {
                                      'userId': loginStorage.getUserId(),
                                      'changePassword': newPassword.text,
                                      'oldPassword': oldPassword.text
                                    };
                                    controller.passwordChangeFunction(body);
                                  },
                        child: controller.loadingData == true
                            ? customCircleLoader()
                            : null);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
