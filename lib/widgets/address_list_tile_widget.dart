import '../common_methods/common_methods.dart';
import '../models/address.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AddressListTileWidget extends StatelessWidget {
  const AddressListTileWidget({
    required this.addressData,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);
  final Address addressData;

  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          addressData.name!.substring(0, 1).toUpperCase(),
          textScaleFactor: 1.5,
        ),
      ),
      title: Text(addressData.name!),
      subtitle: Text(addressData.city!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const FaIcon(
              Icons.pin_drop_outlined,
              color: Colors.red,
            ),
            onPressed: () async {
              await openMapLocation(
                latitude: addressData.latitude!,
                longitude: addressData.longitude!,
              );
            },
          ),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
