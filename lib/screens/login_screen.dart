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
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to your account',
                    style: Theme.of(context).textTheme.bodyMedium,
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
                  CustomButton(
                    title: 'Sign In',
                    onTap: () {
                      if (isFormValid()) {
                        loginController.loginFunction(context);
                      }
                    },
                    child: loginController.loading.value
                        ? customCircleLoader()
                        : null,
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

Widget customCircleLoader() {
  return const AppLoader(
    size: 24,
    strokeWidth: 2.2,
    color: Colors.white,
    trackColor: Colors.white24,
  );
}
