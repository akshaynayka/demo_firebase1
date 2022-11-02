import '../helpers/reset_data_helper.dart';
import '../widgets/restart_app_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

String removeSpaceFromString(String value) {
  final string = value.replaceAll(RegExp(r"\s+"), "");
  return string;
}

displaySnackbar({required BuildContext context, required String msg}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
    ),
  );
}

Future<void> sendWhatsAppMessage(
    {required String mobileNumber, required String message}) async {
  String url = "whatsapp://send?phone=$mobileNumber&text=$message";
  await canLaunchUrl(Uri.parse(url))
      ? launchUrl(Uri.parse(url))
      : debugPrint('Can\'t open whatsapp');
}

Future<void> makeCall({required String mobileNumber}) async {
  String url = "tel:$mobileNumber";
  await canLaunchUrl(Uri.parse(url))
      ? launchUrl(Uri.parse(url))
      : debugPrint('Can\'t open Phone');
}

Future<void> openMapLocation(
    {required String latitude, required String longitude}) async {
  final String googleMapslocationUrl =
      "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

  final String url = Uri.encodeFull(googleMapslocationUrl);

  await canLaunchUrl(Uri.parse(url))
      ? launchUrl(Uri.parse(url))
      : debugPrint('Can\'t open Maps');
}

Future<void> showErrorDialog(String message, BuildContext context) async {
  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Error Occurred'),
      content: Text(message),
      actions: [
        TextButton(
          child: Text(
            'Okay',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    ),
  );
}

Future<bool> willPopExitCallback(BuildContext context) async {
  showExitAppDialog(context);
  return true;
}

Future<void> requestLocationPermission() async {
  // final serviceStatusLocation = await Permission.locationWhenInUse.isGranted;

  // bool isLocation = serviceStatusLocation == ServiceStatus.enabled;

  final status = await Permission.location.request();

  if (status == PermissionStatus.granted) {
    debugPrint('Permission Granted');
  } else if (status == PermissionStatus.denied) {
    debugPrint('Permission denied');
  } else if (status == PermissionStatus.permanentlyDenied) {
    debugPrint('Permission Permanently Denied');
    await openAppSettings();
  }
}

Future<void> showExitAppDialog(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: const Text('Do you realy want to exit'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor)),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      SystemNavigator.pop();
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ));
}

Future<void> showResetDataDialog(BuildContext context) async {
  await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: const Text('Do you realy want to reset data'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor)),
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).primaryColor)),
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await ResetDataHelper().resetAllData();
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ));
}

Future<void> showLogoutAppDialog(BuildContext context) async {
  // bool value = false;
  final restartFunction = (() {
    RestartAppWidget.restartApp(context);
  });
  await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: const Text('Do you realy want to Logout'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      // value = false;
                      Navigator.of(ctx).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      // value = true;
                      Navigator.of(ctx).pop();
                      await FirebaseAuth.instance.signOut();
                      restartFunction();
                      final GoogleSignIn googleSignIn =
                          GoogleSignIn(scopes: <String>["email"]);
                      await googleSignIn.signOut();
                    },
                  ),
                ],
              ),
            ],
          ));

  // return value;
}
