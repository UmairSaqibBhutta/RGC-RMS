import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/forget_password/forget_password.dart';
import 'package:leadmanagementsystem/constants/size_config.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isVisible = false;
  bool animateLogo = false;

  bool isEmailError = false;
  bool isPasswordError = false;

  String emailErrorString = '';
  String passwordErrorString = '';

  @override
  void initState() {
    super.initState();
    // Trigger the animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        animateLogo = true;
      });
    });
  }

  LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: getProportionateScreenHeight(40)),
                  Center(
                    child: Image.asset(
                      'images/main-logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: getProportionateScreenHeight(48)),
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to your account',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    autofillHints: const [AutofillHints.email],
                    inputType: TextInputType.emailAddress,
                    prefixIcon: CupertinoIcons.person_alt_circle,
                    hint: 'Email address',
                    suffix: loginController.emailCont.text.isNotEmpty
                        ? CupertinoIcons.clear_circled_solid
                        : null,
                    controller: loginController.emailCont,
                    allSidesPadding: 0,
                    suffixOnTap: () {
                      loginController.emailCont.clear();
                    },
                  ),
                  if (isEmailError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: formErrorText(error: emailErrorString),
                    ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: loginController.passCont,
                    prefixIcon: CupertinoIcons.padlock,
                    inputType: TextInputType.visiblePassword,
                    autofillHints: const [AutofillHints.password],
                    maxLines: 1,
                    hint: 'Password',
                    obscureText: isVisible,
                    allSidesPadding: 0,
                    suffix: isVisible ? Icons.visibility : Icons.visibility_off,
                    suffixOnTap: () {
                      isVisible = !isVisible;
                      setState(() {});
                    },
                  ),
                  if (isPasswordError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: formErrorText(error: passwordErrorString),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.to(const ForgetPassword());
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: appColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isFormValid()) {
                          loginController.loginFunction(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: loginController.loading.value
                          ? customCircleLoader()
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  bool isFormValid() {
    bool isValid = true;
    resetErrors();

    if (loginController.emailCont.text.isEmpty) {
      emailErrorString = 'Please enter your email';
      isEmailError = true;
      isValid = false;
    }
    if (loginController.passCont.text.isEmpty) {
      passwordErrorString = 'Please enter your password';
      isPasswordError = true;
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  void resetErrors() {
    isEmailError = false;
    isPasswordError = false;

    emailErrorString = '';
    passwordErrorString = '';
  }

  Widget formErrorText({required String error}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton1 extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? gradient1;
  final Color? gradient2;
  final Color? borderColor;
  final Color? txtColor;

  const CustomButton1({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient1 = appColor,
    this.gradient2 = const Color(0xFFB9F6CA),
    this.borderColor = Colors.transparent,
    this.txtColor = Colors.white,
  });

  @override
  State<CustomButton1> createState() => _CustomButton1State();
}

class _CustomButton1State extends State<CustomButton1> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: widget.borderColor!),
            borderRadius: BorderRadius.circular(10.0),
            gradient: LinearGradient(
              colors: [
                widget.gradient1!,
                widget.gradient2!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: .3,
                blurRadius: 3,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.txtColor,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget customCircleLoader() {
  return const SizedBox(
    height: 24,
    width: 24,
    child: CircularProgressIndicator(
        strokeAlign: .1, strokeWidth: 2.2, color: Colors.white),
  );
}
