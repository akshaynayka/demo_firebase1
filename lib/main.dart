import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:demo_firebase1/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import '../screens/configuration/configuration_screen.dart';
import '../values/string_en.dart';
import '../screens/account/my_technician_list_screen.dart';
import '../screens/auth/register_with_google_screen.dart';
import '../screens/call_requests/add_edit_call_request_screen.dart';
import '../screens/call_requests/call_request_list_screen.dart';
import '../screens/call_requests/call_request_technician_list_screen.dart';
import '../screens/customer_call_request/add_edit_customer_call_request_screen.dart';
import '../screens/customer_call_request/customer_call_request_list_screen.dart';
import '../screens/customer_call_request/service_provider_list_for_customer_screen.dart';
import '../screens/customer_call_request/technician_list_for_customer_screen.dart';
import '../widgets/restart_app_widget.dart';
import '../screens/auth/continue_as_screen.dart';
import '../screens/service_provider/add_edit_service_provider_screen.dart';
import '../screens/service_provider/service_provider_list_screen.dart';
import '../screens/user_permissions/add_edit_permission.dart';
import '../screens/user_permissions/permission_list_screen.dart';
import '../screens/users/user_permission_screen.dart';
import '../helpers/user_role_helper.dart';
import '../models/user.dart' as user;
import '../providers/user_provider.dart';
import '../screens/account/my_profile_screen.dart';

import '../screens/address/add_edit_address_screen.dart';
import '../screens/address/address_list_screen.dart';
import 'screens/technician/add_edit_technician_screen.dart';
import '../screens/users/add_edit_user_screen.dart';
import '../screens/users/user_list_screen.dart';

import '../screens/calls/add_edit_call_screen.dart';
import '../screens/calls/call_list_screen.dart';
import '../screens/customers/add_edit_customer_screen.dart';
import '../screens/customers/customer_list_screen.dart';
import 'screens/home_screen.dart';
import '../screens/loading_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/services/add_edit_service_screen.dart';
import '../screens/services/service_list_screen.dart';
import 'screens/technician/technician_list_screen.dart';
import '../values/app_routes.dart';
import '../values/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> _firebaseMassagingBackgroungHandler(message) async {
  await Firebase.initializeApp();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notification',
  description: 'notification channel dscription',
  importance: Importance.high,
  playSound: true,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: kIsWeb ? null : 'demo_firebase1',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMassagingBackgroungHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // FirebaseMessaging.onMessage.listen((event) {
  //    print('hello---->');
  //   print(event.data);
  // });

  await dotenv.load(fileName: ".env");
  HttpOverrides.global = MyHttpOverrides();

  runApp(const RestartAppWidget(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        // title: DotEnv.get('APP_TITLE', fallback: 'Staff Management'),
        title: dotenv.get('APP_TITLE', fallback: appTitle),
        theme: ThemeData(
          primarySwatch: appColorPrimarySwatch,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen(
                flag: 'ConnectionState.waiting',
              );
            } else if (userSnapshot.hasData) {
              return StreamBuilder<List<user.User>>(
                  stream: UserRoleHelper().getRoleStream(
                    authId: userSnapshot.data!.uid,
                    context: ctx,
                  ),
                  builder: (ctx, roleSnapshot) {
                    // if (roleSnapshot.connectionState ==
                    //     ConnectionState.waiting) {
                    //   return const LoadingScreen(
                    //     flag: 'roleSnapshot.waiting',
                    //   );
                    // } else

                    if (roleSnapshot.hasData) {
                      // print("print user has data---->");
                      // print(roleSnapshot.data!.first.toJson());
                      return const HomeScreen();
                    } else if (roleSnapshot.hasError) {
                      return const ContinueAsScreen();
                    }
                    return const LoadingScreen(
                      flag: 'roleSnapshot.hasData',
                    );
                  });
            }
            return const ContinueAsScreen();
          },
        ),

        routes: {
          // '/': (context) => const LoginScreen(),
          appRouteHomeScreen: (context) => const HomeScreen(),
          appRouteRegisterScreen: (context) => const RegisterScreen(),
          appRouteLoginScreen: (context) => const LoginScreen(),
          appRouteCustomerListScreen: (context) => const CustomerListScreen(),
          appRouteAddEditCustomerScreen: (context) =>
              const AddEditCustomerScreen(),
          appRouteTechnicianListScreen: (context) =>
              const TechnicianListScreen(),
          appRouteServiceListScreen: (context) => const ServiceListScreen(),
          appRouteAddEditServiceScreen: (context) =>
              const AddEditServiceScreen(),
          appRouteCallListScreen: (context) => const CallListScreen(),
          appRouteCallRequestTechnicianListScreen: (context) =>
              const CallRequestTechnicianListScreen(),
          appRouteAddEditCallScreen: (context) => const AddEditCallScreen(),
          appRouteAddEditCallRequestsScreen: (context) =>
              const AddEditCallRequestScreen(),
          appRouteAddEditTechnicianScreen: (context) =>
              const AddEditTechnicianScreen(),
          appRouteUserListScreen: (context) => const UserListScreen(),
          appRouteAddEditUserScreen: (context) => const AddEditUserScreen(),
          appRouteAddEditAddressScreen: (context) =>
              const AddEditAddressScreen(),
          appRouteAddressListScreen: (context) => const AddressListScreen(),
          appRouteMyProfileScreen: (context) => const MyProfileScreen(),
          appRouteUserPermissionScreen: (context) =>
              const UserPermissionScreen(),
          appRoutePermissionListScreen: (context) =>
              const PermissionListScreen(),
          appRouteAddEditPermissionScreen: (context) =>
              const AddEditPermissionScreen(),
          // appRouteContinueAsScreen: (context) => const ContinueAsScreen(),
          appRouteServiceProviderListScreen: (context) =>
              const ServiceProviderListScreen(),
          appRouteAddEditServiceProviderScreen: (context) =>
              const AddEditServiceProviderScreen(),
          appRouteMyTechnicianListScreen: (context) =>
              const MyTechnicianListScreen(),
          appRouteCallRequestsListScreen: (context) =>
              const CallRequestListScreen(),
          appRouteTechnicianListForCustomerScreen: (context) =>
              const TechnicianListForCustomerScreen(),
          appRouteServiceProviderListForCustomerScreen: (context) =>
              const ServiceProviderListForCustomerScreen(),
          appRouteAddEditCustomerCallRequestScreen: (context) =>
              const AddEditCustomerCallRequestScreen(),
          appRouteCustomerCallRequestListScreen: (context) =>
              const CustomerCallRequestListScreen(),
          appRouteRegisterWithGoogleScreen: (context) =>
              const RegisterWithGoogleScreen(),
          appRouteConfigurationScreen: (context) => const ConfigurationScreen(),
        },
        // debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
