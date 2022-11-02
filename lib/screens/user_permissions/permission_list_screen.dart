import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../values/app_permissions.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../values/app_routes.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';

class PermissionListScreen extends StatefulWidget {
  const PermissionListScreen({this.fromTabScreen, Key? key}) : super(key: key);
  final bool? fromTabScreen;
  @override
  State<PermissionListScreen> createState() => _PermissionListScreenState();
}

class _PermissionListScreenState extends State<PermissionListScreen> {
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

  // Widget _trailingWidget({
  //   bool isExpanded = true,
  // }) {
  //   return LayoutBuilder(
  //     builder: (context, boxConstraints) => Container(
  //       // color: Colors.red,
  //       width: boxConstraints.maxWidth * 0.3,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           // Text(boxConstraints.maxWidth.ceil().toString()),

  //           IconButton(
  //             onPressed: () {},
  //             icon: const Icon(
  //               Icons.mode_edit_outline_outlined,
  //             ),
  //           ),
  //           Icon(
  //             isExpanded
  //                 ? Icons.keyboard_arrow_up_outlined
  //                 : Icons.keyboard_arrow_down_outlined,
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  List<Widget> _buildWidgetList(
      {required String? parentId,
      required List<PermissionData> allPermissionList}) {
    List<Widget> widgetList = [];
    final dataList = allPermissionList
        .where((element) => element.parentId == parentId)
        .toList();

    for (var i = 0; i < dataList.length; i++) {
      // final childrenList = allPermissionList
      //     .where((element) => element.parentId == dataList[i].id)
      //     .toList();
      // var isExpanded = false;
      widgetList.add(
        ExpansionTile(
          title: Text(dataList[i].label ?? dataList[i].name!),
          // onExpansionChanged: (value) {
          //   isExpanded = value;
          // },

          childrenPadding: const EdgeInsets.only(left: 20),
          leading: IconButton(
            onPressed: () {
              if (PermissionHelper().validateUserPermission(
                userData: _userData!,
                userPermissionList: _userPermissionList,
                permission: appPermissionAddEditPermission,
              )) {
                Navigator.of(context).pushNamed(
                  appRouteAddEditPermissionScreen,
                  arguments: dataList[i].id,
                );
              }
            },
            icon: const Icon(
              Icons.mode_edit_outline_outlined,
            ),
          ),

          children: _buildWidgetList(
              parentId: dataList[i].id!, allPermissionList: allPermissionList),
        ),
      );
      // }
    }

    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.fromTabScreen == true
          ? null
          : const AppBarWidget(
              title: appTitlePermissions,
            ),
      floatingActionButton: !PermissionHelper().validateUserPermission(
        userData: _userData!,
        userPermissionList: _userPermissionList,
        permission: appPermissionAddEditPermission,
      )
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(appRouteAddEditPermissionScreen);
              },
            ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const CircularLoaderWidget()
          : StreamBuilder<List<PermissionData>>(
              stream: PermissionHelper().getAllPermissionStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(appTitleSomethingWentWrong);
                } else if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularLoaderWidget();
                  }
                  final permissionList = snapshot.data;
                  // return ListView.builder(
                  //   itemCount: permissionList!.length,
                  //   itemBuilder: (context, index) {
                  //     return Card(
                  //       child: PermissionListTileWidget(
                  //         permissionDetails: permissionList[index],
                  //         onTap: () {
                  //           if (PermissionHelper().validateUserPermission(
                  //             userData: _userData!,
                  //             userPermissionList: _userPermissionList,
                  //             permission: appPermissionAddEditPermission,
                  //           )) {
                  //             Navigator.of(context).pushNamed(
                  //               appRouteAddEditPermissionScreen,
                  //               arguments: permissionList[index].id,
                  //             );
                  //           }
                  //         },
                  //       ),
                  //     );
                  //   },
                  // );

                  return ListView(
                    children: _buildWidgetList(
                        parentId: null, allPermissionList: permissionList!),
                  );
                } else {
                  return const CircularLoaderWidget();
                }
              },
            ),
    );
  }
}
