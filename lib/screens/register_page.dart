import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/widgets/custom_text_field.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomTextField(
              prefixIcon: Icons.mail,
              hint: 'Email',
            ),
            CustomTextField(
              prefixIcon: Icons.phone,
              hint: 'Phone',
            ),
            CustomTextField(
              prefixIcon: Icons.location_city,
              hint: 'City',
            ),
            CustomTextField(
              prefixIcon: Icons.location_city_sharp,
              hint: 'Address',
            ),
            CustomTextField(
              prefixIcon: Icons.lock,
              hint: 'Password',
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      elevation: 0, backgroundColor: Colors.red),
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
