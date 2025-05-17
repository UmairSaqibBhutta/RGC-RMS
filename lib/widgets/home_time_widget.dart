import 'package:flutter/material.dart';

class HomeTimeWidget extends StatefulWidget {
  Widget? child;

  double? elevation;
  Color? color;

  HomeTimeWidget({super.key, this.child, this.color, this.elevation});

  @override
  State<HomeTimeWidget> createState() => _HomeTimeWidgetState();
}

class _HomeTimeWidgetState extends State<HomeTimeWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        surfaceTintColor: Colors.white,
        elevation: widget.elevation,
        color: widget.color,
        child: widget.child,
      ),
    );
  }
}
