import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../helpers/service_provider_helper.dart';
import '../../models/service_provider.dart';
import '../../values/static_values.dart';
import '../../helpers/user_helper.dart';
import '../../models/user.dart' as user;
import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';
import 'package:flutter/material.dart';

class AddEditServiceProviderScreen extends StatefulWidget {
  const AddEditServiceProviderScreen({Key? key}) : super(key: key);

  @override
  State<AddEditServiceProviderScreen> createState() =>
      _AddEditServiceProviderScreenState();
}

class _AddEditServiceProviderScreenState
    extends State<AddEditServiceProviderScreen> {
  bool _isInit = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _serviceProviderData = ServiceProvider(
    id: null,
    userId: null,
    email: null,
    fullName: null,
    mobile: null,
  );
  var _password = '';
  var _isLoading = false;
  var _isProcess = false;
  String? _serviceProviderId;
  List<PermissionData> _userPermissionList = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      _serviceProviderId = args;
      _userPermissionList = await UsersHelper()
          .getDefaultPermission(userType: appRoleServiceProvider);

      if (args != null) {
        setState(() {
          _isLoading = true;
        });
        final data = await ServiceProviderHelper()
            .getServiceProviderDetails(_serviceProviderId);
        _serviceProviderData = data!;

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

  void _submitForm() async {
    setState(() {
      _isProcess = true;
    });
    var message = appTitleSomethingWentWrong;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    try {
      final navigator = Navigator.of(context);

      if (_serviceProviderData.id != null) {
        message = (await ServiceProviderHelper().addUpdateServiceProviderData(
            serviceProviderData: _serviceProviderData))!;
        // messsage = '$appTitleServiceProvider updated';
      } else {
        final authUser = await UsersHelper().createFirebaseAuthUserWithApi(
          email: _serviceProviderData.email!,
          password: _password,
          context: context,
        );

        final userData = user.User(
          id: null,
          email: _serviceProviderData.email,
          fullName: _serviceProviderData.fullName,
          role: appRoleServiceProvider,
          mobile: _serviceProviderData.mobile,
          authId: authUser,
        );
        final userId = await UsersHelper().createAppUser(userData: userData);

        await PermissionHelper().updateUserPermissionList(
          selectedPermissionList: _userPermissionList,
          userId: userId!,
        );
        final serviceProviderData = ServiceProvider(
          id: null,
          userId: userId,
          email: _serviceProviderData.email,
          fullName: _serviceProviderData.fullName,
          mobile: _serviceProviderData.mobile,
        );

        message = (await ServiceProviderHelper().addUpdateServiceProviderData(
            serviceProviderData: serviceProviderData))!;

        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _serviceProviderData.email!);
      }
      displaySnackbar(context: _scaffoldKey.currentContext!, msg: message);
      navigator.pop();
    } catch (error) {
      debugPrint('error---> $error');

      var errorMessage = appTitleSomethingWentWrong;

      final errorString = error.toString();
      if (errorString.contains('email-already-in-use')) {
        errorMessage = 'This email is already in use';
      }

      showErrorDialog(errorMessage, context);
      setState(() {
        _isLoading = false;
      });
    }

    setState(() {
      _isProcess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: const AppBarWidget(title: appTitleServiceProvider),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const CircularLoaderWidget()
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Container(
                      //   width: double.infinity,
                      //   decoration: BoxDecoration(
                      //     borderRadius: const BorderRadius.only(
                      //       bottomLeft: Radius.circular(60),
                      //     ),
                      //     gradient: LinearGradient(
                      //       begin: Alignment.centerLeft,
                      //       end: Alignment.centerRight,
                      //       colors: <Color>[
                      //         Theme.of(context).primaryColor,
                      //         appColorSecondGradient,
                      //       ],
                      //     ),
                      //   ),
                      //   height: 70.0,
                      //   alignment: Alignment.topCenter,
                      //   child: const Text(
                      //     appTitleServiceProviderDetails,
                      //     style: TextStyle(
                      //       fontSize: 25.0,
                      //       color: Colors.white,
                      //       fontWeight: FontWeight.bold,
                      //     ),
                      //   ),
                      // ),

                      const SizedBox(
                        height: 30.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _serviceProviderData.fullName,
                          lableText: appTitleFullName,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _serviceProviderData.fullName = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _serviceProviderData.mobile,
                          lableText: appTitleMobile,
                          icon: Icons.phone_android_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          onSaved: (value) {
                            _serviceProviderData.mobile = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _serviceProviderData.email,
                          lableText: appTitleEmail,
                          icon: Icons.email_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: requiredEmailValidator,
                          onSaved: (value) {
                            _serviceProviderData.email =
                                removeSpaceFromString(value!);
                          },
                        ),
                      ),
                      if (_serviceProviderData.id == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: TextFormFieldWidget(
                            initialValue: _password,
                            lableText: appTitlePassword,
                            icon: Icons.bungalow_outlined,
                            labelColor: Theme.of(context).primaryColor,
                            iconColor: Theme.of(context).primaryColor,
                            validator: nameValidator,
                            textInputAction: TextInputAction.next,
                            onSaved: (value) {
                              _password = value!;
                            },
                          ),
                        ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      RoundButtonWidget(
                        width: deviceSize.width * 0.5,
                        label: _serviceProviderData.id != null
                            ? appTitleUpdate
                            : appTitleAdd,
                        onPressed: _submitForm,
                        isProccess: _isProcess,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
