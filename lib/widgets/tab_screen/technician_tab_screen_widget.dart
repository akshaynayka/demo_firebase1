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
import '../../widgets/side_drawer.dart';
import '../../models/user.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/dashboard/technician_dashboard_widget.dart';

class TechnicianTabScreenWidget extends StatefulWidget {
  const TechnicianTabScreenWidget({required this.userData, Key? key})
      : super(key: key);

  final User userData;

  @override
  State<TechnicianTabScreenWidget> createState() =>
      _TechnicianTabScreenWidgetState();
}

class _TechnicianTabScreenWidgetState extends State<TechnicianTabScreenWidget> {
  int _selectedPageIndex = 0;
  bool _isLoading = true;
  var _pages = [];
  var _technicianId = '';

  @override
  void initState() {
    _getUserData();
    super.initState();
  }

  _getUserData() async {
    final firebaseInstance = FirebaseFirestore.instance;

    setState(() {
      _isLoading = true;
    });
    _technicianId =
        Provider.of<UserProvider>(context, listen: false).currentTechnicianId!;
    _pages = [
      {
        'page': TechnicianDashboardWidget(
          userData: widget.userData,
        ),
        'title': appTitle,
        'label': 'Home',
        'icon': Icons.home,
      },
      {
        'page': const MyTechnicianListScreen(
          fromTabScreen: true,
        ),
        'title': appTitleServiceProviders,
        'label': appTitleServiceProviders,
        'icon': Icons.design_services_sharp,
        'stream': TechnicianHelper().getMyTechnicianCounterStream(
          userRole: widget.userData.role!,
          technicianId: _technicianId,
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
      //   'title': appTitleCalls,
      //   'label': appTitleCalls,
      //   'icon': Icons.timer_sharp,
      //   'stream': null,
      // },
      // {
      //   'page': const CallRequestTechnicianListScreen(fromTabScreen: true),
      //   'title': appTitleCallRequests,
      //   'label': appTitleCallRequests,
      //   'icon': Icons.timer_sharp,
      //   'stream': null,
      // },
      // {
      //   'page': const CustomerCallRequestListScreen(fromTabScreen: true),
      //   'title': 'Customer call request',
      //   'label': 'Customer call request',
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
      // : TechnicianDashboardWidget(userData: widget.userData),
    );
  }
}
