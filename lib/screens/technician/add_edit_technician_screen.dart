import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../values/static_values.dart';
import '../../helpers/user_helper.dart';
import '../../models/user.dart' as user;
import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../helpers/technician_helper.dart';
import '../../models/technician.dart';
import '../../values/api_end_points.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditTechnicianScreen extends StatefulWidget {
  const AddEditTechnicianScreen({Key? key}) : super(key: key);

  @override
  State<AddEditTechnicianScreen> createState() =>
      _AddEditTechnicianScreenState();
}

class _AddEditTechnicianScreenState extends State<AddEditTechnicianScreen> {
  bool _isInit = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _technicianData = Technician(
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
  String? _technicianId;
  List<PermissionData> _userPermissionList = [];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      _technicianId = args;
      _userPermissionList =
          await UsersHelper().getDefaultPermission(userType: appRoleTechnician);
      if (args != null) {
        setState(() {
          _isLoading = true;
        });
        final data = await TechnicianHelper()
            .getTechnicianDetails(technicianId: _technicianId);
        _technicianData = data!;

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
      final technicianInstance = FirebaseFirestore.instance
          .collection(apiTechnicians)
          .doc(_technicianData.id);

      Technician technicianData = Technician(
        id: _technicianData.id ?? technicianInstance.id,
        userId: _technicianData.userId,
        address: _technicianData.address,
        email: _technicianData.email,
        fullName: _technicianData.fullName,
        latitude: _technicianData.latitude,
        longitude: _technicianData.longitude,
        mobile: _technicianData.mobile,
      );
      if (_technicianData.id != null) {
        await technicianInstance.update(technicianData.toJson()).then((value) {
          messsage = 'Technician updated';
        });
      } else {
        final authUser = await UsersHelper().createFirebaseAuthUserWithApi(
          email: _technicianData.email!,
          password: _password,
          context: context,
        );
        final userInstance =
            FirebaseFirestore.instance.collection(apiUsers).doc();
        final userData = user.User(
          id: userInstance.id,
          email: _technicianData.email,
          fullName: _technicianData.fullName,
          role: appRoleTechnician,
          mobile: _technicianData.mobile,
          authId: authUser,
        );
        await userInstance.set(userData.toJson());

        await PermissionHelper().updateUserPermissionList(
          selectedPermissionList: _userPermissionList,
          userId: userInstance.id,
        );

        technicianData.userId = userData.id;
        await technicianInstance
            .set(technicianData.toJson())
            .then((value) async {
          await FirebaseAuth.instance
              .sendPasswordResetEmail(email: _technicianData.email!);
          messsage = 'Technician added';
        });
      }

      displaySnackbar(context: _scaffoldKey.currentContext!, msg: messsage);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      debugPrint('error ---->$error');
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
      appBar: const AppBarWidget(title: 'Technician'),
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
                      //     appTitleTechnicianDetails,
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
                          initialValue: _technicianData.fullName,
                          lableText: appTitleFullName,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _technicianData.fullName = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _technicianData.mobile,
                          lableText: appTitleMobile,
                          icon: Icons.phone_android_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.phone,
                          onSaved: (value) {
                            _technicianData.mobile = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _technicianData.address,
                          lableText: appTitleAddress,
                          icon: Icons.bungalow_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _technicianData.address = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _technicianData.email,
                          lableText: appTitleEmail,
                          icon: Icons.email_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          keyboardType: TextInputType.emailAddress,
                          validator: requiredEmailValidator,
                          onSaved: (value) {
                            _technicianData.email =
                                removeSpaceFromString(value!);
                          },
                        ),
                      ),
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
                          initialValue: _technicianData.latitude,
                          lableText: appTitleLatitude,
                          icon: Icons.my_location_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          onSaved: (value) {
                            _technicianData.latitude = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _technicianData.longitude,
                          lableText: appTitleLongitude,
                          icon: Icons.my_location_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          onSaved: (value) {
                            _technicianData.longitude = value!;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      RoundButtonWidget(
                        width: deviceSize.width * 0.5,
                        label: _technicianData.id != null
                            ? appTitleUpdate
                            : appTitleAdd,
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
