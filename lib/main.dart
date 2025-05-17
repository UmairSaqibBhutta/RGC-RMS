import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/location_controller.dart';
import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:leadmanagementsystem/firebase_options.dart';
import 'package:leadmanagementsystem/services/firbase_messaging_service.dart';

import 'package:leadmanagementsystem/services/custom_get_request.dart';
import 'package:leadmanagementsystem/services/custom_post_request.dart';
import 'package:leadmanagementsystem/constants/size_config.dart';
import 'package:leadmanagementsystem/storage/login_storage.dart';
import 'screens/splash_screen.dart';
// umairbhutta161@gmail.com
//123456

//asmahsan@gmail.com
//123456

@pragma('vm:entry-point')
onStart(ServiceInstance service) async {
  log("onStart is fired for background service ........");
  getRequest = CustomGetRequest();
  postRequest = CustomPostRequest();
  await Hive.initFlutter();
  await Hive.openBox('login_hive');
  loginStorage = LoginStorage();

  if (loginStorage.getUserId() == null) {
    return;
  }

  // Only available for flutter 3.0.0 and later
  // DartPluginRegistrant.ensureInitialized();

  log("onStart fired ........");

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  if (service is IOSServiceInstance) {}

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(minutes: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          const AndroidNotificationDetails(notificationId, notificationDesc,
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false,
              icon: '@mipmap/ic_launcher');
      if (await service.isForegroundService()) {
        await flutterLocalNotificationsPlugin.show(
          0,
          '$appName - Location Service',
          'Tracking your location to improve task updates and management.',
          NotificationDetails(android: androidPlatformChannelSpecifics),
        );
        if (!Get.isRegistered<LocationController>()) {
          locationController = Get.put(LocationController());
        }
        locationController.updateWorkerLocation();
      }
    }

    if (service is IOSServiceInstance) {
      DarwinNotificationDetails iosPlatformChannelSpecifics =
          const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );
      await flutterLocalNotificationsPlugin.show(
        0,
        '$appName - Location Service',
        'Tracking your location to improve task updates and management.',
        NotificationDetails(iOS: iosPlatformChannelSpecifics),
      );
      if (!Get.isRegistered<LocationController>()) {
        locationController = Get.put(LocationController());
      }
      locationController.updateWorkerLocation();
    }
  });
}

late ProjectController projectsController;
late LocationController locationController;

String? fcmToken;

late CustomGetRequest getRequest;
late CustomPostRequest postRequest;

late LoginStorage loginStorage;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final bgService = FlutterBackgroundService();
const String notificationId = 'your channel id';
const String notificationDesc = 'Show notifications';
const notiId = 393;

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  projectsController = Get.put(ProjectController(), permanent: true);
  locationController = Get.put(LocationController(), permanent: true);

  getRequest = CustomGetRequest();
  postRequest = CustomPostRequest();
  await Hive.initFlutter();
  await Hive.openBox('login_hive');
  loginStorage = LoginStorage();
  FirebaseMessagingService().initialize();
  await Alarm.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
    if (loginStorage.getUserId() != null) {
      log("userId = ${loginStorage.getUserId()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(.9)),
          child: child!,
        );
      },
      theme: ThemeData(
          primaryColor: appColor,
          fontFamily: GoogleFonts.lato().fontFamily,
          textTheme: GoogleFonts.mulishTextTheme(),
          useMaterial3: false,
          appBarTheme:
              const AppBarTheme(iconTheme: IconThemeData(color: Colors.black))),
      title: 'RGC RMS',
      home: const SplashScreen(),
      // home: AddProjectPage(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
