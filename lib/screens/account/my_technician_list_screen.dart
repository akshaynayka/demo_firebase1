import 'package:demo_firebase1/values/app_routes.dart';
import 'package:demo_firebase1/widgets/animated_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import '../../helpers/technician_helper.dart';
import '../../models/service_provider_technician_request.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/service_provider_technician_list_tile_widget.dart';

class MyTechnicianListScreen extends StatefulWidget {
  const MyTechnicianListScreen({this.fromTabScreen, Key? key})
      : super(key: key);
  final bool? fromTabScreen;
  @override
  State<MyTechnicianListScreen> createState() => _MyTechnicianListScreenState();
}

class _MyTechnicianListScreenState extends State<MyTechnicianListScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  // bool _isInit = true;

  final List<Widget> _tabTitleList = const [
    Tab(text: appTitleMyTechnicians),
    Tab(
      text: appTitleRequests,
    ),
  ];
  List<Widget> _tabWidgetList = [];

  String? _serviceProviderId;
  String? _technicianId;
  var _isLoading = true;
  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(_handleTabSelection);
    _serviceProviderId = Provider.of<UserProvider>(context, listen: false)
        .currentServiceProviderId;
    _serviceProviderId ??= '';
    _technicianId =
        Provider.of<UserProvider>(context, listen: false).currentTechnicianId;
    _technicianId ??= '';

    final userData =
        Provider.of<UserProvider>(context, listen: false).currentUser;
    _tabWidgetList = [
      MyTechnicianListWidget(
        status: const ['accepted'],
        serviceProviderId: _serviceProviderId!,
        technicianId: _technicianId!,
        userData: userData!,
      ),
      MyTechnicianListWidget(
        status: const ['requested'],
        serviceProviderId: _serviceProviderId!,
        technicianId: _technicianId!,
        userData: userData,
      ),
    ];
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

  _handleTabSelection() {
    if (_tabController!.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromTabScreen == true
          ? null
          : const AppBarWidget(title: appTitleTechnicians),
      floatingActionButton: AnimatedFloatingActionButton(
        children: [
          SpeedDialChild(
              label: '$appTitleConnect $appTitleTechnician',
              child: const Icon(
                Icons.wallet_travel,
              ),
              onTap: () {
                Navigator.of(context).pushNamed(appRouteTechnicianListScreen);
              }),
        ],
      ),
      body: _isLoading
          ? const CircularLoaderWidget()
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  tabs: _tabTitleList,
                ),
                // Flexible(child: _tabWidgetList[_tabController!.index]),
                Flexible(
                    child: TabBarView(
                        physics: const BouncingScrollPhysics(),
                        controller: _tabController,
                        children: _tabWidgetList))
              ],
            ),
    );
  }
}

class MyTechnicianListWidget extends StatelessWidget {
  final User userData;
  final List<String> status;
  final String serviceProviderId;
  final String technicianId;

  const MyTechnicianListWidget({
    required this.status,
    required this.userData,
    required this.serviceProviderId,
    required this.technicianId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ServiceProviderTechnicianRequest>>(
      stream: TechnicianHelper().getMyTechnicianStream(
        userRole: userData.role!,
        status: status,
        serviceProviderId: serviceProviderId,
        technicianId: technicianId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(appTitleSomethingWentWrong);
        } else if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularLoaderWidget();
          }
          final requestList = snapshot.data;
          return ListView.builder(
            itemCount: requestList!.length,
            itemBuilder: (context, index) {
              return ServiceProviderTechnicianListTileWidget(
                requestData: requestList[index],
                userData: userData,
              );
            },
          );
        } else {
          return const CircularLoaderWidget();
        }
      },
    );
  }
}
