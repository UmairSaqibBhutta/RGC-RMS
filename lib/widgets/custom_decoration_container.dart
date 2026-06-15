import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
          begin: Alignment.topRight,
          colors: [
            widget.isDrawer == true
                ? Colors.brown.withValues(alpha: 1)
                : Colors.brown.withValues(alpha: .2),
            widget.isDrawer == true
                ? Colors.blue.withValues(alpha: .5)
                : Colors.blue.withValues(alpha: .1),
          ],
        ),
      ),
      child: widget.child,
    );
  }
}
