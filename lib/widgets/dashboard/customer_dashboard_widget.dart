import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import '../../../helpers/calls_helper.dart';
import '../../../models/call.dart';
import '../../../models/user.dart';
import '../../../providers/user_provider.dart';
import '../../../values/api_end_points.dart';
import '../../../values/app_routes.dart';
import '../../../values/colors.dart';
import '../../../values/string_en.dart';
import '../../../widgets/animated_floating_action_button.dart';
import '../../../widgets/call_list_lite_widget.dart';
import '../../../widgets/circular_loader_widget.dart';
import '../../../widgets/counter_card_widget.dart';
import '../../../widgets/side_drawer.dart';

class CustomerDashboardWidget extends StatefulWidget {
  const CustomerDashboardWidget({required this.userData, Key? key})
      : super(key: key);
  final User userData;

  @override
  State<CustomerDashboardWidget> createState() =>
      _CustomerDashboardWidgetState();
}

class _CustomerDashboardWidgetState extends State<CustomerDashboardWidget> {
  @override
  void initState() {
    super.initState();
    _getData();
  }

  final List<Widget> _tileList = [];
  var _isLoading = true;
  String? _customerId;
  _getData() async {
    setState(() {
      _isLoading = true;
    });
    _customerId =
        Provider.of<UserProvider>(context, listen: false).currentCustomer!;
    final firebaseInstance = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> dataList = [
      // {
      //   'title': appTitleServiceProviders,
      //   'icon': Icons.design_services_sharp,
      //   'stream': firebaseInstance.collection(apiServicesProviders).snapshots(),
      //   'route': appRouteServiceProviderListScreen,
      // },
      // {
      //   'title': appTitleTechnicians,
      //   'icon': Icons.wallet_travel,
      //   'stream': firebaseInstance.collection(apiTechnicians).snapshots(),
      //   'route': appRouteTechnicianListScreen,
      // },
      {
        'title': appTitleOpenCalls,
        'icon': Icons.timer_sharp,
        'stream': firebaseInstance
            .collection(apiCalls)
            .where('customerId', isEqualTo: _customerId)
            .where('status', isEqualTo: 'open')
            .snapshots(),
        'route': appRouteCallListScreen,
      },
      {
        'title': appTitleOpenCallRequests,
        'icon': Icons.timer_sharp,
        'stream': firebaseInstance
            .collection(apiCustomerCallRequests)
            .where('status', isEqualTo: 'requested')
            .where('customerId', isEqualTo: _customerId)
            .snapshots(),
        'route': appRouteCustomerCallRequestListScreen,
      },
    ];

    for (var element in dataList) {
      _tileList.add(
        _getCountStreamWidget(
            stream: element['stream'],
            title: element['title'],
            icon: element['icon'],
            key: element['title'],
            route: element['route']),
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

// final technicianStream =
//     firebaseInstance.collection(apiTechnicians).snapshots();
// final serviceProviderStream =
//     firebaseInstance.collection(apiServicesProviders).snapshots();
  Widget _getCountStreamWidget({
    required Stream<QuerySnapshot<Map<String, dynamic>>>? stream,
    required String title,
    required IconData icon,
    required String key,
    String? route,
  }) {
    return StreamBuilder(
      key: Key(title),
      stream: stream,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        final listLength = snapshot.data?.docs.length;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularLoaderWidget();
        }
        return
            // Text(listLength.toString());

            CounterCardWidget(
          counterText: listLength!,
          titleText: title,
          icon: icon,
          ontap: route == null
              ? null
              : () {
                  Navigator.of(context).pushNamed(route);
                },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideDrawer(userData: widget.userData),
      floatingActionButton: AnimatedFloatingActionButton(
        children: [
          SpeedDialChild(
              label: 'Create from Service Provider',
              child: const Icon(
                Icons.design_services_sharp,
              ),
              onTap: () {
                Navigator.of(context).pushNamed(
                  appRouteServiceProviderListForCustomerScreen,
                );
              }),
          SpeedDialChild(
              label: 'Create from Technician',
              child: const Icon(
                Icons.wallet_travel,
              ),
              onTap: () {
                Navigator.of(context).pushNamed(
                  appRouteTechnicianListForCustomerScreen,
                );
              }),
        ],
      ),
      body: _isLoading
          ? const CircularLoaderWidget()
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _tileList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      childAspectRatio: 6 / 4.5,
                      mainAxisSpacing: 15,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return _tileList[index];
                    },
                  ),
                ),
                Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 1.0, color: appColorGreyDark),
                    ),
                    color: appColorGrey,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Calls'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(appRouteCallListScreen);
                        },
                        child: const Text(
                          'Show All',
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child:
                        //  ListView.builder(
                        //   itemBuilder: ((context, index) => const Text('data')),
                        // ),
                        StreamBuilder<List<Call>>(
                  stream: CallsHelper().getAllCallsStream(
                    statusList: ['open', 'running'],
                    userRole: widget.userData.role!,
                    customerId: _customerId,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(appTitleSomethingWentWrong);
                    } else if (snapshot.hasData) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularLoaderWidget();
                      }
                      final callList = snapshot.data;
                      return ListView.builder(
                        itemCount: callList!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: CallListTileWidget(
                              callData: callList[index],
                              ctx: context,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  appRouteAddEditCallScreen,
                                  arguments: callList[index].id,
                                );
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return const CircularLoaderWidget();
                    }
                  },
                )),
              ],
            ),
    );
  }
}
