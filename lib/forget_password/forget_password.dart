import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  TextEditingController emailControl = TextEditingController();

  LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: loginController,
        builder: (cont) {
          return Scaffold(
            appBar: AppBar(backgroundColor: appColor),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomTextField(
                      inputType: TextInputType.emailAddress,
                      controller: emailControl,
                      hint: 'Email',
                    ),
                    const SizedBox(height: 10),
                    cont.otpLoading
                        ? const Center(child: AppLoader())
                        : CustomButton(
                            title: 'Continue',
                            onTap: () {
                              if (validation()) {
                                cont.forgetPasswordService(
                                    emailControl.text.trim());
                              }
                            })
                  ],
                ),
              ),
            ),
          );
        });
  }

  bool validation() {
    if (emailControl.text.isEmpty) {
      CustomSnackbar.error('Enter your email');
      return false;
    } else {
      return true;
    }
  }
}
