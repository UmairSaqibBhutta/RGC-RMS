import 'dart:developer';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:leadmanagementsystem/models/reminder_model.dart';
import 'package:leadmanagementsystem/storage/reminder_storage.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';

class AlarmHelper {
  static setReminder(
      {required String title,
      required String desc,
      required DateTime dateTime}) async {
    final reminderId = dateTime.millisecondsSinceEpoch ~/ 1000;
    final alarmSettings = AlarmSettings(
      id: reminderId,
      dateTime: dateTime,
      assetAudioPath: 'assets/audio/alarm.mp3',
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fixed(volume: 1.0, volumeEnforced: true),
      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      notificationSettings: NotificationSettings(
        title: title,
        body: desc,
        stopButton: 'Stop Reminder',
        icon: 'notification_icon',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings).then(
      (value) async {
        CustomSnackbar.success("Alarm set for $title");
        await ReminderStorage.saveReminder(ReminderModel(
          id: reminderId,
          title: title,
          description: desc,
          dateTime: dateTime,
        ));
      },
    ).onError(
      (error, stackTrace) {
        log("error in alarm set = ${error.toString()}");
        CustomSnackbar.error("Alarm could not be set for $error");
      },
    );
  }

  static Future<bool> deleteAlarm(int id) async {
    try {
      await Alarm.stop(id);
      return true;
    } catch (e) {
      log("error in deleting alarm = ${e.toString()}");
      return true;
    }
  }
}
