// import 'package:flutter/foundation.dart';
// import 'package:geocoding/geocoding.dart' as geoCoding;
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
//     as bg;

// import 'dart:async';
// import 'dart:developer';

// import 'package:get/get.dart';
// import 'package:leadmanagementsystem/api_urls.dart';
// import 'package:leadmanagementsystem/main.dart';
// import 'package:location/location.dart';

// class LocationController extends GetxController {
//   Timer? timer;

//   /// fetch location other than ceo
//   updateWorkerLocation() {
//     if (loginStorage.getUserRole() != "Group Director-CEO") {
//       initializeLocation();
//     }
//   }

//   Future<bool> getUserLocation(String id) async {
//     var responce =
//         await getRequest.customGetRequest(apiPath: AppUrls.getUserLocation);

//     if (responce != null) {
//       if (responce["status"] == true) {
//         Get.snackbar("Success", "User location fetched successfully");

//         return true;
//       } else {
//         Get.snackbar("Success", "User location could not be fetched");

//         return false;
//       }
//     } else {
//       Get.snackbar("Success", "User location could not be fetched");

//       return false;
//     }
//   }

//   void initializeLocation() {
//     bg.BackgroundGeolocation.onLocation((bg.Location location) {
//       log('[location] - $location');
//       // location.coords.

//       uploadLocationToServer(location);
//     });

//     bg.BackgroundGeolocation.ready(bg.Config(
//             desiredAccuracy: bg.Config.DESIRED_ACCURACY_MEDIUM,
//             distanceFilter: 10.0,
//             activityRecognitionInterval: 1000 * 60,
//             stopOnTerminate: false,
//             startOnBoot: true,
//             debug: true,
//             logLevel: bg.Config.LOG_LEVEL_VERBOSE))
//         .then((bg.State state) {
//       if (!state.enabled) {
//         ////
//         // 3.  Start the plugin.
//         //
//         bg.BackgroundGeolocation.start();
//       }
//     });
//   }

//   Future<void> uploadLocationToServer(bg.Location location) async {
//     List<geoCoding.Placemark> placemarks =
//         await geoCoding.placemarkFromCoordinates(
//             location.coords.latitude, location.coords.longitude);
//     log("uploadLocationToServer fired");
//     log("placemarks = ${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}");

//     Map body = {
//       "userId": loginStorage.getUserId(),
//       "lat": location.coords..latitude,
//       "long": location.coords..longitude,
//       "areaName":
//           "${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}",
//       "updatedAt": DateTime.now().toIso8601String()
//     };

//     log("body in saveLocation = $body");
//     var responce = await postRequest.customPostRequest(
//         body: body, url: AppUrls.updateLocation);

//     log("responce in update location = $responce");
//   }
// }
