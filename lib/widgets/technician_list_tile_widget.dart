import 'package:demo_firebase1/values/app_routes.dart';
import 'package:demo_firebase1/values/static_values.dart';
import 'package:demo_firebase1/values/string_en.dart';

import '../values/api_end_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../helpers/technician_helper.dart';
import '../models/service_provider_technician_request.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../common_methods/common_methods.dart';
import '../models/technician.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TechnicianListTileWidget extends StatelessWidget {
  const TechnicianListTileWidget({
    required this.technicianDetails,
    required this.userData,
    this.changePermission = false,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);

  final Technician technicianDetails;
  final bool changePermission;
  final User userData;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    final serviceProviderId = Provider.of<UserProvider>(context, listen: false)
        .currentServiceProviderId;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          technicianDetails.fullName!.substring(0, 1).toUpperCase(),
          textScaleFactor: 1.5,
        ),
      ),
      title: Text(technicianDetails.fullName!),
      subtitle: Text(technicianDetails.mobile ?? ''),
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
                  mobileNumber: technicianDetails.mobile!, message: 'hello');
            },
          ),
          IconButton(
            icon: const FaIcon(
              Icons.phone_outlined,
              color: Colors.blue,
            ),
            onPressed: () async {
              await makeCall(mobileNumber: technicianDetails.mobile!);
            },
          ),
          IconButton(
            icon: const FaIcon(
              Icons.pin_drop_outlined,
              color: Colors.red,
            ),
            onPressed: () async {
              await openMapLocation(
                latitude: technicianDetails.latitude!,
                longitude: technicianDetails.longitude!,
              );
            },
          ),
          if (userData.role == appRoleAdmin)
            PopupMenuButton(
              itemBuilder: (ctx) => [
                if (changePermission)
                  const PopupMenuItem(
                    value: 'permission',
                    child: Text(appTitlePermissions),
                  ),
              ],
              onSelected: (value) {
                if (value == 'permission') {
                  Navigator.of(context).pushNamed(
                    appRouteUserPermissionScreen,
                    arguments: technicianDetails.userId,
                  );
                }
              },
            ),

          // if (serviceProviderId != null)
          //   StreamBuilder(
          //     stream: FirebaseFirestore.instance
          //         .collection(apiServiceprovidertechnician)
          //         .where('requestedBy', isEqualTo: userData.role)
          //         .where('technicianId', isEqualTo: technicianDetails.id)
          //         .snapshots(),
          //     builder: (context,
          //         AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          //       final data = snapshot.data;
          //       if (snapshot.hasData) {
          //         if (data!.docs.isEmpty) {
          //           return PopupMenuButton(
          //             itemBuilder: (ctx) => [
          //               const PopupMenuItem(
          //                 value: 'sendRequest',
          //                 child: Text('Send Request'),
          //               )
          //             ],
          //             onSelected: (value) async {
          //               if (value == 'sendRequest') {
          //                 final data = ServiceProviderTechnicianRequest(
          //                   id: null,
          //                   requestedBy: userData.role!,
          //                   serviceProviderId: serviceProviderId,
          //                   technicianId: technicianDetails.id!,
          //                   status: 'requested',
          //                 );
          //                 await TechnicianHelper()
          //                     .addServiceProviderTechnicianData(
          //                         requestData: data);
          //                 //   appRouteAddressListScreen,
          //                 //   arguments: customerData.userId,
          //                 // );
          //               }
          //             },
          //           );
          //         }
          //         return PopupMenuButton(
          //           itemBuilder: (ctx) => [
          //             const PopupMenuItem(
          //               value: 'cancelTechnician',
          //               child: Text('Cancel Request'),
          //             )
          //           ],
          //           onSelected: (value) async {
          //             final serviceProviderTechnicianInstance =
          //                 FirebaseFirestore.instance
          //                     .collection(apiServiceprovidertechnician)
          //                     .where('requestedBy', isEqualTo: userData.role)
          //                     .where('technicianId',
          //                         isEqualTo: technicianDetails.id);

          //             final data =
          //                 await serviceProviderTechnicianInstance.get();
          //             var docId = '';
          //             if (data.docs.isNotEmpty) {
          //               docId = data.docs[0].id;
          //             }
          //             await FirebaseFirestore.instance
          //                 .collection(apiServiceprovidertechnician)
          //                 .doc(docId)
          //                 .delete();
          //           },
          //         );
          //       }
          //       return const SizedBox();
          //     },
          //   )

          if (serviceProviderId != null)
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(apiServiceprovidertechnician)
                  .where('requestedBy', isEqualTo: userData.role)
                  .where('technicianId', isEqualTo: technicianDetails.id)
                  .snapshots(),
              builder: (ctx,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                final data = snapshot.data;
                if (snapshot.hasData) {
                  if (data!.docs.isEmpty) {
                    return IconButton(
                      onPressed: () async {
                        final data = ServiceProviderTechnicianRequest(
                          id: null,
                          requestedBy: userData.role!,
                          serviceProviderId: serviceProviderId,
                          technicianId: technicianDetails.id!,
                          status: 'requested',
                        );
                        await TechnicianHelper()
                            .addServiceProviderTechnicianData(
                                requestData: data);
                        //   appRouteAddressListScreen,
                        //   arguments: customerData.userId,
                        // );
                      },
                      icon: const Icon(
                        Icons.send_outlined,
                        color: Colors.blue,
                      ),
                    );

                    // return PopupMenuButton(
                    //   itemBuilder: (ctx) => [
                    //     const PopupMenuItem(
                    //       value: 'sendRequest',
                    //       child: Text('Send Request'),
                    //     )
                    //   ],
                    //   onSelected: (value) async {
                    //     if (value == 'sendRequest') {
                    //       final data = ServiceProviderTechnicianRequest(
                    //         id: null,
                    //         requestedBy: userData.role!,
                    //         serviceProviderId: serviceProviderId,
                    //         technicianId: technicianDetails.id!,
                    //         status: 'requested',
                    //       );
                    //       await TechnicianHelper()
                    //           .addServiceProviderTechnicianData(
                    //               requestData: data);
                    //       //   appRouteAddressListScreen,
                    //       //   arguments: customerData.userId,
                    //       // );
                    //     }
                    //   },
                    // );

                  }

                  return IconButton(
                    onPressed: () async {
                      final serviceProviderTechnicianInstance =
                          FirebaseFirestore.instance
                              .collection(apiServiceprovidertechnician)
                              .where('requestedBy', isEqualTo: userData.role)
                              .where('technicianId',
                                  isEqualTo: technicianDetails.id);

                      final data =
                          await serviceProviderTechnicianInstance.get();
                      var docId = '';
                      if (data.docs.isNotEmpty) {
                        docId = data.docs[0].id;
                      }
                      await FirebaseFirestore.instance
                          .collection(apiServiceprovidertechnician)
                          .doc(docId)
                          .delete();
                    },
                    icon: const Icon(
                      Icons.cancel_schedule_send_outlined,
                      color: Colors.red,
                    ),
                  );

                  // return PopupMenuButton(
                  //   itemBuilder: (ctx) => [
                  //     const PopupMenuItem(
                  //       value: 'cancelTechnician',
                  //       child: Text('Cancel Request'),
                  //     )
                  //   ],
                  //   onSelected: (value) async {
                  //     final serviceProviderTechnicianInstance =
                  //         FirebaseFirestore.instance
                  //             .collection(apiServiceprovidertechnician)
                  //             .where('requestedBy', isEqualTo: userData.role)
                  //             .where('technicianId',
                  //                 isEqualTo: technicianDetails.id);

                  //     final data =
                  //         await serviceProviderTechnicianInstance.get();
                  //     var docId = '';
                  //     if (data.docs.isNotEmpty) {
                  //       docId = data.docs[0].id;
                  //     }
                  //     await FirebaseFirestore.instance
                  //         .collection(apiServiceprovidertechnician)
                  //         .doc(docId)
                  //         .delete();
                  //   },
                  // );
                }
                return const SizedBox();
              },
            )
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
