import 'package:provider/provider.dart';
import '../../widgets/appbar_widget.dart';
import '../../helpers/technician_helper.dart';
import '../../models/service_provider_technician_request.dart';
import '../../values/static_values.dart';
import '../../helpers/permission_helper.dart';
import '../../helpers/service_provider_helper.dart';
import '../../models/permission_data.dart';
import '../../models/service_provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/app_permissions.dart';
import '../../widgets/service_provider_list_tile_widget.dart';
import '../../values/app_routes.dart';
import '../../values/colors.dart';
import '../../values/string_en.dart';
import '../../widgets/circular_loader_widget.dart';
import 'package:flutter/material.dart';

class ServiceProviderListScreen extends StatefulWidget {
  const ServiceProviderListScreen({this.fromTabScreen = false, Key? key})
      : super(key: key);
  final bool? fromTabScreen;
  @override
  State<ServiceProviderListScreen> createState() =>
      _ServiceProviderListScreenState();
}

class _ServiceProviderListScreenState extends State<ServiceProviderListScreen> {
  User? _userData = User(
    id: null,
    email: null,
    fullName: null,
    mobile: null,
    role: null,
    authId: null,
  );
  bool _isInit = true;
  var _isLoading = false;
  List<PermissionData> _userPermissionList = [];
  String? _technicianId;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _userData = Provider.of<UserProvider>(context, listen: false).currentUser;
      _technicianId =
          Provider.of<UserProvider>(context, listen: false).currentTechnicianId;
      _technicianId ??= '';
      _userPermissionList =
          await PermissionHelper().getAllUserPermissions(userId: _userData!.id);
    }
    setState(() {
      _isInit = false;
      _isLoading = false;
    });
    super.didChangeDependencies();
  }

  bool _checkContainsOrNot(
      List<ServiceProviderTechnicianRequest>? technicianProviderList,
      String serviceProviderId) {
    return technicianProviderList!
                .firstWhere(
                  (data) => data.serviceProviderId == serviceProviderId,
                  orElse: () => ServiceProviderTechnicianRequest(
                    id: null,
                    requestedBy: null,
                    serviceProviderId: null,
                    technicianId: null,
                    status: null,
                  ),
                )
                .id !=
            null
        ? true
        : false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromTabScreen == true
          ? null
          : const AppBarWidget(title: appTitleServiceProviders),
      floatingActionButton: !PermissionHelper().validateUserPermission(
        userData: _userData!,
        userPermissionList: _userPermissionList,
        permission: appPermissionAddEditServiceProvider,
      )
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(appRouteAddEditServiceProviderScreen);
              },
            ),
      backgroundColor: appColorBackground,
      body: _isLoading
          ? const CircularLoaderWidget()
          : StreamBuilder<List<ServiceProvider>>(
              stream: ServiceProviderHelper().getAllServiceProviderStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(appTitleSomethingWentWrong);
                } else if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularLoaderWidget();
                  }

                  // final serviceProviders = snapshot.data;
                  // return ListView.builder(
                  //   itemCount: serviceProviders!.length,
                  //   itemBuilder: (context, index) {
                  //     return Card(
                  //       child: ServiceProviderListTileWidget(
                  //         serviceProviderData: serviceProviders[index],
                  //         userData: _userData!,
                  //         onTap: () {
                  //           if (PermissionHelper().validateUserPermission(
                  //             userData: _userData!,
                  //             userPermissionList: _userPermissionList,
                  //             permission: appPermissionAddEditServiceProvider,
                  //           )) {
                  //             Navigator.of(context).pushNamed(
                  //               appRouteAddEditServiceProviderScreen,
                  //               arguments: serviceProviders[index].id,
                  //             );
                  //           }
                  //         },
                  //         // addressPermission:
                  //         //     PermissionHelper().validateUserPermission(
                  //         //   userData: _userData!,
                  //         //   userPermissionList: _userPermissionList,
                  //         //   permission: appPermissionAddressList,
                  //         // ),
                  //       ),
                  //     );
                  //   },
                  // );
                  var serviceProviderList = [];
                  serviceProviderList = snapshot.data!;
                  return FutureBuilder<List<ServiceProviderTechnicianRequest>>(
                      future: TechnicianHelper().getMyTechnicianRequestList(
                        userRole: appRoleTechnician,
                        // serviceProviderId: 'N5H42OSXKf77yQXwosWz',
                        technicianId: _technicianId,
                        status: 'accepted',
                      ),
                      builder: (context, snapshotData) {
                        if (snapshotData.hasData) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularLoaderWidget();
                          }

                          final myTechnicianProviderList = snapshotData.data;
                          var otherServiceProviderList = [];
                          for (var element in serviceProviderList) {
                            final contains = _checkContainsOrNot(
                                myTechnicianProviderList, element.id!);
                            if (!contains) {
                              otherServiceProviderList.add(element);
                            }
                          }
                          // otherTechnicianList.every((element) {
                          //   if()
                          //   return true;
                          // });
                          return ListView.builder(
                            itemCount: otherServiceProviderList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                //   child: TechnicianListTileWidget(
                                //     technicianDetails: otherServiceProviderList[index],
                                //     userData: _userData!,
                                //     onTap: () {
                                //       if (PermissionHelper()
                                //           .validateUserPermission(
                                //         userData: _userData!,
                                //         userPermissionList: _userPermissionList,
                                //         permission:
                                //             appPermissionAddEditTechnician,
                                //       )) {
                                //         Navigator.of(context).pushNamed(
                                //           appRouteAddEditTechnicianScreen,
                                //           arguments:
                                //               otherTechnicianList[index].id,
                                //         );
                                //       }
                                //     },
                                //   ),

                                child: ServiceProviderListTileWidget(
                                  serviceProviderData:
                                      otherServiceProviderList[index],
                                  userData: _userData!,
                                  changePermission:
                                      _userData!.role == appRoleAdmin,
                                  onTap: () {
                                    if (PermissionHelper()
                                        .validateUserPermission(
                                      userData: _userData!,
                                      userPermissionList: _userPermissionList,
                                      permission:
                                          appPermissionAddEditServiceProvider,
                                    )) {
                                      Navigator.of(context).pushNamed(
                                        appRouteAddEditServiceProviderScreen,
                                        arguments:
                                            otherServiceProviderList[index].id,
                                      );
                                    }
                                  },
                                  // addressPermission:
                                  //     PermissionHelper().validateUserPermission(
                                  //   userData: _userData!,
                                  //   userPermissionList: _userPermissionList,
                                  //   permission: appPermissionAddressList,
                                  // ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const CircularLoaderWidget();
                        }
                      });
                } else {
                  return const CircularLoaderWidget();
                }
              },
            ),
    );
  }
}
