import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/controllers/login_controller.dart';
import 'package:leadmanagementsystem/main.dart';

import '../screens/notification_screen.dart';

class FirebaseMessagingService {
  LoginController loginController = Get.put(LoginController());

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // loginController.getNotifications();
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getAPNSToken().then((String? token) {
      fcmToken = token;
      print("Firebase Messaging Token: $token");
    });

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitilizeSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: iosInitilizeSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && loginStorage.getUserId() != null) {
          // Navigate to NotificationScreen when notification is tapped
          Get.to(() => const NotificationScreen());
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            notificationId, notificationDesc,
            importance: Importance.max, showBadge: true));
  }

  Future<void> _showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      notificationId,
      notificationDesc,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    DarwinNotificationDetails iosNotiDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iosNotiDetails);
    await flutterLocalNotificationsPlugin.show(
      id: 0,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
