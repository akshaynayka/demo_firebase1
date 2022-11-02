import 'package:flutter/foundation.dart';

import '../values/static_values.dart';
import 'package:flutter/material.dart';
import '../common_methods/common_methods.dart';
import '../values/colors.dart';
import '../models/user.dart' as user;
import '../values/string_en.dart';
import '../values/app_routes.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({
    required this.userData,
    Key? key,
  }) : super(key: key);

  final user.User userData;

  Widget _rowTileContainer(IconData icon, String title, Function()? onTap) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 8),
      height: 40,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
            ),
            const SizedBox(width: 32),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    // final restartFunction = (() {
    //   RestartAppWidget.restartApp(context);
    // });
    return Drawer(
      child: Center(
        child:
            //  _isLoading
            //     ? const CircularLoaderWidget()
            //     :
            Column(
          children: [
            AppBar(
              title: const Text(appTitle),
              automaticallyImplyLeading: false,
              titleTextStyle: const TextStyle(
                // fontSize: 25.0,
                color: appColorWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
            _rowTileContainer(
              Icons.home,
              appTitleHome,
              () {
                navigator.pop();
                // Navigator.popUntil(context, ModalRoute.withName("/"));

                navigator.popAndPushNamed(
                  appRouteHomeScreen,
                );
              },
            ),
            _rowTileContainer(
              Icons.person_pin_rounded,
              'Profile',
              () {
                navigator.pop();
                navigator.pushNamed(appRouteMyProfileScreen);
              },
            ),
            if (userData.role == appRoleCustomer)
              _rowTileContainer(
                Icons.person_pin_rounded,
                'My Address',
                () {
                  navigator.pop();
                  navigator.pushNamed(appRouteAddressListScreen,
                      arguments: userData.id);
                },
              ),
            if (userData.role == appRoleAdmin)
              _rowTileContainer(
                Icons.person_pin_rounded,
                'Configuration',
                () {
                  navigator.pop();
                  navigator.pushNamed(appRouteConfigurationScreen);
                },
              ),
            _rowTileContainer(
              Icons.exit_to_app,
              'Logout',
              () async {
                await showLogoutAppDialog(context);
                navigator.pop();
              },
            ),
            const Expanded(
              child: SizedBox(),
            ),

            // _rowTileContainer(
            //   Icons.person_pin_rounded,
            //   widget.userData.role == appRoleServiceProvider
            //       ? 'My Technicians'
            //       : 'My Service Provider',
            //   () {
            //     Navigator.pop(context);
            //     navigator.pushNamed(appRouteMyTechnicianListScreen);
            //   },
            // ),
            // if (PermissionHelper().validateUserPermission(
            //     userData: widget.userData,
            //     userPermissionList: _userPermissionList,
            //     permission: appPermissionCustomerList))
            //   _rowTileContainer(
            //     Icons.person_pin_rounded,
            //     'Customers',
            //     () {
            //       Navigator.pop(context);
            //       navigator.pushNamed(appRouteCustomerListScreen);
            //     },
            //   ),
            // if (PermissionHelper().validateUserPermission(
            //     userData: widget.userData,
            //     userPermissionList: _userPermissionList,
            //     permission: appPermissionServiceProvidersList))
            //   _rowTileContainer(
            //     Icons.person_pin_rounded,
            //     'Service Providers',
            //     () {
            //       Navigator.pop(context);
            //       navigator.pushNamed(appRouteServiceProviderListScreen);
            //     },
            //   ),
            // if (PermissionHelper().validateUserPermission(
            //     userData: widget.userData,
            //     userPermissionList: _userPermissionList,
            //     permission: appPermissionTechnicianList))
            //   _rowTileContainer(
            //     Icons.person_pin_rounded,
            //     'Technicians',
            //     () {
            //       Navigator.pop(context);
            //       navigator.pushNamed(appRouteTechnicianListScreen);
            //     },
            //   ),
            // if (PermissionHelper().validateUserPermission(
            //     userData: widget.userData,
            //     userPermissionList: _userPermissionList,
            //     permission: appPermissionServiceList))
            //   _rowTileContainer(
            //     Icons.person_pin_rounded,
            //     'Services',
            //     () {
            //       Navigator.pop(context);
            //       navigator.pushNamed(appRouteServiceListScreen);
            //     },
            //   ),
            // if (PermissionHelper().validateUserPermission(
            //     userData: widget.userData,
            //     userPermissionList: _userPermissionList,
            //     permission: appPermissionCallList))
            //   _rowTileContainer(
            //     Icons.person_pin_rounded,
            //     'Calls',
            //     () {
            //       Navigator.pop(context);
            //       navigator.pushNamed(appRouteCallListScreen);
            //     },
            //   ),
            // _rowTileContainer(
            //   Icons.person_pin_rounded,
            //   'Call Request Technicians',
            //   () {
            //     Navigator.pop(context);
            //     navigator
            //         .pushNamed(appRouteCallRequestTechnicianListScreen);
            //   },
            // ),
            // _rowTileContainer(
            //   Icons.person_pin_rounded,
            //   'Call Request',
            //   () {
            //     Navigator.pop(context);
            //     navigator.pushNamed(appRouteCallRequestsListScreen);
            //   },
            // ),
            // if (widget.userData.role == appRoleAdmin)
            //   _rowTileContainer(
            //     Icons.person_pin_rounded,
            //     'Users',
            //     () {
            //       Navigator.pop(context);
            //       navigator.pushNamed(appRouteUserListScreen);
            //     },
            //   ),
            // if (widget.userData.role == appRoleAdmin)
            //   _rowTileContainer(
            //     Icons.person_pin_rounded,
            //     'Permissions',
            //     () {
            //       Navigator.pop(context);
            //       navigator.pushNamed(appRoutePermissionListScreen);
            //     },
            //   ),
            if (kDebugMode)
              _rowTileContainer(
                Icons.person_pin_rounded,
                'Test Screen1',
                () {
                  Navigator.pop(context);
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) =>  TestScreen1(),

                  //         settings: 'FunlJFYnYe55DBQO4Tdw'
                  //         ),

                  //         );
                },
              ),
            if (kDebugMode)
              _rowTileContainer(
                Icons.person_pin_rounded,
                'Test Screen2',
                () {
                  Navigator.pop(context);
                },
              ),

            // _rowTileContainer(
            //   Icons.person_pin_rounded,
            //   'Test Screen3',
            //   () {
            //     Navigator.pop(context);
            //     // Navigator.push(
            //     //     context,
            //     //     MaterialPageRoute(
            //     //         builder: (context) => const TestScreen3()));
            //     Navigator.push(
            //       context,
            //       PageRouteBuilder(
            //           opaque: false,
            //           pageBuilder: (context, _, __) => const TestScreen3()),
            //     );
            //   },
            // ),
            Container(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    appTitlePoweredBy,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('$appTitleVersion : V-0.0.1'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
