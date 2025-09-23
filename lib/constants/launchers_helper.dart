import 'package:leadmanagementsystem/controllers/project_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherHelper {
  /// Opens the given URL in the external browser.
  /// Displays an error message if the URL cannot be opened.
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.tryParse(url) ?? Uri();
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      customSnackBar("Error", "Unable to open the URL: $url");
    }
  }

  /// Initiates a phone call to the given number.
  /// Displays an error message if the call cannot be made.
  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      customSnackBar("Error", "Unable to make a call to: $phoneNumber");
    }
  }

  static Future<void> openMap(
      {required double latitude, required double longitude}) async {
    final googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
          Uri.parse(
            googleMapsUrl,
          ),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }
}
