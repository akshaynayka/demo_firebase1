import '../common_methods/common_methods.dart';

import '../widgets/tab_screen/admin_tab_screen_widget.dart';
import '../widgets/tab_screen/customer_tab_screen_widget.dart';
import '../widgets/tab_screen/service_provider_tab_screen_widget.dart';
import '../widgets/tab_screen/technician_tab_screen_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../helpers/user_helper.dart';
import '../main.dart';
import '../helpers/permission_helper.dart';
import '../models/permission_data.dart';
import '../models/user.dart';
import '../widgets/circular_loader_widget.dart';
import '../widgets/appbar_widget.dart';
import '../widgets/side_drawer.dart';
import '../values/static_values.dart';
import '../providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // TabController? _tabController;
  // bool _isInit = true;
  User? _userData = User(
    id: null,
    email: null,
    fullName: null,
    mobile: null,
    role: null,
    authId: null,
  );
  List<PermissionData> _userPermissionList = [];
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _getUserData();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('new onmessage oppen app message----->');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(notification.title!),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.body!),
                ],
              ),
            ),
          ),
        );
      }
    });
  }

  _getUserData() async {
    setState(() {
      _isLoading = true;
    });
    _userData = Provider.of<UserProvider>(context, listen: false).currentUser;

    _userPermissionList =
        await PermissionHelper().getAllUserPermissions(userId: _userData!.id);
    setState(() {
      _isLoading = false;
    });
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    debugPrint('device info------>');
    await UsersHelper().storeDeviceInfo(
      deviceData: deviceInfo.toMap(),
      userId: _userData!.id,
    );
  }

  Widget _getDashboard(String userRole) {
    switch (userRole) {
      case appRoleAdmin:
        return AdminTabScreenWidget(
          userData: _userData!,
        );
      case appRoleServiceProvider:
        return ServiceProviderTabScreenWidget(
          userData: _userData!,
          userPermissionList: _userPermissionList,
        );
      case appRoleTechnician:
        // return TechnicianDashboardWidget(
        //   userData: _userData!,
        //   userPermissionList: _userPermissionList,
        // );
        return TechnicianTabScreenWidget(
          userData: _userData!,
        );
      default:
        return CustomerTabScreenWidget(
          userData: _userData!,
          userPermissionList: _userPermissionList,
        );
    }

    // switch (expression) {
    //   case value:
    //     break;
    //   default:
    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return willPopExitCallback(context);
      },
      child: _isLoading
          ? Scaffold(
              appBar: const AppBarWidget(),
              drawer: SideDrawer(userData: _userData!),
              body: const CircularLoaderWidget(),
            )
          : _getDashboard(_userData!.role!),
    );
    // : Scaffold(
    //     floatingActionButton: FloatingActionButton(
    //       child: Icon(
    //         Icons.send,
    //       ),
    //       onPressed: () {
    //         flutterLocalNotificationsPlugin.show(
    //             0,
    //             "Testing hello",
    //             "How you doin ?",
    //             NotificationDetails(
    //                 android: AndroidNotificationDetails(
    //                     channel.id, channel.name,
    //                     channelDescription: channel.description,
    //                     importance: Importance.high,
    //                     color: Colors.blue,
    //                     playSound: true,
    //                     icon: '@mipmap/ic_launcher')));
    //       },
    //     ),
    //     appBar: const AppBarWidget(),
    //     body: Center(child: Text('data')));
  }
}
