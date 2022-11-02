import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../values/app_permissions.dart';
import '../../common_methods/validate_user_role.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/static_values.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../values/app_routes.dart';
import '../../widgets/call_list_widget.dart';

class CallListScreen extends StatefulWidget {
  const CallListScreen({this.fromTabScreen = false, Key? key})
      : super(key: key);
  final bool? fromTabScreen;
  @override
  State<CallListScreen> createState() => _CallListScreenState();
}

class _CallListScreenState extends State<CallListScreen>
    with SingleTickerProviderStateMixin {
  List<Widget> tabTitleList = [
    const Tab(text: 'Open'),
    const Tab(text: 'Running'),
    const Tab(text: 'Close'),
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
  String _customerId = '';
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
      } else if (_userData.role == appRoleCustomer) {
        _customerId =
            Provider.of<UserProvider>(context, listen: false).currentCustomer!;
      }
      _userPermissionList =
          await PermissionHelper().getAllUserPermissions(userId: _userData.id);

      final permissionInstance = PermissionHelper();
      final addEditPermission = permissionInstance.validateUserPermission(
        userData: _userData,
        userPermissionList: _userPermissionList,
        permission: appPermissionAddEditCall,
      );
      tabWidgetList = [
        CallListWidget(
          status: 'open',
          technicianId: _technicianId,
          userRole: _userData.role,
          addEditPermission: addEditPermission,
          serviceProviderId: _serviceProviderId,
          customerId: _customerId,
        ),
        CallListWidget(
          status: 'running',
          technicianId: _technicianId,
          userRole: _userData.role,
          addEditPermission: addEditPermission,
          serviceProviderId: _serviceProviderId,
          customerId: _customerId,
        ),
        CallListWidget(
          status: 'close',
          technicianId: _technicianId,
          userRole: _userData.role,
          addEditPermission: addEditPermission,
          serviceProviderId: _serviceProviderId,
          customerId: _customerId,
        ),
      ];
      if (validateUserRole(
          userRole: _userData.role!, roleList: [appRoleAdmin])) {
        tabWidgetList.insert(
            0,
            CallListWidget(
              status: 'request',
              userRole: _userData.role,
              addEditPermission: addEditPermission,
            ));
        tabTitleList.insert(0, const Tab(text: 'Request'));
      }
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
          : const AppBarWidget(
              title: appTitleCalls,
            ),
      floatingActionButton: !PermissionHelper().validateUserPermission(
        userData: _userData,
        userPermissionList: _userPermissionList,
        permission: appPermissionAddEditCall,
      )
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context).pushNamed(appRouteAddEditCallScreen);
              },
            ),
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
