import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/customer_call_request_helper.dart';
import '../models/customer_call_request.dart';
import '../values/api_end_points.dart';
import '../values/app_routes.dart';
import '../values/static_values.dart';
import '../widgets/circular_loader_widget.dart';

class CustomerCallRequestTechnicianListTileWidget extends StatefulWidget {
  const CustomerCallRequestTechnicianListTileWidget({
    required this.callRequestTechnicianData,
    required this.userRole,
    this.onTap,
    this.onLongPress,
    required this.ctx,
    Key? key,
  }) : super(key: key);
  final void Function()? onTap;
  final CustomerCallRequest callRequestTechnicianData;
  final void Function()? onLongPress;
  final BuildContext ctx;
  final String? userRole;

  @override
  State<CustomerCallRequestTechnicianListTileWidget> createState() =>
      _CustomerCallRequestTechnicianListTileWidgetState();
}

class _CustomerCallRequestTechnicianListTileWidgetState
    extends State<CustomerCallRequestTechnicianListTileWidget> {
  // var _isLoading = true;
  // bool _isInit = true;

  @override
  Widget build(BuildContext context) {
    // return ListTile(
    //   leading: const CircleAvatar(
    //     child: Text('A'),
    //   ),
    //   subtitle: Text(widget.callRequestData.status ?? 'null'),
    // );

    return FutureBuilder<Map<String, dynamic>>(
        future: CustomerCallRequestHelper()
            .getCustomerCallRequestTechnicianCombineData(
                customerCallRequestTechnicianData:
                    widget.callRequestTechnicianData),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularLoaderWidget();
          } else {
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  snapshot.data!['customer'].fullName
                      .substring(0, 1)
                      .toUpperCase(),
                ),
              ),
              title: Text(snapshot.data!['customer'].fullName),
              subtitle: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (snapshot.data!['technician'] != null)
                    Text(snapshot.data!['technician'].fullName),
                  if (snapshot.data!['serviceProvider'] != null)
                    Text(snapshot.data!['serviceProvider'].fullName),
                  // Text(callDetails.serviceId!),
                  // Text('Navsari'),
                ],
              ),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                // if (widget.userRole == appRoleTechnician)
                //   IconButton(
                //     icon: const FaIcon(
                //       FontAwesomeIcons.check,
                //       color: Colors.green,
                //     ),
                //     onPressed: () async {
                //       widget.callRequestTechnicianData.status = 'accepted';

                //       await CustomerCallRequestHelper()
                //           .addUpdateCallRequestTechnician(
                //         callRequestTechnician: widget.callRequestTechnicianData,
                //       );
                //     },
                //   ),
                // if ((widget.userRole == appRoleAdmin ||
                //         widget.userRole == appRoleServiceProvider) &&
                //     widget.callRequestTechnicianData.status == 'accepted')
                if (widget.userRole != appRoleCustomer &&
                    widget.callRequestTechnicianData.status != 'accepted')
                  TextButton(
                    child: const Text('Create Call'),
                    onPressed: () async {
                      final callRequestInstance = FirebaseFirestore.instance
                          .collection(apiCustomerCallRequests)
                          .doc(widget.callRequestTechnicianData.id);
                      if (widget.userRole == appRoleServiceProvider) {
                        Navigator.of(context).pushNamed(
                          appRouteAddEditCallRequestsScreen,
                          arguments: {
                            'customerCallRequestId':
                                widget.callRequestTechnicianData.id
                          },
                        ).then((value) async {
                          if (value == true) {
                            await callRequestInstance
                                .update({'status': 'accepted'});
                          }
                        });
                      } else {
                        var customerCallRequestData =
                            await CustomerCallRequestHelper()
                                .getCustomerCallRequestDetails(
                                    widget.callRequestTechnicianData.id);
                        await CustomerCallRequestHelper()
                            .createCallFromCustomerRequest(
                          customerCallRequestData: customerCallRequestData!,
                        );
                        await callRequestInstance
                            .update({'status': 'accepted'});
                      }
                    },
                  ),
                if ((widget.userRole == appRoleCustomer &&
                        widget.callRequestTechnicianData.status !=
                            'accepted') ||
                    (widget.userRole == appRoleServiceProvider &&
                        widget.callRequestTechnicianData.status !=
                            'accepted') ||
                    (widget.userRole == appRoleTechnician &&
                        widget.callRequestTechnicianData.status != 'accepted'))
                  IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.xmark,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      // await FirebaseFirestore.instance
                      //     .collection(apiServiceprovidertechnician)
                      //     .doc(widget.requestData.id)
                      //     .delete();
                    },
                  ),
              ]),
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
            );
          }
        });
  }
}
