import '../helpers/call_requests_helper.dart';
import '../models/call_request_technician.dart';
import '../widgets/call_request_technician_list_lite_widget.dart';
import '../values/string_en.dart';
import '../widgets/circular_loader_widget.dart';
import 'package:flutter/material.dart';

class CallRequestTechnicianListWidget extends StatelessWidget {
  const CallRequestTechnicianListWidget({
    this.status,
    this.technicianId,
    this.serviceProviderId,
    this.userRole,
    // required this.addEditPermission,
    Key? key,
  }) : super(key: key);
  final String? status;
  final String? technicianId;
  final String? serviceProviderId;

  final String? userRole;
  // final bool addEditPermission;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CallRequestTechnician>>(
      // stream: FirebaseFirestore.instance
      //     .collection(apiCallRequestTechnicians)
      //     .where('technicianId', isEqualTo: null)
      //     .snapshots(),
      stream: CallRequestsHelper().getAllCallRequestTechnicianStream(
        userRole: userRole!,
        technicianId: technicianId,
        status: status,
        serviceProviderId: serviceProviderId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(appTitleSomethingWentWrong);
        } else if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularLoaderWidget();
          }
          final callList = snapshot.data!;
          return ListView.builder(
            itemCount: callList.length,
            itemBuilder: (context, index) {
              return CallRequestTechnicianListTileWidget(
                callRequestTechnicianData: callList[index],
                userRole: userRole,
                ctx: context,
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
