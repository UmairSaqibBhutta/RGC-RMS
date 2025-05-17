import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/main.dart';

class BackgroundService {
  static initBgService() async {
    await bgService.configure(
        androidConfiguration: AndroidConfiguration(
          // this will be executed when app is in foreground or background in separated isolate
          onStart: onStart,
          foregroundServiceTypes: [
            AndroidForegroundType.location,
          ],
          // auto start service
          autoStart: true,
          isForegroundMode: true,

          notificationChannelId: notificationId,
          initialNotificationTitle: '$appName - Location Service',
          initialNotificationContent: 'Initializing location tracking...',
          foregroundServiceNotificationId: notiId,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: true,
          onBackground: (service) {
            onStart(service);

            return true;
          },
          onForeground: (service) {
            onStart(service);
          },
        ));
  }

  static stopService() async {
    bgService.invoke('stopService');
  }

  static startService() async {
    if (await bgService.isRunning()) {
      return;
    } else {
      bgService.startService();
    }
  }
}
