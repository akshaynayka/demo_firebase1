import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/technician_helper.dart';
import '../../providers/user_provider.dart';
import '../../values/api_end_points.dart';
import '../../widgets/stream_counter_badge_widget.dart';
import '../../screens/account/my_technician_list_screen.dart';
import '../../screens/customers/customer_list_screen.dart';
import '../../values/string_en.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/dashboard/service_provider_dashboard_widget.dart';
import '../../widgets/side_drawer.dart';
import '../../models/permission_data.dart';
import '../../models/user.dart';
import '../../widgets/appbar_widget.dart';

class ServiceProviderTabScreenWidget extends StatefulWidget {
  const ServiceProviderTabScreenWidget(
      {required this.userData, required this.userPermissionList, Key? key})
      : super(key: key);
  final User userData;
  final List<PermissionData> userPermissionList;
  @override
  State<ServiceProviderTabScreenWidget> createState() =>
      _ServiceProviderTabScreenWidgetState();
}

class _ServiceProviderTabScreenWidgetState
    extends State<ServiceProviderTabScreenWidget> {
  int _selectedPageIndex = 0;
  bool _isLoading = true;
  var _pages = [];
  String? _serviceProviderId;

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  _getUserData() async {
    final firebaseInstance = FirebaseFirestore.instance;

    setState(() {
      _isLoading = true;

      _serviceProviderId = Provider.of<UserProvider>(context, listen: false)
          .currentServiceProviderId!;
    });
    _pages = [
      {
        'page': ServiceProviderDashboardWidget(
          userData: widget.userData,
        ),
        'title': appTitle,
        'label': 'Home',
        'icon': Icons.home,
        'stream': null,
      },
      {
        'page': const MyTechnicianListScreen(fromTabScreen: true),
        'title': 'Technicians',
        'label': 'Technicians',
        'icon': Icons.wallet_travel,
        'stream': TechnicianHelper().getMyTechnicianCounterStream(
          userRole: widget.userData.role!,
          serviceProviderId: _serviceProviderId,
        ),
      },
      {
        'page': const CustomerListScreen(),
        'title': 'Customers',
        'label': 'Customers',
        'icon': Icons.people_alt_outlined,
        'stream': firebaseInstance.collection(apiCustomers).snapshots(),
      },
      // {
      //   'page': const CallListScreen(fromTabScreen: true),
      //   'title': 'Calls',
      //   'label': 'Calls',
      //   'icon': Icons.timer_sharp,
      //   'stream': null,
      // },
      // {
      //   'page': const CallRequestListScreen(fromTabScreen: true),
      //   'title': appTitleCallRequests,
      //   'label': appTitleCallRequests,
      //   'icon': Icons.timer_sharp,
      //   'stream': null,
      // },
      // {
      //   'page': const CallRequestTechnicianListScreen(fromTabScreen: true),
      //   'title': 'Request to technicians',
      //   'label': 'Request to technicians',
      //   'icon': Icons.timer_sharp,
      //   'stream': null,
      // },
      // {
      //   'page': const CustomerCallRequestListScreen(fromTabScreen: true),
      //   'title': 'Customer Call Request',
      //   'label': 'Customer Call Request',
      //   'icon': Icons.timer_sharp,
      //   'stream': null,
      // },
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
        type: BottomNavigationBarType.values.first,
        items: [
          for (var i = 0; i < _pages.length; i++)
            BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 4.0, left: 0.4, top: 0.4),
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
                label: _pages[i]['label']),
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
