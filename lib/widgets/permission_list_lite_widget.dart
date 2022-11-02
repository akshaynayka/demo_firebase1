import '../models/permission_data.dart';
import 'package:flutter/material.dart';

class PermissionListTileWidget extends StatelessWidget {
  const PermissionListTileWidget(
      {required this.permissionDetails, this.onTap, Key? key})
      : super(key: key);
  final void Function()? onTap;
  final PermissionData permissionDetails;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          permissionDetails.name!.substring(0, 1).toUpperCase(),
          textScaleFactor: 1.5,
        ),
      ),
      title: Text(permissionDetails.name!),
      subtitle: Text(permissionDetails.name!),
      onTap: onTap,
    );
  }
}
