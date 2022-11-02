import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../common_methods/common_methods.dart';
import '../../helpers/customers_helper.dart';
import '../../helpers/permission_helper.dart';
import '../../helpers/service_provider_helper.dart';
import '../../helpers/technician_helper.dart';
import '../../helpers/user_helper.dart';
import '../../models/customer.dart';
import '../../models/permission_data.dart';
import '../../models/service_provider.dart';
import '../../models/technician.dart';
import '../../models/user.dart' as user;
import '../../widgets/restart_app_widget.dart';
import '../../values/static_values.dart';
import '../../values/app_routes.dart';
import '../../values/colors.dart';
import '../../values/string_en.dart';

class ContinueAsScreen extends StatefulWidget {
  const ContinueAsScreen({Key? key}) : super(key: key);

  @override
  State<ContinueAsScreen> createState() => _ContinueAsScreenState();
}

class _ContinueAsScreenState extends State<ContinueAsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedType;
  List<PermissionData> userPermissionList = [];

  // var _isLoading = false;
  // var _isInit = true;
  // @override
  // void didChangeDependencies() async {
  //   if (_isInit) {

  //   }
  //   _isInit = false;

  //   super.didChangeDependencies();
  // }

  Widget _buttonWidget({
    required String title,
    required IconData icon,
    required void Function() onPressed,
    bool isWeb = false,
  }) {
    return Container(
      width: isWeb ? 400 : null,
      // height: isWeb ? 70 : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FaIcon(
                icon,
                size: isWeb ? 38 : 25,
              ),
              Text(
                title,
                style: TextStyle(fontSize: isWeb ? 20 : 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginType({
    required String type,
    required String title,
    required IconData icon,
    double size = 90,
  }) {
    return GestureDetector(
      // splashFactory: NoSplash.splashFactory,
      // splashColor: Colors.transparent,
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 3.5,
                    color: _selectedType != type
                        ? appColorSecondGradient
                        : Colors.green,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 45,
                  // color: Theme.of(context).primaryColor,
                ),
              ),
              _selectedType != type
                  ? const SizedBox()
                  : Positioned(
                      right: 0.0,
                      bottom: 15.0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: appColorWhite,
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 0.0,
                            color: appColorWhite,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 30,
                          color: Colors.green,
                        ),
                      ),
                    ),
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Text(
            title,
            style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: _selectedType != type ? null : Colors.green),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final isWeb = deviceSize.width > 600;
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 60,
                ),
                const Text(
                  appTitleWekcome,
                  style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  appTitleTellUsWhoYouAre,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                _loginType(
                  type: appRoleServiceProvider,
                  title: appTitleServiceProvider,
                  icon: FontAwesomeIcons.chalkboardUser,
                ),
                _loginType(
                  type: appRoleTechnician,
                  title: appTitleTechnician,
                  icon: FontAwesomeIcons.screwdriverWrench,
                ),
                _loginType(
                  type: appRoleCustomer,
                  title: appTitleCustomer,
                  icon: FontAwesomeIcons.userGroup,
                ),
                const SizedBox(
                  height: 30,
                ),

                const SizedBox(
                  height: 30,
                ),
                // const Expanded(child: SizedBox()),
                _buttonWidget(
                  title: 'Continue With Email',
                  icon: FontAwesomeIcons.envelope,
                  isWeb: isWeb,
                  onPressed: () {
                    if (_selectedType != null) {
                      Navigator.of(context)
                          .pushNamed(appRouteLoginScreen,
                              arguments: _selectedType)
                          .then((value) {
                        Navigator.of(context).pop();
                      });
                    } else {
                      displaySnackbar(
                          context: context, msg: 'Please Select User Role');
                    }
                  },
                ),
                _buttonWidget(
                  title: 'Continue With Google',
                  icon: FontAwesomeIcons.google,
                  isWeb: isWeb,
                  onPressed: () async {
                    if (_selectedType == null) {
                      return displaySnackbar(
                          context: context, msg: 'Please Select User Role');
                    }
                    restartFunction() {
                      RestartAppWidget.restartApp(context);
                    }

                    var message = appTitleSomethingWentWrong;
                    final navigator = Navigator.of(context);
                    userPermissionList = await PermissionHelper()
                        .getDefaultPermission(userType: _selectedType!);
                    final FirebaseAuth auth = FirebaseAuth.instance;

                    GoogleSignInAccount? userSignin;

                    final GoogleSignIn googleSignIn =
                        GoogleSignIn(scopes: <String>[
                      "email",
                    ]);
                    userSignin = await googleSignIn.signIn();
                    final authntication = await userSignin?.authentication;
                    OAuthCredential? credential;
                    credential = GoogleAuthProvider.credential(
                        idToken: authntication!.idToken,
                        accessToken: authntication.accessToken);

                    final authData =
                        await auth.signInWithCredential(credential);

                    final currentUserData =
                        await UsersHelper().getCurrentUserDetails();

                    if (currentUserData == null) {
                      // Navigator.of(context).pushNamed(
                      //   appRouteRegisterWithGoogleScreen,
                      //   arguments: user.User(
                      //     id: null,
                      //     email: authData.user?.email,
                      //     fullName: authData.user?.displayName,
                      //     mobile: authData.user?.phoneNumber,
                      //     role: _selectedType,
                      //     authId: authData.user?.uid,
                      //   ),
                      // );
                      final userData = user.User(
                        id: null,
                        email: authData.user?.email,
                        fullName: authData.user?.displayName,
                        mobile: authData.user?.phoneNumber,
                        role: _selectedType,
                        authId: authData.user?.uid,
                      );
                      await UsersHelper()
                          .createAppUser(
                        userData: userData,
                      )
                          .then((value) async {
                        final userId = value!;

                        if (_selectedType == appRoleCustomer) {
                          final customerData = Customer(
                            id: null,
                            userId: userId,
                            address: '',
                            email: userData.email,
                            fullName: userData.fullName,
                            latitude: null,
                            longitude: null,
                            mobile: userData.mobile,
                          );
                          await CustomersHelper()
                              .addCustomerData(customerData: customerData)
                              .then((value) {
                            message = value!;
                          });

                          await PermissionHelper().updateUserPermissionList(
                            selectedPermissionList: userPermissionList,
                            userId: userId,
                          );
                          navigator.pushNamed(appRouteAddEditAddressScreen,
                              arguments: {
                                'userId': userId,
                              }).then((value) {
                            restartFunction();
                          });
                        } else if (_selectedType == appRoleTechnician) {
                          final technicianData = Technician(
                            id: null,
                            userId: userId,
                            address: '',
                            email: userData.email,
                            fullName: userData.fullName,
                            latitude: null,
                            longitude: null,
                            mobile: userData.mobile,
                          );

                          await TechnicianHelper()
                              .addTechnicianData(technicianData: technicianData)
                              .then((value) {
                            message = value!;
                          });
                          await PermissionHelper().updateUserPermissionList(
                            selectedPermissionList: userPermissionList,
                            userId: userId,
                          );
                        } else if (_selectedType == appRoleServiceProvider) {
                          final serviceProviderData = ServiceProvider(
                            id: null,
                            userId: userId,
                            email: userData.email,
                            fullName: userData.fullName,
                            mobile: userData.mobile,
                          );
                          await ServiceProviderHelper()
                              .addUpdateServiceProviderData(
                                  serviceProviderData: serviceProviderData)
                              .then((value) {
                            // message = value!;
                          });

                          await PermissionHelper().updateUserPermissionList(
                            selectedPermissionList: userPermissionList,
                            userId: userId,
                          );
                        }
                      });
                      if (_scaffoldKey.currentContext != null) {
                        displaySnackbar(
                            context: _scaffoldKey.currentContext!,
                            msg: message);
                      }
                      // navigator.pop();

                      if (_selectedType == appRoleCustomer) {
                        restartFunction();
                      }
                    } else {
                      if (currentUserData.role != _selectedType) {
                        displaySnackbar(
                          context: context,
                          msg:
                              'You selected $_selectedType but you account already exist as ${currentUserData.role}',
                        );
                      }
                    }
                  },
              
                ),

                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
