import 'package:provider/provider.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/app_permissions.dart';

import '../../helpers/addresses_helper.dart';
import '../../models/address.dart';
import '../../widgets/address_list_tile_widget.dart';
import '../../values/app_routes.dart';
import '../../values/colors.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import 'package:flutter/material.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  bool _isInit = true;
  String? _userId;
  var _isLoading = false;
  User? _userData = User(
    id: null,
    email: null,
    fullName: null,
    mobile: null,
    role: null,
    authId: null,
  );
  List<PermissionData> _userPermissionList = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      _userId = args;

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
      appBar: const AppBarWidget(
        title: appTitleAddresses,
      ),
      floatingActionButton: !PermissionHelper().validateUserPermission(
        userData: _userData!,
        userPermissionList: _userPermissionList,
        permission: appPermissionAddEditAddress,
      )
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(appRouteAddEditAddressScreen, arguments: {
                  'userId': _userId,
                });
              },
            ),
      backgroundColor: appColorBackground,
      body: _isLoading
          ? const CircularLoaderWidget()
          : StreamBuilder<List<Address>>(
              stream: AddressesHelper()
                  .gellAllAddressesStream(userId: _userId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(appTitleSomethingWentWrong);
                } else if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularLoaderWidget();
                  }
                  final addresses = snapshot.data;
                  return ListView.builder(
                    itemCount: addresses!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: AddressListTileWidget(
                          addressData: addresses[index],
                          onTap: () {
                            if (PermissionHelper().validateUserPermission(
                              userData: _userData!,
                              userPermissionList: _userPermissionList,
                              permission: appPermissionAddEditAddress,
                            )) {
                              Navigator.of(context).pushNamed(
                                appRouteAddEditAddressScreen,
                                arguments: {
                                  'addressId': addresses[index].id,
                                  'userId': _userId,
                                },
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
