import 'dart:developer';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
late ProjectController projectsController;
late LocationController locationController;

String? fcmToken;

late CustomGetRequest getRequest;
late CustomPostRequest postRequest;

late LoginStorage loginStorage;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const String notificationId = 'your channel id';
const String notificationDesc = 'Show notifications';
const notiId = 393;

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Crashlytics and catch Flutter errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  projectsController = Get.put(ProjectController(), permanent: true);
  locationController = Get.put(LocationController(), permanent: true);

  getRequest = CustomGetRequest();
  postRequest = CustomPostRequest();
  await Hive.initFlutter();
  await Hive.openBox('login_hive');
  await Hive.openBox('remindersBox');
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
          floatingActionButtonTheme:
              const FloatingActionButtonThemeData(backgroundColor: appColor),
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
