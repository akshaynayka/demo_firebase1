import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/call_requests_helper.dart';
import '../helpers/calls_helper.dart';
import '../models/call_request_technician.dart';
import '../values/api_end_points.dart';
import '../values/static_values.dart';
import '../widgets/circular_loader_widget.dart';

class CallRequestTechnicianListTileWidget extends StatefulWidget {
  const CallRequestTechnicianListTileWidget({
    required this.callRequestTechnicianData,
    required this.userRole,
    this.onTap,
    this.onLongPress,
    required this.ctx,
    Key? key,
  }) : super(key: key);
  final void Function()? onTap;
  final CallRequestTechnician callRequestTechnicianData;
  final void Function()? onLongPress;
  final BuildContext ctx;
  final String? userRole;

  @override
  State<CallRequestTechnicianListTileWidget> createState() =>
      _CallRequestTechnicianListTileWidgetState();
}

class _CallRequestTechnicianListTileWidgetState
    extends State<CallRequestTechnicianListTileWidget> {
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

    return
        // _isLoading
        //     ? const CircularLoaderWidget()
        //     :

        FutureBuilder<Map<String, dynamic>>(
            future: CallRequestsHelper().getCallRequestTechnicianCombineData(
                callRequestTechnicianData: widget.callRequestTechnicianData),
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
                      Text(snapshot.data!['technician'].fullName),
                      if (snapshot.data!['serviceProvider'] != null)
                        Text(snapshot.data!['serviceProvider'].fullName),
                      // Text(callDetails.serviceId!),
                      // Text('Navsari'),
                    ],
                  ),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (widget.userRole == appRoleTechnician &&
                        widget.callRequestTechnicianData.status == 'requested')
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.check,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          widget.callRequestTechnicianData.status = 'accepted';

                          await CallRequestsHelper()
                              .addUpdateCallRequestTechnician(
                            callRequestTechnician:
                                widget.callRequestTechnicianData,
                          );
                        },
                      ),
                    if ((widget.userRole == appRoleAdmin ||
                            widget.userRole == appRoleServiceProvider) &&
                        widget.callRequestTechnicianData.status == 'accepted')
                      TextButton(
                        child: const Text('Create Call'),
                        onPressed: () async {
                          final callDetails = await CallsHelper()
                              .getCallDetailsFromRequestId(widget
                                  .callRequestTechnicianData.callRequestId);
                          if (callDetails != null) {
                            final callInstance = FirebaseFirestore.instance
                                .collection(apiCalls)
                                .doc(callDetails.id);
                            await callInstance.update({
                              'technicianId':
                                  widget.callRequestTechnicianData.technicianId
                            });
                          } else {
                            var callRequestData = await CallRequestsHelper()
                                .getCallRequestDetails(widget
                                    .callRequestTechnicianData.callRequestId);

                            await CallsHelper().createCallFromRequest(
                                callRequestData: callRequestData!,
                                technicianId: widget
                                    .callRequestTechnicianData.technicianId!);

                            final callRequestInstance = FirebaseFirestore
                                .instance
                                .collection(apiCallRequests)
                                .doc(callRequestData.id);
                            await callRequestInstance
                                .update({'status': 'assigned'});
                            await CallRequestsHelper()
                                .updateCallRequestTechniciansStatus(
                                    callRequestId: callRequestInstance.id,
                                    technicianId: widget
                                        .callRequestTechnicianData
                                        .technicianId!);
                          }
                          // callRequestData!.technicianId =
                          //     widget.callRequestTechnicianData.technicianId;
                          // print(callRequestData!.toJson());

                          // widget.callRequestTechnicianData.status = 'accepted';

                          // await CallRequestsHelper()
                          //     .addUpdateCallRequestTechnician(
                          //   callRequestTechnician:
                          //       widget.callRequestTechnicianData,
                          // );
                        },
                      ),
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
