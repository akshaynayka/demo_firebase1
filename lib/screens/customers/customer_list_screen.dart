import 'package:provider/provider.dart';
import '../../values/static_values.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/app_permissions.dart';

import '../../helpers/customers_helper.dart';
import '../../models/customer.dart';
import '../../values/app_routes.dart';
import '../../values/colors.dart';
import '../../values/string_en.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/customer_list_tile_widget.dart';
import 'package:flutter/material.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({Key? key}) : super(key: key);

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
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
      floatingActionButton: !PermissionHelper().validateUserPermission(
        userData: _userData!,
        userPermissionList: _userPermissionList,
        permission: appPermissionAddEditCustomer,
      )
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context).pushNamed(appRouteAddEditCustomerScreen);
              },
            ),
      backgroundColor: appColorBackground,
      body: _isLoading
          ? const CircularLoaderWidget()
          : StreamBuilder<List<Customer>>(
              stream: CustomersHelper().gellAllCustomersStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(appTitleSomethingWentWrong);
                } else if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularLoaderWidget();
                  }
                  final customers = snapshot.data;
                  return ListView.builder(
                    itemCount: customers!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: CustomerListTileWidget(
                          changePermission: _userData!.role == appRoleAdmin,
                          customerData: customers[index],
                          onTap: () {
                            if (PermissionHelper().validateUserPermission(
                                  userData: _userData!,
                                  userPermissionList: _userPermissionList,
                                  permission: appPermissionAddEditCustomer,
                                ) &&
                                (customers[index].createdBy == _userData!.id ||
                                    _userData!.role == appRoleAdmin)) {
                              Navigator.of(context).pushNamed(
                                appRouteAddEditCustomerScreen,
                                arguments: customers[index].id,
                              );
                            }
                          },
                          addressPermission: PermissionHelper()
                                  .validateUserPermission(
                                userData: _userData!,
                                userPermissionList: _userPermissionList,
                                permission: appPermissionAddressList,
                              ) &&
                              (customers[index].createdBy == _userData!.id ||
                                  _userData!.role == appRoleAdmin),
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
