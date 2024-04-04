import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transitrack_web/style/constants.dart';

Future<bool> requestLocationPermission(BuildContext context) async {
  PermissionStatus permissionStatus = await Permission.location.request();

  if (permissionStatus == PermissionStatus.granted) {
    return true;
  }

  AwesomeDialog(
          context: context,
          width: 400,
          dialogType: DialogType.error,
          padding: const EdgeInsets.all(Constants.defaultPadding),
          desc: "To use GPS features, allow GPS tracking.")
      .show();
  return false;
}
