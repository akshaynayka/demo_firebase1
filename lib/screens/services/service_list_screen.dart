import 'package:provider/provider.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/app_permissions.dart';
import '../../helpers/service_helper.dart';
import '../../models/service.dart';
import '../../values/app_routes.dart';
import '../../values/colors.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/service_list_lite_widget.dart';
import 'package:flutter/material.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({this.fromTabScreen, Key? key}) : super(key: key);
  final bool? fromTabScreen;

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  User? _userData = User(
    id: null,
    email: null,
    fullName: null,
    mobile: null,
    role: null,
    authId: null,
  );
  bool _isInit = true;
  var _isLoading = false;
  List<PermissionData> _userPermissionList = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _userData = Provider.of<UserProvider>(context, listen: false).currentUser;
      _userPermissionList =
          await PermissionHelper().getAllUserPermissions(userId: _userData!.id);
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
              title: appTitleService,
            ),
      floatingActionButton: !PermissionHelper().validateUserPermission(
        userData: _userData!,
        userPermissionList: _userPermissionList,
        permission: appPermissionAddEditService,
      )
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context).pushNamed(appRouteAddEditServiceScreen);
              },
            ),
      backgroundColor: appColorBackground,
      body: _isLoading
          ? const CircularLoaderWidget()
          : StreamBuilder<List<Service>>(
              stream: ServiceHelper().getAllServicesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(appTitleSomethingWentWrong);
                } else if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularLoaderWidget();
                  }
                  final serviceList = snapshot.data;
                  return ListView.builder(
                    itemCount: serviceList!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ServiceListTileWidget(
                          serviceDetails: serviceList[index],
                          onTap: () {
                            if (PermissionHelper().validateUserPermission(
                              userData: _userData!,
                              userPermissionList: _userPermissionList,
                              permission: appPermissionAddEditService,
                            )) {
                              Navigator.of(context).pushNamed(
                                appRouteAddEditServiceScreen,
                                arguments: serviceList[index].id,
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const CircularLoaderWidget();
                }
              },
            ),
    );
  }
}
