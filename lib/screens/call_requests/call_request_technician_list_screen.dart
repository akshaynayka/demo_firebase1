import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/call_request_technician_list_widget.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/static_values.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../values/app_routes.dart';
import '../../widgets/appbar_widget.dart';

class CallRequestTechnicianListScreen extends StatefulWidget {
  const CallRequestTechnicianListScreen({this.fromTabScreen, Key? key})
      : super(key: key);
  final bool? fromTabScreen;

  @override
  State<CallRequestTechnicianListScreen> createState() =>
      _CallRequestTechnicianListScreenState();
}

class _CallRequestTechnicianListScreenState
    extends State<CallRequestTechnicianListScreen>
    with SingleTickerProviderStateMixin {
  List<Widget> tabTitleList = [
    const Tab(text: 'Requested'),
    const Tab(text: 'Accepted'),
    const Tab(text: 'Assigned'),
  ];

  List<Widget> tabWidgetList = [];

  var _isInit = true;
  var _isLoading = true;
  User _userData = User(
    id: null,
    email: null,
    fullName: null,
    mobile: null,
    role: null,
    authId: null,
  );
  String _technicianId = '';
  String _serviceProviderId = '';
  List<PermissionData> _userPermissionList = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _userData =
          Provider.of<UserProvider>(context, listen: false).currentUser!;

      if (_userData.role == appRoleTechnician) {
        _technicianId = Provider.of<UserProvider>(context, listen: false)
            .currentTechnicianId!;
      } else if (_userData.role == appRoleServiceProvider) {
        _serviceProviderId = Provider.of<UserProvider>(context, listen: false)
            .currentServiceProviderId!;
      }
      _userPermissionList =
          await PermissionHelper().getAllUserPermissions(userId: _userData.id);

      // final permissionInstance = PermissionHelper();
      // final addEditPermission = permissionInstance.validateUserPermission(
      //   userData: _userData,
      //   userPermissionList: _userPermissionList,
      //   permission: appPermissionAddEditCall,
      // );
      tabWidgetList = [
        CallRequestTechnicianListWidget(
          status: 'requested',
          technicianId: _technicianId,
          userRole: _userData.role,
          // addEditPermission: addEditPermission,
          serviceProviderId: _serviceProviderId,
        ),
        CallRequestTechnicianListWidget(
          status: 'accepted',
          technicianId: _technicianId,
          userRole: _userData.role,
          // addEditPermission: addEditPermission,
          serviceProviderId: _serviceProviderId,
        ),
        CallRequestTechnicianListWidget(
          status: 'assigned',
          technicianId: _technicianId,
          userRole: _userData.role,
          // addEditPermission: addEditPermission,
          serviceProviderId: _serviceProviderId,
        ),
      ];
      // if (validateUserRole(
      //     userRole: _userData.role!, roleList: [appRoleAdmin])) {
      //   tabWidgetList.insert(
      //       0,
      //       CallRequestListWidget(
      //         status: 'request',
      //         userRole: _userData.role,
      //         addEditPermission: addEditPermission,
      //       ));
      //   tabTitleList.insert(0, const Tab(text: 'Request'));
      // }
    }
    setState(() {
      _isInit = false;
      _isLoading = false;
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromTabScreen == true
          ? null
          : const AppBarWidget(title: 'Call Requests'),
      floatingActionButton:
          // !PermissionHelper().validateUserPermission(
          //   userData: _userData,
          //   userPermissionList: _userPermissionList,
          //   permission: appPermissionAddEditCall,
          // )

          _userData.role == appRoleAdmin ||
                  _userData.role == appRoleServiceProvider
              ? FloatingActionButton(
                  child: const Icon(Icons.person_add),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(appRouteAddEditCallRequestsScreen);
                  },
                )
              : null,
      body: _isLoading
          ? const CircularLoaderWidget()
          : SafeArea(
              child: DefaultTabController(
              length: tabTitleList.length,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    tabs: tabTitleList,
                  ),
                  Flexible(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: tabWidgetList,
                    ),
                  )
                ],
              ),
            )),
    );
  }
}
