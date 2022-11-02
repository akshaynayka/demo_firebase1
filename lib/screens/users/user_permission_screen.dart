import 'package:flutter/material.dart';
import '../../common_methods/common_methods.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/round_button_widget.dart';

class UserPermissionScreen extends StatefulWidget {
  const UserPermissionScreen({Key? key}) : super(key: key);

  @override
  State<UserPermissionScreen> createState() => _UserPermissionScreenState();
}

class _UserPermissionScreenState extends State<UserPermissionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _isLoading = false;
  bool _isInit = true;
  String? _userId;
  List<PermissionData> userPermissionList = [];
  List<PermissionData> allPermissionList = [];
  // List<PermissionData> orderedPermissionList = [];
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      _userId = args;

      if (args != null) {
        setState(() {
          _isLoading = true;
        });

        allPermissionList = await PermissionHelper().getAllPermissionList();
        userPermissionList =
            await PermissionHelper().getAllUserPermissions(userId: _userId);

        // _orderPermissionList(parentId: null);
        // final data = await UsersHelper().getUserDetails(_userId);
        // _userData = data!;

        setState(() {
          _isLoading = false;
        });
      }
    }
    setState(() {
      _isInit = false;
    });

    super.didChangeDependencies();
  }

  // _orderPermissionList({required String? parentId, double padding = 0}) {
  //   final dataList = allPermissionList
  //       .where((element) => element.parentId == parentId)
  //       .toList();

  //   for (var permissionData in dataList) {
  //     permissionData.padding = padding;
  //     orderedPermissionList.add(
  //       permissionData,
  //     );
  //     _orderPermissionList(parentId: permissionData.id, padding: padding + 40);
  //   }
  // }

  void _addUserPermission({required PermissionData permissionData}) {
    final dataExists =
        userPermissionList.any((element) => element.id == permissionData.id);

    if (!dataExists) {
      userPermissionList.add(permissionData);
    }
  }

  void _addAllChildrenPermission({required PermissionData permissionData}) {
    _addUserPermission(permissionData: permissionData);

    final childrenList = allPermissionList
        .where((element) => element.parentId == permissionData.id)
        .toList();
    for (var data in childrenList) {
      _addUserPermission(permissionData: data);
      _addAllChildrenPermission(permissionData: data);
    }
  }

  void _removeAllChildrenPermission({required PermissionData permissionData}) {
    // _addUserPermission(permissionData: permissionData);

    final childrenList = allPermissionList
        .where((element) => element.parentId == permissionData.id)
        .toList();
    userPermissionList.removeWhere((data) => data.id == permissionData.id);

    for (var value in childrenList) {
      userPermissionList.removeWhere((data) => data.id == value.id);
      _removeAllChildrenPermission(permissionData: value);
    }
  }

  List<Widget> _buildWidgetList({required String? parentId}) {
    List<Widget> widgetList = [];
    final dataList = allPermissionList
        .where((element) => element.parentId == parentId)
        .toList();

    for (var i = 0; i < dataList.length; i++) {
      final isChildExists = allPermissionList
          .any((element) => element.parentId == dataList[i].id);
      // final childrenList = allPermissionList
      //     .where((element) => element.parentId == dataList[i].id)
      //     .toList();
      widgetList.add(
        ExpansionTile(
          title: Text(dataList[i].label ?? dataList[i].name!),
          // tilePadding: EdgeInsets.only(left: 0),
          childrenPadding: const EdgeInsets.only(left: 20),
          trailing: isChildExists ? null : const SizedBox(),
          leading: Checkbox(
            value: userPermissionList
                        .firstWhere((data) => data.id == dataList[i].id!,
                            orElse: () => PermissionData(
                                id: null,
                                parentId: null,
                                name: null,
                                label: null))
                        .id !=
                    null
                ? true
                : false,
            onChanged: (bool? value) {
              if (value!) {
                _addAllChildrenPermission(permissionData: dataList[i]);

                setState(() {});
              } else {
                _removeAllChildrenPermission(permissionData: dataList[i]);
                setState(() {
                  // userPermissionList
                  //     .removeWhere((data) => data.id == dataList[i].id);
                });
              }
            },
          ),
          children: _buildWidgetList(parentId: dataList[i].id!),
        ),
      );
      // }
    }

    return widgetList;
  }

  _selectAllPermission() {
    for (var data in allPermissionList) {
      _addUserPermission(permissionData: data);
    }
  }

  _removeAllPermission() {
    userPermissionList = [];
  }

  bool? _isAllSelected() {
    var status = false;
    if (userPermissionList.length == allPermissionList.length) {
      for (var data in allPermissionList) {
        if (userPermissionList.any((item) => item.id == data.id)) {
          status = true;
        }
      }
    }
    return status;
  }

  void _submitForm() async {
    var messsage = appTitleSomethingWentWrong;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    try {
      await PermissionHelper()
          .updateUserPermissionList(
        selectedPermissionList: userPermissionList,
        userId: _userId!,
      )
          .then((value) {
        messsage = 'Permissions Updated';
      });
      displaySnackbar(context: _scaffoldKey.currentContext!, msg: messsage);
      if (!mounted) return;
      Navigator.of(context).pop();
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //     appRouteCustomerListScreen, ModalRoute.withName('/'));

    } catch (error) {
      debugPrint('error---> $error');

      const errorMessage = appTitleSomethingWentWrong;
      showErrorDialog(errorMessage, context);
    }

    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey,
      appBar: const AppBarWidget(title: 'User Permissions'),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const CircularLoaderWidget()
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 30.0,
                    ),
                    ExpansionTile(
                      title: const Text(appTitleAllPermissions),
                      // tilePadding: EdgeInsets.only(left: 0),
                      childrenPadding: const EdgeInsets.only(left: 20),
                      trailing: const SizedBox(),
                      leading: Checkbox(
                        value: _isAllSelected(),
                        onChanged: (bool? value) {
                          if (value!) {
                            _selectAllPermission();
                          } else {
                            _removeAllPermission();
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    const Divider(),
                    Flexible(
                      child: ListView(
                        children: _buildWidgetList(parentId: null),
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    RoundButtonWidget(
                      width: deviceSize.width * 0.5,
                      label: appTitleUpdate,
                      onPressed: _submitForm,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
