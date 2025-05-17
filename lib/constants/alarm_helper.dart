import 'dart:developer';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';

class AlarmHelper {
  static setReminder(
      {required String title,
      required String desc,
      required DateTime dateTime}) async {
    final alarmSettings = AlarmSettings(
      id: dateTime.millisecondsSinceEpoch ~/ 1000,
      dateTime: dateTime,
      assetAudioPath: 'images/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      volume: 1,
      notificationSettings: NotificationSettings(
        title: title,
        body: desc,
        stopButton: 'Stop Reminder',
        icon: 'notification_icon',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings).then(
      (value) {
        customSnackBar("Success", "Alarm set for $title");
      },
    ).onError(
      (error, stackTrace) {
        log("error in alarm set = ${error.toString()}");
        customSnackBar("Error", "Alarm could not be set for $error");
      },
    );
  }
}
