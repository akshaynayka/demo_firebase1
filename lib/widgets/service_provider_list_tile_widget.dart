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
import '../models/service_provider.dart';
import '../common_methods/common_methods.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ServiceProviderListTileWidget extends StatelessWidget {
  const ServiceProviderListTileWidget({
    required this.serviceProviderData,
    required this.userData,
    this.changePermission = false,
    this.onTap,
    this.onLongPress,
    Key? key,
  }) : super(key: key);
  final ServiceProvider serviceProviderData;
  final User userData;
  final bool changePermission;

  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  Widget build(BuildContext context) {
    final technicianId =
        Provider.of<UserProvider>(context, listen: false).currentTechnicianId;
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          serviceProviderData.fullName!.substring(0, 1).toUpperCase(),
          textScaleFactor: 1.5,
        ),
      ),
      title: Text(serviceProviderData.fullName!),
      subtitle: Text(serviceProviderData.mobile ?? ''),
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
                  mobileNumber: serviceProviderData.mobile!, message: 'hello');
            },
          ),
          IconButton(
            icon: const FaIcon(
              Icons.phone_outlined,
              color: Colors.blue,
            ),
            onPressed: () async {
              await makeCall(mobileNumber: serviceProviderData.mobile!);
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
                    arguments: serviceProviderData.userId,
                  );
                }
              },
            ),
          if (technicianId != null)
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(apiServiceprovidertechnician)
                    .where('requestedBy', isEqualTo: userData.role)
                    .where('serviceProviderId',
                        isEqualTo: serviceProviderData.id)
                    .snapshots(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  final data = snapshot.data;
                  if (snapshot.hasData) {
                    if (data!.docs.isEmpty) {
                      return IconButton(
                        onPressed: () async {
                          final data = ServiceProviderTechnicianRequest(
                            id: null,
                            requestedBy: userData.role!,
                            serviceProviderId: serviceProviderData.id!,
                            technicianId: technicianId,
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
                      //       value: 'addServiceProvider',
                      //       child: Text('Send Request'),
                      //     ),
                      //   ],
                      //   onSelected: (value) async {
                      //     if (value == 'addServiceProvider') {
                      //       final data = ServiceProviderTechnicianRequest(
                      //         id: null,
                      //         requestedBy: userData.role!,
                      //         serviceProviderId: serviceProviderData.id!,
                      //         technicianId: technicianId,
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
                        // final data = ServiceProviderTechnicianRequest(
                        //   id: null,
                        //   requestedBy: userData.role!,
                        //   serviceProviderId: serviceProviderData.id!,
                        //   technicianId: technicianId,
                        //   status: 'requested',
                        // );
                        // await TechnicianHelper()
                        //     .addServiceProviderTechnicianData(
                        //         requestData: data);
                        // //   appRouteAddressListScreen,
                        // //   arguments: customerData.userId,
                        // // );
                        final serviceProviderTechnicianInstance =
                            FirebaseFirestore.instance
                                .collection(apiServiceprovidertechnician)
                                .where('requestedBy', isEqualTo: userData.role)
                                .where('serviceProviderId',
                                    isEqualTo: serviceProviderData.id);

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
                    //       value: 'cancelServiceProvider',
                    //       child: Text('Cancel Request'),
                    //     ),
                    //   ],
                    //   onSelected: (value) async {
                    //     if (value == 'cancelServiceProvider') {
                    //       // final data = ServiceProviderTechnicianRequest(
                    //       //   id: null,
                    //       //   requestedBy: userData.role!,
                    //       //   serviceProviderId: serviceProviderData.id!,
                    //       //   technicianId: technicianId,
                    //       //   status: 'requested',
                    //       // );
                    //       // await TechnicianHelper()
                    //       //     .addServiceProviderTechnicianData(
                    //       //         requestData: data);
                    //       // //   appRouteAddressListScreen,
                    //       // //   arguments: customerData.userId,
                    //       // // );
                    //       final serviceProviderTechnicianInstance =
                    //           FirebaseFirestore
                    //               .instance
                    //               .collection(apiServiceprovidertechnician)
                    //               .where('requestedBy',
                    //                   isEqualTo: userData.role)
                    //               .where('serviceProviderId',
                    //                   isEqualTo: serviceProviderData.id);

                    //       final data =
                    //           await serviceProviderTechnicianInstance.get();
                    //       var docId = '';
                    //       if (data.docs.isNotEmpty) {
                    //         docId = data.docs[0].id;
                    //       }
                    //       await FirebaseFirestore.instance
                    //           .collection(apiServiceprovidertechnician)
                    //           .doc(docId)
                    //           .delete();
                    //     }
                    //   },
                    // );

                  }
                  return const SizedBox();
                }),
        ],
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
