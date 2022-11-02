import 'package:flutter/material.dart';
import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../values/app_routes.dart';
import '../../values/string_en.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';
import '../../models/user.dart' as user;

class RegisterWithGoogleScreen extends StatefulWidget {
  const RegisterWithGoogleScreen({Key? key}) : super(key: key);

  @override
  State<RegisterWithGoogleScreen> createState() =>
      _RegisterWithGoogleScreenState();
}

class _RegisterWithGoogleScreenState extends State<RegisterWithGoogleScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var _isInit = true;
  var _isLoading = true;

  var _userData = user.User(
    id: null,
    email: '',
    fullName: '',
    role: null,
    mobile: '',
    authId: null,
  );
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _userData = ModalRoute.of(context)?.settings.arguments as user.User;
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  //   Future<void> _submitAuthform() async {
  //   var message = appTitleSomethingWentWrong;
  //   String? userId;

  //   _restartFunction() {
  //     RestartAppWidget.restartApp(context);
  //   }

  //   // UserCredential authResult;
  //   if (!_formKey.currentState!.validate()) {
  //     // Invalid!
  //     return;
  //   }
  //   _formKey.currentState!.save();
  //   final navigator = Navigator.of(context);

  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     await UsersHelper()
  //         .createAppUser(userData: _userData)
  //         .then((value) async {
  //       userId = value!;

  //       if (_userType == appRoleCustomer) {
  //         final customerData = Customer(
  //           id: null,
  //           userId: userId,
  //           address: '',
  //           email: _userData.email,
  //           fullName: _userData.fullName,
  //           latitude: null,
  //           longitude: null,
  //           mobile: _userData.mobile,
  //         );
  //         await CustomersHelper()
  //             .addCustomerData(customerData: customerData)
  //             .then((value) {
  //           message = value!;
  //         });

  //         await PermissionHelper().updateUserPermissionList(
  //           selectedPermissionList: userPermissionList,
  //           userId: userId!,
  //         );
  //         navigator.pushNamed(appRouteAddEditaddressScreen, arguments: {
  //           'userId': userId,
  //         }).then((value) {
  //           _restartFunction();
  //         });
  //       } else if (_userType == appRoleTechnician) {
  //         final technicianData = Technician(
  //           id: null,
  //           userId: userId,
  //           address: '',
  //           email: _userData.email,
  //           fullName: _userData.fullName,
  //           latitude: null,
  //           longitude: null,
  //           mobile: _userData.mobile,
  //         );

  //         await TechnicianHelper()
  //             .addTechnicianData(technicianData: technicianData)
  //             .then((value) {
  //           message = value!;
  //         });
  //         await PermissionHelper().updateUserPermissionList(
  //           selectedPermissionList: userPermissionList,
  //           userId: userId!,
  //         );
  //       } else if (_userType == appRoleServiceProvider) {
  //         final serviceProviderData = ServiceProvider(
  //           id: null,
  //           userId: userId,
  //           email: _userData.email,
  //           fullName: _userData.fullName,
  //           mobile: _userData.mobile,
  //         );
  //         await ServiceProviderHelper()
  //             .addUpdateServiceProviderData(
  //                 serviceProviderData: serviceProviderData)
  //             .then((value) {
  //           message = value!;
  //         });

  //         await PermissionHelper().updateUserPermissionList(
  //           selectedPermissionList: userPermissionList,
  //           userId: userId!,
  //         );
  //       }
  //     });

  //     displaySnackbar(context: _scaffoldKey.currentContext!, msg: message);
  //     // navigator.pop();

  //     if (_userType != appRoleCustomer) {
  //       _restartFunction();
  //     }
  //   } on PlatformException catch (error) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     var message = 'An error occurred, please check your credentials';
  //     if (error.message != null) {
  //       message = error.message!;
  //     }
  //     displaySnackbar(context: context, msg: message);
  //   } catch (error) {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     var message = 'An error occurred, please check your credentials';

  //     displaySnackbar(context: context, msg: message);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 255,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Color(0xffe75c00),
                          Color(0xffea8100),
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
                  const Positioned(
                    bottom: 25.0,
                    right: 40.0,
                    child: Text(
                      appTitleRegister,
                      style: TextStyle(
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
                  initialValue: _userData.fullName,
                  icon: Icons.person,
                  lableText: appTitleFullName,
                  labelColor: Theme.of(context).primaryColor,
                  iconColor: Theme.of(context).primaryColor,
                  validator: nameValidator,
                  textInputAction: TextInputAction.next,
                  onSaved: (value) {
                    _userData.fullName = value;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25.0,
                  vertical: 10.0,
                ),
                child: TextFormFieldWidget(
                  initialValue: _userData.email,
                  readOnly: true,
                  icon: Icons.email_outlined,
                  lableText: appTitleEmail,
                  labelColor: Theme.of(context).primaryColor,
                  iconColor: Theme.of(context).primaryColor,
                  validator: requiredEmailValidator,
                  textInputAction: TextInputAction.next,
                  onSaved: (value) {
                    _userData.email = removeSpaceFromString(value!);
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
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: <Color>[
                          Color(0xffe75c00),
                          Color(0xffea8100),
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
                            // onPressed: _submitAuthform,
                            onPressed: () {},
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
    );
  }
}
