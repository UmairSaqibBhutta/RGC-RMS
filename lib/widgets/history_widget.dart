import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/constants/constants.dart';

class HistoryWidget extends StatefulWidget {
  Function()? onTap;
  String? txt;

  bool? color;

  HistoryWidget({super.key, this.onTap, this.color, this.txt});

  @override
  State<HistoryWidget> createState() => _HistoryWidgetState();
}

class _HistoryWidgetState extends State<HistoryWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (widget.onTap),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.color == true ? appColor : Colors.transparent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
            child: Text(
              widget.txt!.toUpperCase(),
              style: TextStyle(
                  color: widget.color == true ? whiteColor : blackColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }
}
