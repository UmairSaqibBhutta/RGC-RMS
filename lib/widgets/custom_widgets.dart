import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';

AppBar mAppbar(String text, {List<Widget>? action, Color? backgroundColor}) {
  return AppBar(
    title: Text(
      text,
      style: const TextStyle(color: blackColor),
    ),
    centerTitle: true,
    elevation: 0,
    backgroundColor: backgroundColor ?? Colors.transparent,
    iconTheme: const IconThemeData(color: Colors.black),
    actions: action,
  );
}

Text titleText(String text,
    {double? fontSize, FontWeight? fontWeight, Color? color}) {
  return Text(
    text,
    softWrap: true,
    style: TextStyle(
        fontSize: fontSize ?? 18, fontWeight: fontWeight ?? FontWeight.bold),
  );
}

String formatAmount(double amount) {
  final formatter = NumberFormat.currency(locale: 'en_PK', symbol: '₨ ');
  return formatter.format(amount);
}

const boldStyle = TextStyle(fontWeight: FontWeight.bold);
const whiteStyle = TextStyle(color: whiteColor);

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
          child: CircularProgressIndicator(
        color: appColor,
      )),
    );
  }
}


Future<DateTime?> pickDate({
  required BuildContext context,
  DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final DateTime now = DateTime.now();
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: appColor,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      );
    },
  );
  return pickedDate;
}
