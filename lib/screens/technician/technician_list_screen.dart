import '../../widgets/appbar_widget.dart';
import 'package:provider/provider.dart';
import '../../models/service_provider_technician_request.dart';
import '../../values/static_values.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/app_permissions.dart';

import '../../helpers/technician_helper.dart';
import '../../models/technician.dart';
import '../../values/app_routes.dart';
import '../../values/colors.dart';
import '../../values/string_en.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/technician_list_tile_widget.dart';
import 'package:flutter/material.dart';

class TechnicianListScreen extends StatefulWidget {
  const TechnicianListScreen({this.fromTabScreen, Key? key}) : super(key: key);
  final bool? fromTabScreen;
  @override
  State<TechnicianListScreen> createState() => _TechnicianListScreenState();
}

class _TechnicianListScreenState extends State<TechnicianListScreen> {
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
  String? _serviceProviderId;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _serviceProviderId = Provider.of<UserProvider>(context, listen: false)
          .currentServiceProviderId;
      _serviceProviderId ??= '';
      _userData = Provider.of<UserProvider>(context, listen: false).currentUser;
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
      String technicianId) {
    return technicianProviderList!
                .firstWhere(
                  (data) => data.technicianId == technicianId,
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
      appBar: widget.fromTabScreen != true
          ? const AppBarWidget(
              title: appTitleTechnician,
            )
          : null,
      floatingActionButton: !PermissionHelper().validateUserPermission(
        userData: _userData!,
        userPermissionList: _userPermissionList,
        permission: appPermissionAddEditTechnician,
      )
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(appRouteAddEditTechnicianScreen);
              },
            ),
      backgroundColor: appColorBackground,
      body: _isLoading
          ? const CircularLoaderWidget()
          : StreamBuilder<List<Technician>>(
              stream: TechnicianHelper().getAllTechnicianStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(appTitleSomethingWentWrong);
                } else if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularLoaderWidget();
                  }
                  var technicianList = [];
                  technicianList = snapshot.data!;
                  return FutureBuilder<List<ServiceProviderTechnicianRequest>>(
                      future: TechnicianHelper().getMyTechnicianRequestList(
                        userRole: appRoleServiceProvider,
                        serviceProviderId: _serviceProviderId,
                        // technicianId: '',
                        status: 'accepted',
                      ),
                      builder: (context, snapshotData) {
                        if (snapshotData.hasData) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularLoaderWidget();
                          }

                          final myTechnicianProviderList = snapshotData.data;
                          var otherTechnicianList = [];
                          for (var element in technicianList) {
                            final contains = _checkContainsOrNot(
                                myTechnicianProviderList, element.id!);
                            if (!contains) {
                              otherTechnicianList.add(element);
                            }
                          }
                          // otherTechnicianList.every((element) {
                          //   if()
                          //   return true;
                          // });
                          return ListView.builder(
                            itemCount: otherTechnicianList.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: TechnicianListTileWidget(
                                  technicianDetails: otherTechnicianList[index],
                                  changePermission:
                                      _userData!.role == appRoleAdmin,
                                  userData: _userData!,
                                  onTap: () {
                                    if (PermissionHelper()
                                        .validateUserPermission(
                                      userData: _userData!,
                                      userPermissionList: _userPermissionList,
                                      permission:
                                          appPermissionAddEditTechnician,
                                    )) {
                                      Navigator.of(context).pushNamed(
                                        appRouteAddEditTechnicianScreen,
                                        arguments:
                                            otherTechnicianList[index].id,
                                      );
                                    }
                                  },
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
