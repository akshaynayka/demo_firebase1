import '../helpers/calls_helper.dart';
import '../models/call.dart';
import '../values/app_routes.dart';
import '../values/string_en.dart';
import '../widgets/call_list_lite_widget.dart';
import '../widgets/circular_loader_widget.dart';
import 'package:flutter/material.dart';

class CallListWidget extends StatelessWidget {
  const CallListWidget({
    this.status,
    this.technicianId,
    this.serviceProviderId,
    this.customerId,
    this.userRole,
    required this.addEditPermission,
    Key? key,
  }) : super(key: key);
  final String? status;
  final String? technicianId;
  final String? serviceProviderId;
  final String? customerId;

  final String? userRole;
  final bool addEditPermission;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Call>>(
      stream: CallsHelper().getAllCallsStream(
        statusList: [status],
        userRole: userRole!,
        technicianId: technicianId,
        serviceProviderId: serviceProviderId,
        customerId: customerId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(appTitleSomethingWentWrong);
        } else if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularLoaderWidget();
          }
          final callList = snapshot.data;
          return ListView.builder(
            itemCount: callList!.length,
            itemBuilder: (context, index) {
              return Card(
                child: CallListTileWidget(
                  callData: callList[index],
                  ctx: context,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      appRouteAddEditCallScreen,
                      arguments: callList[index].id,
                    );
                  },
                ),
              );
            },
          );
        } else {
          return const CircularLoaderWidget();
        }
      },
    );
  }
}
