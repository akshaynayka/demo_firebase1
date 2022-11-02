import '../values/app_routes.dart';
import '../values/string_en.dart';

import '../models/user.dart';
import '../common_methods/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UserListTileWidget extends StatelessWidget {
  const UserListTileWidget({
    required this.userData,
    required this.userPermission,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);
  final User userData;
  final bool userPermission;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          userData.fullName!.substring(0, 1).toUpperCase(),
          textScaleFactor: 1.5,
        ),
      ),
      title: Text(userData.fullName!),
      subtitle: Text(userData.mobile!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: Colors.green,
            ),
            onPressed: () async {
              await sendWhatsAppMessage(
                  mobileNumber: userData.mobile!, message: 'hello');
            },
          ),
          IconButton(
            icon: const FaIcon(
              Icons.phone_outlined,
              color: Colors.blue,
            ),
            onPressed: () async {
              await makeCall(mobileNumber: userData.mobile!);
            },
          ),
          if (userPermission)
            PopupMenuButton(
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'permission',
                  child: Text(appTitlePermissions),
                ),
              ],
              onSelected: (value) {
                if (value == 'permission') {
                  Navigator.of(context).pushNamed(
                    appRouteUserPermissionScreen,
                    arguments: userData.id,
                  );
                }
              },
            ),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
