import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/widgets/custom_button.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  String? email;

  OtpScreen({super.key, this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  LoginController loginController = Get.put(LoginController());

  String? otp;

  int currentIndex = 0;

  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: loginController,
        builder: (cont) {
          return currentIndex == 1
              ? Scaffold(
                  appBar: AppBar(backgroundColor: appColor),
                  body: SafeArea(
                      child: Column(
                    children: [
                      CustomTextField(
                        controller: password,
                        hint: 'Password',
                      ),
                      CustomTextField(
                        controller: confirmPassword,
                        hint: 'Confirm Password',
                      ),
                      const SizedBox(height: 10),
                      cont.loadingData
                          ? const AppLoader()
                          : CustomButton(
                              title: 'Save',
                              onTap: () {
                                if (validation()) {
                                  Map<String, dynamic> body = {
                                    'email': widget.email,
                                    'otpCode': otp,
                                    'newPassword': confirmPassword.text
                                  };

                                  print('body-->$body');

                                  cont.confirmPasswordService(body);
                                }
                              })
                    ],
                  )),
                )
              : Scaffold(
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Your Otp',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: Pinput(
                          length: 6,
                          onCompleted: (val) {
                            if (val.toString() ==
                                cont.otpModelData!.otp.toString()) {
                              otp = val.toString();
                              currentIndex = 1;
                              setState(() {});
                            } else {
                              CustomSnackbar.error('Invalid Otp');
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
        });
  }

  bool validation() {
    if (password.text.isEmpty) {
      CustomSnackbar.error('Enter your password');
      return false;
    } else if (confirmPassword.text.isEmpty) {
      CustomSnackbar.error('Enter your Confirm Password');
      return false;
    } else if (password.text != confirmPassword.text) {
      CustomSnackbar.error('Password not matched');
      return false;
    } else {
      return true;
    }
  }
}
