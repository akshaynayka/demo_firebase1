import '../models/service.dart';
import 'package:flutter/material.dart';

class ServiceListTileWidget extends StatelessWidget {
  const ServiceListTileWidget(
      {required this.serviceDetails, this.onTap, Key? key})
      : super(key: key);
  final void Function()? onTap;
  final Service serviceDetails;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          serviceDetails.name!.substring(0, 1).toUpperCase(),
          textScaleFactor: 1.5,
        ),
      ),
      title: Text(serviceDetails.name!),
      subtitle: Text(serviceDetails.etimatedDuration!),
      onTap: onTap,
    );
  }
}
