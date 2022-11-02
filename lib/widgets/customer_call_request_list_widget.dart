import 'package:flutter/material.dart';
import '../helpers/customer_call_request_helper.dart';
import '../models/customer_call_request.dart';
import '../values/string_en.dart';
import '../widgets/circular_loader_widget.dart';
import '../widgets/customer_call_request_technician_list_lite_widget.dart';

class CustomerCallRequestListWidget extends StatelessWidget {
  const CustomerCallRequestListWidget({
    required this.userRole,
    required this.technicianId,
    required this.serviceProvider,
    required this.customerId,
    required this.status,
    
    Key? key,
  }) : super(key: key);
  final String userRole;
  final String technicianId;
  final String serviceProvider;
  final String customerId;
  final String status;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CustomerCallRequest>>(
      stream: CustomerCallRequestHelper().getCustomerCallRequestStream(
        status: status,
        userRole: userRole,
        technicianId: technicianId,
        serviceProviderId: serviceProvider,
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
            itemCount: callList?.length,
            itemBuilder: (context, index) {
              return Card(
                // child: CallListTileWidget(
                //   callData: callList[index],
                //   ctx: context,
                //   onTap: () {
                //     Navigator.of(context).pushNamed(
                //       appRouteAddEditCallScreen,
                //       arguments: callList[index].id,
                //     );
                //   },
                // ),

                child: CustomerCallRequestTechnicianListTileWidget(
                    callRequestTechnicianData: callList![index],
                    userRole: userRole,
                    ctx: context),
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
