import '../helpers/call_requests_helper.dart';
import '../models/call_request.dart';
import '../values/app_routes.dart';
import '../widgets/call_request_list_lite_widget.dart';
import '../values/string_en.dart';
import '../widgets/circular_loader_widget.dart';
import 'package:flutter/material.dart';

class CallRequestListWidget extends StatelessWidget {
  const CallRequestListWidget({
    this.status,
    this.serviceProviderId,
    this.userRole,
    required this.addEditPermission,
    Key? key,
  }) : super(key: key);
  final String? status;
  final String? serviceProviderId;

  final String? userRole;
  final bool addEditPermission;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CallRequest>>(
      stream: CallRequestsHelper().getAllCallRequestsStream(
          status: status,
          userRole: userRole!,
          serviceProviderId: serviceProviderId),
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
                child: CallRequestListTileWidget(
                  callRequestData: callList[index],
                  userRole: userRole!,
                  ctx: context,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      appRouteAddEditCallRequestsScreen,
                      arguments: {
                        'callRequestId': callList[index].id,
                      },
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
