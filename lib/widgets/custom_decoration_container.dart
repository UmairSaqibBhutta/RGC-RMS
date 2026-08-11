import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';

class CustomDecorationContainer extends StatefulWidget {
  Widget? child;

  bool? isDrawer;

  CustomDecorationContainer({super.key, this.child, this.isDrawer});

  @override
  State<CustomDecorationContainer> createState() =>
      _CustomDecorationContainerState();
}

class _CustomDecorationContainerState extends State<CustomDecorationContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height,
      width: widget.isDrawer == true ? Get.width * .65 : Get.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isDrawer == true
              ? [appColor, const Color(0xFF00794A)]
              : [
                  appColor.withValues(alpha: .08),
                  appColor.withValues(alpha: .02),
                ],
        ),
      ),
      child: widget.child,
    );
  }
}
