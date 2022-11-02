import 'package:firebase_auth/firebase_auth.dart';
import '../../values/static_values.dart';
import '../../helpers/user_helper.dart';
import '../../models/user.dart' as user;
import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../values/api_end_points.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditUserScreen extends StatefulWidget {
  const AddEditUserScreen({Key? key}) : super(key: key);

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  bool _isInit = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _userData = user.User(
    id: null,
    email: '',
    fullName: '',
    role: null,
    password: null,
    mobile: '',
    authId: null,
  );
  var _isLoading = false;
  String? _userId;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      _userId = args;

      if (args != null) {
        setState(() {
          _isLoading = true;
        });
        final data = await UsersHelper().getUserDetails(_userId);
        _userData = data!;

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
    var messsage = appTitleSomethingWentWrong;
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    try {
      final userInstance =
          FirebaseFirestore.instance.collection(apiUsers).doc(_userData.id);

      if (_userData.id != null) {
        final userData = user.User(
          id: _userData.id ?? userInstance.id,
          email: _userData.email,
          fullName: _userData.fullName,
          role: _userData.role,
          mobile: _userData.mobile,
          authId: _userData.authId,
        );

        await userInstance.update(userData.toJson()).then((value) {
          messsage = 'User updated';
        });
      } else {
        final authUser = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _userData.email!, password: _userData.password!);
        final userData = user.User(
          id: _userData.id ?? userInstance.id,
          email: _userData.email,
          fullName: _userData.fullName,
          role: _userData.role,
          mobile: _userData.mobile,
          authId: authUser.user!.uid,
        );
        await userInstance.set(userData.toJson()).then((value) {
          messsage = 'User added';
        });
      }

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
      appBar:
          AppBarWidget(title: _userData.id != null ? 'Edit User' : 'Add User'),
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
                      //     appTitleUserDetails,
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
                          initialValue: _userData.fullName,
                          lableText: appTitleFullName,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _userData.fullName = value!;
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
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _userData.email,
                          lableText: appTitleEmail,
                          icon: Icons.email_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: requiredEmailValidator,
                          readOnly: _userData.id != null,
                          onSaved: (value) {
                            _userData.email = removeSpaceFromString(value!);
                          },
                        ),
                      ),
                      if (_userData.id == null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: TextFormFieldWidget(
                            initialValue: _userData.password,
                            lableText: appTitlePassword,
                            icon: Icons.person,
                            labelColor: Theme.of(context).primaryColor,
                            iconColor: Theme.of(context).primaryColor,
                            validator: nameValidator,
                            onSaved: (value) {
                              _userData.password = value!;
                            },
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: appRoleAdmin,
                          lableText: appTitleRole,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          readOnly: true,
                          onSaved: (value) {
                            _userData.role = value;
                          },
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 20.0,
                      //     vertical: 10.0,
                      //   ),
                      //   child: DropdownButtonFormFieldWidget(
                      //     lableText: appTitleRole,
                      //     icon: Icons.person,
                      //     labelColor: Theme.of(context).primaryColor,
                      //     iconColor: Theme.of(context).primaryColor,
                      //     value: appRoleAdmin,
                      //     items: staticUserRoleList
                      //         .map(
                      //           (data) => DropdownMenuItem(
                      //             value: data['value'],
                      //             child: Text(data['title']!),
                      //           ),
                      //         )
                      //         .toList(),
                      //     readOnly: true,
                      //     onChanged: (value) {},
                      //     onSaved: (value) {
                      //       _userData.role = value;
                      //     },
                      //   ),
                      // ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      RoundButtonWidget(
                        width: deviceSize.width * 0.5,
                        label:
                            _userData.id != null ? appTitleUpdate : appTitleAdd,
                        onPressed: _submitForm,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
