import '../values/app_routes.dart';
import '../values/string_en.dart';

import '../common_methods/common_methods.dart';
import '../models/customer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomerListTileWidget extends StatelessWidget {
  const CustomerListTileWidget({
    required this.customerData,
    required this.addressPermission,
    this.changePermission = false,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);
  final Customer customerData;
  final bool addressPermission;
  final bool changePermission;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          customerData.fullName!.substring(0, 1).toUpperCase(),
          textScaleFactor: 1.5,
        ),
      ),
      title: Text(customerData.fullName!),
      subtitle: Text(customerData.mobile ?? ''),
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
                  mobileNumber: customerData.mobile!, message: 'hello');
            },
          ),
          IconButton(
            icon: const FaIcon(
              Icons.phone_outlined,
              color: Colors.blue,
            ),
            onPressed: () async {
              await makeCall(mobileNumber: customerData.mobile!);
            },
          ),
          IconButton(
            icon: const FaIcon(
              Icons.pin_drop_outlined,
              color: Colors.red,
            ),
            onPressed: () async {
              await openMapLocation(
                latitude: customerData.latitude!,
                longitude: customerData.longitude!,
              );
            },
          ),
          if (addressPermission)
            PopupMenuButton(
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'address',
                  child: Text(appTitleAddress),
                ),
                if (changePermission)
                  const PopupMenuItem(
                    value: 'permission',
                    child: Text(appTitlePermissions),
                  ),
              ],
              onSelected: (value) {
                if (value == 'address') {
                  Navigator.of(context).pushNamed(
                    appRouteAddressListScreen,
                    arguments: customerData.userId,
                  );
                } else if (value == 'permission') {
                  Navigator.of(context).pushNamed(
                    appRouteUserPermissionScreen,
                    arguments: customerData.userId,
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
