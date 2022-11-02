import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../values/app_routes.dart';
import '../../providers/user_provider.dart';
import '../../values/static_values.dart';
import '../../helpers/user_helper.dart';
import '../../models/user.dart' as user;
import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../helpers/customers_helper.dart';
import '../../models/customer.dart';
import '../../values/api_end_points.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditCustomerScreen extends StatefulWidget {
  const AddEditCustomerScreen({Key? key}) : super(key: key);

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  bool _isInit = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _customerData = Customer(
    id: null,
    userId: null,
    address: null,
    email: null,
    fullName: null,
    latitude: null,
    longitude: null,
    mobile: null,
  );
  var _password = '';
  var _isLoading = false;
  var _isProcess = false;
  String? _customerUserId;
  String? _customerId;
  user.User? _userData = user.User(
    id: null,
    email: null,
    fullName: null,
    mobile: null,
    role: null,
    authId: null,
  );
  List<PermissionData> _userPermissionList = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      _customerId = args;
      _userData = Provider.of<UserProvider>(context, listen: false).currentUser;
      _userPermissionList =
          await UsersHelper().getDefaultPermission(userType: appRoleCustomer);
      if (args != null) {
        setState(() {
          _isLoading = true;
        });
        final data = await CustomersHelper().getCustomerDetails(_customerId);
        _customerData = data!;

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
      final customerInstance = FirebaseFirestore.instance
          .collection(apiCustomers)
          .doc(_customerData.id);

      final navigator = Navigator.of(context);

      if (_customerData.id != null) {
        final customerData = Customer(
          id: _customerData.id,
          userId: _customerData.userId,
          address: _customerData.address,
          email: _customerData.email,
          fullName: _customerData.fullName,
          latitude: _customerData.latitude,
          longitude: _customerData.longitude,
          mobile: _customerData.mobile,
          createdBy: _customerData.createdBy,
          createdAt: _customerData.createdAt,
          updatedBy: _userData!.id,
          updatedAt: DateTime.now().toIso8601String(),
        );

        await customerInstance.update(customerData.toJson()).then((value) {
          message = 'Customer updated';
        });
      } else {
        final authUser = await UsersHelper().createFirebaseAuthUserWithApi(
          email: _customerData.email!,
          password: _password,
          context: context,
        );
        final userInstance =
            FirebaseFirestore.instance.collection(apiUsers).doc();

        final userData = user.User(
          id: userInstance.id,
          email: _customerData.email,
          fullName: _customerData.fullName,
          role: appRoleCustomer,
          mobile: _customerData.mobile,
          authId: authUser,
        );
        await userInstance.set(userData.toJson());
        _customerUserId = userInstance.id;
        await PermissionHelper().updateUserPermissionList(
          selectedPermissionList: _userPermissionList,
          userId: userInstance.id,
        );
        final customerData = Customer(
          id: customerInstance.id,
          userId: userInstance.id,
          address: _customerData.address,
          email: _customerData.email,
          fullName: _customerData.fullName,
          latitude: _customerData.latitude,
          longitude: _customerData.longitude,
          mobile: _customerData.mobile,
          createdBy: _userData!.id,
          createdAt: DateTime.now().toIso8601String(),
        );

        await customerInstance.set(customerData.toJson()).then((value) {
          message = 'Customer added';
        });
      }
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _customerData.email!);
      displaySnackbar(context: _scaffoldKey.currentContext!, msg: message);
      // navigator.pushReplacementNamed(appRouteAddEditAddressScreen);
      if (_customerUserId != null) {
        navigator
            .pushReplacementNamed(appRouteAddEditAddressScreen, arguments: {
          'userId': _customerUserId,
        });
      } else {
        navigator.pop();
      }
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //     appRouteCustomerListScreen, ModalRoute.withName('/'));
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
      appBar: const AppBarWidget(title: appTitleCustomer),
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
                      //     appTitleCustomerDetails,
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
                          initialValue: _customerData.fullName,
                          lableText: appTitleFullName,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _customerData.fullName = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _customerData.mobile,
                          lableText: appTitleMobile,
                          icon: Icons.phone_android_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          onSaved: (value) {
                            _customerData.mobile = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _customerData.address,
                          lableText: appTitleAddress,
                          icon: Icons.bungalow_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _customerData.address = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _customerData.email,
                          lableText: appTitleEmail,
                          icon: Icons.email_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: requiredEmailValidator,
                          onSaved: (value) {
                            _customerData.email = removeSpaceFromString(value!);
                          },
                        ),
                      ),
                      if (_customerData.id == null)
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _customerData.latitude,
                          lableText: appTitleLatitude,
                          icon: Icons.my_location_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          onSaved: (value) {
                            _customerData.latitude = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _customerData.longitude,
                          lableText: appTitleLongitude,
                          icon: Icons.my_location_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          onSaved: (value) {
                            _customerData.longitude = value!;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      RoundButtonWidget(
                        width: deviceSize.width * 0.5,
                        label: _customerData.id != null
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
