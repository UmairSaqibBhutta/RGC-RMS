import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class CustomButton extends StatefulWidget {
  final String title;

  Widget? child;

  Color? color;

  Function()? onTap;

  bool fullWidth;

  bool outlined;

  double height;

  CustomButton(
      {super.key,
      required this.title,
      this.onTap,
      this.color = appColor,
      this.child,
      this.fullWidth = true,
      this.outlined = false,
      this.height = 50});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    final Color brandColor = widget.color ?? appColor;
    final buttonStyle = widget.outlined
        ? OutlinedButton.styleFrom(
            foregroundColor: brandColor,
            side: BorderSide(color: brandColor, width: 1.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          )
        : ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            backgroundColor: brandColor,
          );

    final label = widget.child ??
        Text(
          widget.title,
          style: TextStyle(
            color: widget.outlined ? brandColor : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: PointerInterceptor(
          intercepting: false,
          child: SizedBox(
              height: widget.height,
              width: widget.fullWidth ? double.infinity : null,
              child: widget.outlined
                  ? OutlinedButton(
                      onPressed: widget.onTap,
                      style: buttonStyle,
                      child: label,
                    )
                  : ElevatedButton(
                      onPressed: widget.onTap,
                      style: buttonStyle,
                      child: label,
                    ))),
    );
  }
}
