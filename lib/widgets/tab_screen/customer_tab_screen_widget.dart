import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../values/api_end_points.dart';
import '../../widgets/stream_counter_badge_widget.dart';
import '../../screens/customer_call_request/service_provider_list_for_customer_screen.dart';
import '../../screens/customer_call_request/technician_list_for_customer_screen.dart';
import '../../values/string_en.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/dashboard/customer_dashboard_widget.dart';
import '../../widgets/side_drawer.dart';
import '../../models/permission_data.dart';
import '../../models/user.dart';
import '../../widgets/appbar_widget.dart';

class CustomerTabScreenWidget extends StatefulWidget {
  const CustomerTabScreenWidget(
      {required this.userData, required this.userPermissionList, Key? key})
      : super(key: key);
  final User userData;
  final List<PermissionData> userPermissionList;
  @override
  State<CustomerTabScreenWidget> createState() =>
      _CustomerTabScreenWidgetState();
}

class _CustomerTabScreenWidgetState extends State<CustomerTabScreenWidget> {
  int _selectedPageIndex = 0;
  bool _isLoading = true;
  var _pages = [];

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
    _pages = [
      {
        'page': CustomerDashboardWidget(
          userData: widget.userData,
        ),
        'title': appTitle,
        'label': 'Home',
        'icon': Icons.home,
        'stream': null,
      },
      {
        'page': const ServiceProviderListForCustomerScreen(fromTabScreen: true),
        'title': appTitleServiceProviders,
        'label': appTitleServiceProviders,
        'icon': Icons.design_services_sharp,
        'stream': firebaseInstance.collection(apiServicesProviders).snapshots(),
      },
      {
        'page': const TechnicianListForCustomerScreen(fromTabScreen: true),
        'title': appTitleTechnicians,
        'label': appTitleTechnicians,
        'icon': Icons.wallet_travel,
        'stream': firebaseInstance.collection(apiTechnicians).snapshots(),
      },
      // {
      //   'page': const CallListScreen(fromTabScreen: true),
      //   'title': 'Calls',
      //   'label': 'Calls',
      //   'icon': Icons.timer_sharp,
      //   'stream': null,
      // },
      // {
      //   'page': const CustomerCallRequestListScreen(fromTabScreen: true),
      //   'title': appTitleCallRequests,
      //   'label': appTitleCallRequests,
      //   'icon': Icons.timer_sharp,
      //   'stream': null,
      // },
    ];
    setState(() {
      _isLoading = false;
    });
  }

  // _streamCounter(
  //     {required Stream<QuerySnapshot<Map<String, dynamic>>>? stream,
  //     TextStyle? style}) {
  //   return StreamBuilder(
  //     stream: stream,
  //     builder: (context,
  //         AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
  //       final listLength = snapshot.data?.docs.length;
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const CircularLoaderWidget();
  //       }
  //       return Text(
  //         listLength.toString(),
  //         style: style,
  //         textAlign: TextAlign.center,
  //       );
  //     },
  //   );
  // }

  // Widget _badgeWidget() {
  //   return StreamBuilder(
  //     stream: FirebaseFirestore.instance
  //         .collection(apiCustomerCallRequests)
  //         .snapshots(),
  //     builder: (context,
  //         AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
  //       final listLength = snapshot.data?.docs.length;
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const CircularLoaderWidget();
  //       }
  //       return
  //           // Text(listLength.toString());
  //           Container(
  //         padding: EdgeInsets.all(1),
  //         decoration: new BoxDecoration(
  //           color: Colors.red,
  //           borderRadius: BorderRadius.circular(6),
  //         ),
  //         constraints: BoxConstraints(
  //           minWidth: 12,
  //           minHeight: 12,
  //         ),
  //         child: new Text(
  //           listLength.toString(),
  //           style: new TextStyle(
  //             color: Colors.white,
  //             fontSize: 8,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       );
  //     },
  //   );
  // }
  // Widget _SteeamCounterBadgeWidget(
  //     {required Stream<QuerySnapshot<Map<String, dynamic>>>? stream}) {
  //   return Container(
  //     padding: EdgeInsets.all(1),
  //     decoration: new BoxDecoration(
  //       color: Colors.red,
  //       borderRadius: BorderRadius.circular(6),
  //     ),
  //     constraints: BoxConstraints(
  //       minWidth: 12,
  //       minHeight: 12,
  //     ),
  //     child: StreamCounterTextWidget(
  //       stream: stream,
  //       style: TextStyle(
  //         color: Colors.white,
  //         fontSize: 8,
  //       ),
  //     ),
  //   );
  // }

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
