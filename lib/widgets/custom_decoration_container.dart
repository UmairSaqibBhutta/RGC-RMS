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
          gradient: LinearGradient(begin: Alignment.topRight, colors: [
        widget.isDrawer == true
            ? Colors.brown.withOpacity(1)
            : Colors.brown.withOpacity(.2),
        widget.isDrawer == true
            ? Colors.blue.withOpacity(.5)
            : Colors.blue.withOpacity(.1)
      ])),
      child: widget.child,
    );
  }
}
