import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class CustomButton extends StatefulWidget {
  final String title;

  Widget? child;

  Color? color;

  Function()? onTap;

  CustomButton(
      {super.key,
      required this.title,
      this.onTap,
      this.color = appColor,
      this.child});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: PointerInterceptor(
          intercepting: false,
          child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: widget.onTap,
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: widget.color),
                  child: widget.child ??
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      )))),
    );
  }
}
