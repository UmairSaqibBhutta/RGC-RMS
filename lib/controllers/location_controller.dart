import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:geolocator/geolocator.dart';

import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/users_location_model.dart';

class LocationController extends GetxController {
  List<LocationsData> usersLocationList = [];
  bool loadUserLocations = false;

  /// fetch location other than ceo
  updateWorkerLocation() {
    log("updateWorkerLocation is fired");
    if (loginStorage.getUserRole() != "Group Director-CEO") {
      initializeLocation();
    }
  }

  Future<bool> getUserLocation(String id) async {
    var responce =
        await getRequest.customGetRequest(apiPath: ApiUrls.getUserLocation);

    if (responce != null) {
      if (responce["status"] == true) {
        Get.snackbar("Success", "User location fetched successfully");

        return true;
      } else {
        Get.snackbar("Success", "User location could not be fetched");

        return false;
      }
    } else {
      Get.snackbar("Success", "User location could not be fetched");

      return false;
    }
  }

  Future<void> initializeLocation() async {
    Position position = await Geolocator.getCurrentPosition();

    log("position = $position");
    // _locationData = await location.getLocation();
    uploadLocationToServer(position.latitude, position.longitude);
  }

  Future<void> uploadLocationToServer(double lat, double long) async {
    List<geoCoding.Placemark> placemarks =
        await geoCoding.placemarkFromCoordinates(lat, long);
    log("uploadLocationToServer fired");
    log("placemarks = ${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}");

    Map body = {
      "userId": loginStorage.getUserId(),
      "lat": lat,
      "long": long,
      "areaName":
          "${placemarks[0].locality} ${placemarks[0].subLocality} ${placemarks[0].name}",
      "updatedAt": DateTime.now().toIso8601String()
    };

    log("body in saveLocation = $body");
    var responce = await postRequest.customPostRequest(
        body: body, url: ApiUrls.updateLocation);

    log("responce in update location = $responce");
  }

  updateLocationLoading(bool val) {
    loadUserLocations = val;
    update();
  }

  void getAllUsersLocationList() async {
    updateLocationLoading(true);
    var responce =
        await getRequest.customGetRequest(apiPath: ApiUrls.getUserSkipCeo);
    updateLocationLoading(false);

    if (responce != null) {
      if (responce['status'] == true) {
        UsersLocationModel locationModel =
            UsersLocationModel.fromJson(responce);

        usersLocationList = locationModel.data ?? [];

        // Get.snackbar("Success", "User list fetched successfully");
      } else {
        usersLocationList = [];
        Get.snackbar("Failed", "User list could not be fetched");
      }
    } else {
      usersLocationList = [];

      Get.snackbar("Failed", "User list could not be fetched");
    }
  }
}
