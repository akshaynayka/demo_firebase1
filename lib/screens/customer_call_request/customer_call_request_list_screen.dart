import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/static_values.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/customer_call_request_list_widget.dart';

class CustomerCallRequestListScreen extends StatefulWidget {
  const CustomerCallRequestListScreen({this.fromTabScreen, Key? key})
      : super(key: key);
  final bool? fromTabScreen;
  @override
  State<CustomerCallRequestListScreen> createState() =>
      _CustomerCallRequestListScreenState();
}

class _CustomerCallRequestListScreenState
    extends State<CustomerCallRequestListScreen> {
  var _isInit = true;
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
  List<Widget> tabWidgetList = [];
  var _isLoading = true;
  List<Widget> tabTitleList = [
    const Tab(text: 'Requested'),
    const Tab(text: 'Accepted'),
  ];

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

      tabWidgetList = [
        CustomerCallRequestListWidget(
          userRole: _userData.role!,
          technicianId: _technicianId,
          serviceProvider: _serviceProviderId,
          customerId: _customerId,
          status: 'requested',
        ),
        CustomerCallRequestListWidget(
          userRole: _userData.role!,
          technicianId: _technicianId,
          serviceProvider: _serviceProviderId,
          customerId: _customerId,
          status: 'accepted',
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
      body: DefaultTabController(
        length: tabWidgetList.length,
        // child: CustomerCallRequestListWidget(
        //     userRole: _userData.role!, technicianId: _technicianId),
        child: _isLoading
            ? const CircularLoaderWidget()
            : Column(
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
      ),
    );
  }
}
