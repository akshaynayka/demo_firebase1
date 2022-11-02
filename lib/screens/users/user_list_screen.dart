import '../../values/static_values.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../providers/user_provider.dart';
import '../../values/app_permissions.dart';
import '../../helpers/user_helper.dart';
import '../../models/user.dart';
import '../../widgets/user_list_tile_widget.dart';
import '../../values/app_routes.dart';
import '../../values/colors.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({this.fromTabScreen, Key? key}) : super(key: key);
  final bool? fromTabScreen;
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
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
              title: appTitleUsers,
            ),
      floatingActionButton: !PermissionHelper().validateUserPermission(
        userData: _userData!,
        userPermissionList: _userPermissionList,
        permission: appPermissionAddEditUser,
      )
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context).pushNamed(appRouteAddEditUserScreen);
              },
            ),
      backgroundColor: appColorBackground,
      body: _isLoading
          ? const CircularLoaderWidget()
          : StreamBuilder<List<User>>(
              stream: UsersHelper().gellAllUsersStream(role: appRoleAdmin),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(appTitleSomethingWentWrong);
                } else if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularLoaderWidget();
                  }
                  final users = snapshot.data;
                  return ListView.builder(
                    itemCount: users!.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: UserListTileWidget(
                          userData: users[index],
                          onTap: () {
                            if (PermissionHelper().validateUserPermission(
                              userData: _userData!,
                              userPermissionList: _userPermissionList,
                              permission: appPermissionAddEditUser,
                            )) {
                              Navigator.of(context).pushNamed(
                                appRouteAddEditUserScreen,
                                arguments: users[index].id,
                              );
                            }
                          },
                          userPermission:
                              PermissionHelper().validateUserPermission(
                            userData: _userData!,
                            userPermissionList: _userPermissionList,
                            permission: appPermissionAddEditUserPermission,
                          ),
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
