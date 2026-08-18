import 'package:geocoding/geocoding.dart' as geoCoding;
// import 'package:geolocator/geolocator.dart';

import 'dart:async';
import 'package:leadmanagementsystem/utils/dev_log.dart';

import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/api_urls.dart';
import 'package:leadmanagementsystem/main.dart';
import 'package:leadmanagementsystem/models/users_location_model.dart';
import 'package:leadmanagementsystem/widgets/custom_snackbar.dart';
import 'package:location/location.dart';

class LocationController extends GetxController {
  List<LocationsData> usersLocationList = [];
  bool loadUserLocations = false;
  Location location = Location();

  LocationData? locationData;

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
        CustomSnackbar.success("User location fetched successfully");

        return true;
      } else {
        CustomSnackbar.error("User location could not be fetched");

        return false;
      }
    } else {
      CustomSnackbar.error("User location could not be fetched");

      return false;
    }
  }

  Future<void> initializeLocation() async {
    // Position position = await Geolocator.getCurrentPosition();
    locationData = await location.getLocation();

    log("position = $locationData");
    if (locationData != null) {
      // _locationData = await location.getLocation();
      uploadLocationToServer(locationData!.latitude!, locationData!.longitude!);
    }
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
        CustomSnackbar.error("User list could not be fetched");
      }
    } else {
      usersLocationList = [];

      CustomSnackbar.error("User list could not be fetched");
    }
  }

  Future<LocationModel?> getCurrentAddress() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          CustomSnackbar.error("Location service disabled");
          return null;
        }
      }

      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) {
          CustomSnackbar.error("Location permission denied");
          return null;
        }
      }

      /// ðŸ“ Get Location
      LocationData? locationData = await location.getLocation();

      double lat = locationData.latitude!;
      double long = locationData.longitude!;

      /// ðŸŒ Convert to Address
      List<geoCoding.Placemark> placemarks =
          await geoCoding.placemarkFromCoordinates(lat, long);

      final place = placemarks.first;

      String address =
          "${place.locality ?? ""} ${place.subLocality ?? ""} ${place.name ?? ""}"
              .trim();

      log("ðŸ“ Current Address: $address");

      /// âœ… Return LocationModel
      return LocationModel(
        address: address,
        lat: lat.toString(),
        long: long.toString(),
      );
    } catch (e) {
      log("âŒ Location Exception: $e");
      CustomSnackbar.error("Failed to get location");
      return null;
    }
  }
}

class LocationModel {
  String? address;
  String? lat;
  String? long;

  LocationModel({
    this.address,
    this.lat,
    this.long,
  });
}
