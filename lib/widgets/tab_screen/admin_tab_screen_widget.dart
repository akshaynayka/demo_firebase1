import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../values/api_end_points.dart';
import '../../widgets/stream_counter_badge_widget.dart';
import '../../screens/customers/customer_list_screen.dart';
import '../../screens/service_provider/service_provider_list_screen.dart';
import '../../screens/services/service_list_screen.dart';
import '../../screens/technician/technician_list_screen.dart';
import '../../screens/user_permissions/permission_list_screen.dart';
import '../../screens/users/user_list_screen.dart';
import '../../values/static_values.dart';
import '../../values/string_en.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/dashboard/admin_dashboard_widget.dart';
import '../../widgets/side_drawer.dart';
import '../../models/user.dart';
import '../../widgets/appbar_widget.dart';

class AdminTabScreenWidget extends StatefulWidget {
  const AdminTabScreenWidget({required this.userData, Key? key})
      : super(key: key);
  final User userData;
  @override
  State<AdminTabScreenWidget> createState() => _AdminTabScreenWidgetState();
}

class _AdminTabScreenWidgetState extends State<AdminTabScreenWidget> {
  int _selectedPageIndex = 0;
  bool _isLoading = true;
  var _pages = [];

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  _getUserData() async {
    setState(() {
      _isLoading = true;
    });
    final firebaseInstance = FirebaseFirestore.instance;

    _pages = [
      {
        'page': AdminDashboardWidget(
          userData: widget.userData,
        ),
        'title': appTitle,
        'label': appTitleHome,
        'icon': Icons.home,
      },
      {
        'page': const ServiceProviderListScreen(fromTabScreen: true),
        'title': appTitleServiceProviders,
        'label': appTitleServiceProviders,
        'icon': Icons.design_services_sharp,
        'stream': firebaseInstance.collection(apiServicesProviders).snapshots(),
      },
      {
        'page': const TechnicianListScreen(fromTabScreen: true),
        'title': appTitleTechnician,
        'label': appTitleTechnician,
        'icon': Icons.wallet_travel,
        'stream': firebaseInstance.collection(apiTechnicians).snapshots(),
      },
      {
        'page': const CustomerListScreen(),
        'title': appTitleCustomers,
        'label': appTitleCustomers,
        'icon': Icons.people_alt_outlined,
        'stream': firebaseInstance.collection(apiCustomers).snapshots(),
      },
      // {
      //   'page': const CallListScreen(fromTabScreen: true),
      //   'title': appTitleCalls,
      //   'label': appTitleCalls,
      //   'icon': Icons.timer_sharp,
      // },
      // {
      //   'page': const CallRequestListScreen(fromTabScreen: true),
      //   'title': appTitleCallRequests,
      //   'label': appTitleCallRequests,
      //   'icon': Icons.timer_sharp,
      // },
      {
        'page': const ServiceListScreen(fromTabScreen: true),
        'title': appTitleServices,
        'label': appTitleServices,
        'icon': Icons.people_alt_outlined,
        'stream': firebaseInstance.collection(apiServices).snapshots(),
      },
      {
        'page': const UserListScreen(fromTabScreen: true),
        'title': appTitleUsers,
        'label': appTitleUsers,
        'icon': Icons.people_alt_outlined,
        'stream': firebaseInstance.collection(apiUsers).snapshots(),
      },
      {
        'page': const PermissionListScreen(fromTabScreen: true),
        'title': appTitlePermissions,
        'label': appTitlePermissions,
        'icon': Icons.people_alt_outlined,
        'stream': firebaseInstance.collection(apiPermissions).snapshots(),
      },
    ];
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: _pages[_selectedPageIndex]['title'],
        resetData: widget.userData.role == appRoleAdmin,
      ),
      drawer: SideDrawer(userData: widget.userData),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _selectedPageIndex = value;
          });
        },
        currentIndex: _selectedPageIndex,
        // selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        fixedColor: Theme.of(context).primaryColor,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        items: [
          for (var i = 0; i < _pages.length; i++)
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 4.0, left: 0.4, top: 0.4),
                    child: Icon(_pages[i]['icon']),
                  ),
                  _pages[i]['stream'] == null
                      ? const SizedBox()
                      : Positioned(
                          // top: 0.0,
                          right: 0.0,
                          child: StreamCounterBadgeWidget(
                              stream: _pages[i]['stream'])),
                ],
              ),
              label: _pages[i]['label'],
            ),
        ],
      ),
      body: _isLoading
          ? Scaffold(
              appBar: const AppBarWidget(),
              drawer: SideDrawer(userData: widget.userData),
              body: const CircularLoaderWidget(),
            )
          : _pages[_selectedPageIndex]['page'],
    );
  }
}
