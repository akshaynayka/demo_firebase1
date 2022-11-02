import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../widgets/restart_app_widget.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../helpers/customers_helper.dart';
import '../../helpers/service_provider_helper.dart';
import '../../helpers/technician_helper.dart';
import '../../helpers/user_helper.dart';
import '../../models/customer.dart';
import '../../models/service_provider.dart';
import '../../models/technician.dart';
import '../../models/user.dart' as user;
import '../../values/static_values.dart';
import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../values/app_routes.dart';
import '../../values/string_en.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // List<PermissionData> _allPermissionList = [];
  List<PermissionData> _userPermissionList = [];

  final _auth = FirebaseAuth.instance;
  final Map<String, String?> _authData = {
    'name': '',
    'email': '',
    'password': '',
  };

  String? _userType;
  var _userData = user.User(
    id: null,
    email: '',
    fullName: '',
    role: null,
    mobile: '',
    authId: null,
  );
  var _isLoading = true;
  var _isInit = true;
  var _passwordVisible = false;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      _userType = args;
      // _allPermissionList = await PermissionHelper().getAllPermissionList();
      _userPermissionList =
          await PermissionHelper().getDefaultPermission(userType: _userType!);
    }
    _isInit = false;
    setState(() {
      _isLoading = false;
    });
    super.didChangeDependencies();
  }

  // _getDefaultPermission() {
  //   List<String> permissionList = [];
  //   if (_userType == appRoleCustomer) {
  //     permissionList = [
  //       appPermissionCallList,
  //       appPermissionServiceProvidersList,
  //       appPermissionTechnicianList
  //     ];
  //   } else if (_userType == appRoleTechnician) {
  //     permissionList = [
  //       appPermissionCallList,
  //       appPermissionCustomerList,
  //       appPermissionServiceProvidersList,
  //       appPermissionAddEditCall,
  //     ];
  //   } else if (_userType == appRoleServiceProvider) {
  //     permissionList = [
  //       appPermissionCallList,
  //       appPermissionAddEditCustomer,
  //       appPermissionCustomerList,
  //       appPermissionTechnicianList,
  //       appPermissionAddEditCall,
  //       appPermissionAddressList,
  //       appPermissionAddEditAddress,
  //     ];
  //   }

  //   for (var data in permissionList) {
  //     final permissionData = _allPermissionList.firstWhere(
  //         (element) => element.name == data,
  //         orElse: () => PermissionData(id: null, parentId: null, name: null));
  //     if (permissionData.id != null) {
  //       userPermissionList.add(permissionData);
  //     }
  //   }
  // }

  Future<void> _submitAuthform() async {
    var message = appTitleSomethingWentWrong;
    String? userId;

    restartFunction() {
      RestartAppWidget.restartApp(context);
    }

    // UserCredential authResult;
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    final navigator = Navigator.of(context);

    try {
      setState(() {
        _isLoading = true;
      });

      final authUser = await _auth.createUserWithEmailAndPassword(
        email: _authData['email']!,
        password: _authData['password']!,
      );
      _userData = user.User(
        id: null,
        email: _authData['email'],
        fullName: _authData['name'],
        role: _userType,
        mobile: _userData.mobile,
        authId: authUser.user!.uid,
      );

      await UsersHelper()
          .createAppUser(userData: _userData)
          .then((value) async {
        userId = value!;

        if (_userType == appRoleCustomer) {
          final customerData = Customer(
            id: null,
            userId: userId,
            address: '',
            email: _userData.email,
            fullName: _userData.fullName,
            latitude: null,
            longitude: null,
            mobile: _userData.mobile,
          );
          await CustomersHelper()
              .addCustomerData(customerData: customerData)
              .then((value) {
            message = value!;
          });

          await PermissionHelper().updateUserPermissionList(
            selectedPermissionList: _userPermissionList,
            userId: userId!,
          );
          navigator.pushNamed(appRouteAddEditAddressScreen, arguments: {
            'userId': userId,
          }).then((value) {
            restartFunction();
          });
        } else if (_userType == appRoleTechnician) {
          final technicianData = Technician(
            id: null,
            userId: userId,
            address: '',
            email: _userData.email,
            fullName: _userData.fullName,
            latitude: null,
            longitude: null,
            mobile: _userData.mobile,
          );

          await TechnicianHelper()
              .addTechnicianData(technicianData: technicianData)
              .then((value) {
            message = value!;
          });
          await PermissionHelper().updateUserPermissionList(
            selectedPermissionList: _userPermissionList,
            userId: userId!,
          );
        } else if (_userType == appRoleServiceProvider) {
          final serviceProviderData = ServiceProvider(
            id: null,
            userId: userId,
            email: _userData.email,
            fullName: _userData.fullName,
            mobile: _userData.mobile,
          );
          await ServiceProviderHelper()
              .addUpdateServiceProviderData(
                  serviceProviderData: serviceProviderData)
              .then((value) {
            message = value!;
          });

          await PermissionHelper().updateUserPermissionList(
            selectedPermissionList: _userPermissionList,
            userId: userId!,
          );
        }
        // print('user created${_userData.toJson()}');
      });

      displaySnackbar(context: _scaffoldKey.currentContext!, msg: message);
      // navigator.pop();

      if (_userType != appRoleCustomer) {
        restartFunction();
      }
    } on PlatformException catch (error) {
      setState(() {
        _isLoading = false;
      });
      var message = 'An error occurred, please check your credentials';
      if (error.message != null) {
        message = error.message!;
      }
      displaySnackbar(context: context, msg: message);
    } catch (error) {
      debugPrint('catch block exception--->');

      setState(() {
        _isLoading = false;
      });
      var message = 'An error occurred, please check your credentials';

      displaySnackbar(context: context, msg: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 255,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: 110.0,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(255, 68, 46, 46),
                                width: 3.0,
                              )),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                     Positioned(
                      bottom: 25.0,
                      right: 40.0,
                      child: Text(
                        appTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: TextFormFieldWidget(
                    icon: Icons.person,
                    lableText: _userType == appRoleServiceProvider
                        ? 'Bussiness / Store Name'
                        : appTitleFullName,
                    labelColor: Theme.of(context).primaryColor,
                    iconColor: Theme.of(context).primaryColor,
                    validator: nameValidator,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _authData['name'] = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: TextFormFieldWidget(
                    icon: Icons.email_outlined,
                    lableText: appTitleEmail,
                    labelColor: Theme.of(context).primaryColor,
                    iconColor: Theme.of(context).primaryColor,
                    validator: requiredEmailValidator,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onSaved: (value) {
                      _authData['email'] = removeSpaceFromString(value!);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: TextFormFieldWidget(
                    initialValue: _userData.mobile,
                    lableText: appTitleMobile,
                    icon: Icons.phone_android_outlined,
                    labelColor: Theme.of(context).primaryColor,
                    iconColor: Theme.of(context).primaryColor,
                    validator: nameValidator,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    onSaved: (value) {
                      _userData.mobile = value!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 10.0,
                  ),
                  child: StatefulBuilder(
                    builder: (context, setWidgetState) {
                      return TextFormFieldWidget(
                        icon: Icons.vpn_key,
                        lableText: appTitlePassword,
                        labelColor: Theme.of(context).primaryColor,
                        iconColor: Theme.of(context).primaryColor,
                        validator: nameValidator,
                        obscureText: !_passwordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            // color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setWidgetState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        textInputAction: TextInputAction.done,
                        onSaved: (value) {
                          _authData['password'] = value;
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  child: const Text(
                    appTitleForgotPassword,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Material(
                    elevation: 15.0,
                    borderRadius: BorderRadius.circular(25.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: <Color>[
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor,
                          ],
                        ),
                      ),
                      height: 50.0,
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : RoundButtonWidget(
                              label: appTitleRegister,
                              onPressed: _submitAuthform,
                            ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      appTitleHaveAnAccountAlready,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      child: const Text(
                        appTitleLogin,
                        style: TextStyle(
                          color: Color(0xffe75c00),
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(appRouteLoginScreen);
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
