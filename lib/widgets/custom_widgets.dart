import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';

AppBar mAppbar(String text,
    {List<Widget>? action, Color? backgroundColor, Widget? leading}) {
  return AppBar(
    title: Text(text),
    backgroundColor: backgroundColor,
    actions: action,
    leading: leading,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: Color(0xFFE9EAEC)),
    ),
  );
}

Text titleText(String text,
    {double? fontSize, FontWeight? fontWeight, Color? color}) {
  return Text(
    text,
    softWrap: true,
    style: TextStyle(
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? const Color(0xFF111827),
    ),
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLoader(size: 40),
              SizedBox(height: 14),
              Text(
                'Please wait...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 150.ms).scale(begin: const Offset(.9, .9));
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
          dialogTheme: DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      );
    },
  );
  return pickedDate;
}
