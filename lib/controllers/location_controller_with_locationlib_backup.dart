// import 'package:flutter/foundation.dart';
// import 'package:geocoding/geocoding.dart' as geoCoding;

// import 'dart:async';
// import 'dart:developer';

// import 'package:get/get.dart';
// import 'package:leadmanagementsystem/api_urls.dart';
// import 'package:leadmanagementsystem/main.dart';
// import 'package:location/location.dart';

// class LocationController extends GetxController {
//   final Location _location = Location();
//   StreamSubscription<LocationData>? _locationSubscription;
//   Timer? _updateTimer;

//   /// fetch location other than ceo
//   updateWorkerLocation() {
//     if (loginStorage.getUserRole() != "Group Director-CEO") {
//       _initializeLocation();
//     }
//   }

//   Future<void> _initializeLocation() async {
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     // Check if the location service is enabled
//     serviceEnabled = await _location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _location.requestService();
//       if (!serviceEnabled) {
//         return; // Location services not enabled
//       }
//     }

//     // Check for location permissions
//     permissionGranted = await _location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await _location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         return; // Permissions not granted
//       }
//     }

//     await enableBackgroundMode();

//     _startTracking();
//   }

//   Future<bool> enableBackgroundMode() async {
//     bool _bgModeEnabled = await _location.isBackgroundModeEnabled();
//     if (_bgModeEnabled) {
//       return true;
//     } else {
//       try {
//         await _location.enableBackgroundMode();
//       } catch (e) {
//         debugPrint(e.toString());
//       }
//       try {
//         _bgModeEnabled = await _location.enableBackgroundMode();
//       } catch (e) {
//         debugPrint(e.toString());
//       }
//       print(_bgModeEnabled); //True!
//       return _bgModeEnabled;
//     }
//   }

//   void _startTracking() {
//     String _locationInfo = "";

//     _locationSubscription = _location.onLocationChanged
//         .listen((LocationData currentLocation) async {
//       _locationInfo = "Lat: ${currentLocation.latitude}, "
//           "Lng: ${currentLocation.longitude}, "
//           "Time: ${DateTime.now()}";

//       if (_updateTimer == null || !_updateTimer!.isActive) {
//         _updateTimer =
//             Timer.periodic(const Duration(minutes: 30), (timer) async {
//           List<geoCoding.Placemark> placemarks =
//               await geoCoding.placemarkFromCoordinates(
//                   currentLocation.latitude!, currentLocation.longitude!);

//           log("placemarks = ${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}");

//           Map body = {
//             "userId": loginStorage.getUserId(),
//             "lat": currentLocation.latitude,
//             "long": currentLocation.longitude,
//             "areaName":
//                 "${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}",
//             "updatedAt": DateTime.now().toIso8601String()
//           };

//           log("body in saveLocation = $body");
//           var responce = await postRequest.customPostRequest(
//               body: body, url: AppUrls.updateLocation);

//           log("responce in update location = $responce");
//         });
//       }
//     });

//     // You can save the location to a database or send it to a server here
//     log('Location: $_locationInfo');
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
// }
