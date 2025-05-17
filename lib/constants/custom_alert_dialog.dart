import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/constants/constants.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  IconData? icon;
  Color? iconColor;
  String? negativeText;
  String? positiveText;
  VoidCallback? onNegativeTap;
  VoidCallback? onPositiveTap;

  CustomAlertDialog({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.iconColor = Colors.redAccent,
    this.negativeText,
    this.positiveText,
    this.onNegativeTap,
    this.onPositiveTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 60, color: iconColor),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: onNegativeTap,
                  child: Text(
                    negativeText ?? "Cancel",
                    style:
                        const TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: onPositiveTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      positiveText ?? "Ok",
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
