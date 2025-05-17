// import 'package:background_locator_2/background_locator.dart';
// import 'package:background_locator_2/location_dto.dart';
// import 'package:background_locator_2/settings/android_settings.dart';
// import 'package:background_locator_2/settings/ios_settings.dart';
// import 'package:get/get.dart';
// import 'package:leadmanagementsystem/api_urls.dart';
// import 'package:leadmanagementsystem/constants.dart';
// import 'package:leadmanagementsystem/main.dart';

// class LocationController extends GetxController {
//   /// fetch location other than ceo
//   updateWorkerLocation() {
//     // if (loginStorage.getUserRole() != "Group Director-CEO") {
//     //   startBackgroundLocator();
//     // }
//       startBackgroundLocator();

//   }

//   void locationCallback(LocationDto locationDto) {
//     print('Location received: ${locationDto.toString()}');
//     // You can save the location to a database or send it to a server here.


//   }

//   void notificationCallback() {
//     print('Notification clicked');
//   }

//   Future<void> startBackgroundLocator() async {
//     await BackgroundLocator.initialize();
//     BackgroundLocator.registerLocationUpdate(locationCallback,
//         autoStop: false,
//         // initCallback: notificationCallback,
//         initDataCallback: {}, // Optional
//         disposeCallback: () => print('Locator disposed'),
//         androidSettings: const AndroidSettings(
//           interval: 60000 * 10,
//         ),
//         iosSettings: const IOSSettings(showsBackgroundLocationIndicator: true));
//   }

//   void startLocationUpdates() {
//     startBackgroundLocator();
//   }

//   void stopLocationUpdates() {
//     stopBackgroundLocator();
//   }

//   void stopBackgroundLocator() {
//     BackgroundLocator.unRegisterLocationUpdate();
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
