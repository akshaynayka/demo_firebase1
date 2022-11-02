import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/dropdown_form_field_widget.dart';
import '../../helpers/permission_helper.dart';
import '../../models/permission_data.dart';
import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../values/api_end_points.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';

class AddEditPermissionScreen extends StatefulWidget {
  const AddEditPermissionScreen({Key? key}) : super(key: key);

  @override
  State<AddEditPermissionScreen> createState() =>
      _AddEditPermissionScreenState();
}

class _AddEditPermissionScreenState extends State<AddEditPermissionScreen> {
  bool _isInit = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _permissionData = PermissionData(id: null, parentId: null, name: null,label: null);
  var _isLoading = false;
  String? _permissionId;
  List<PermissionData> allPermissionList = [];
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      _permissionId = args;
      allPermissionList = await PermissionHelper().getAllPermissionList();
      if (args != null) {
        setState(() {
          _isLoading = true;
        });

        final data =
            await PermissionHelper().getPermissionDetails(_permissionId);
        _permissionData = data!;

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
      final permissionDetails = FirebaseFirestore.instance
          .collection(apiPermissions)
          .doc(_permissionData.id);

      final permissionData = PermissionData(
        id: _permissionData.id ?? permissionDetails.id,
        parentId: _permissionData.parentId,
        name: _permissionData.name,
        label: _permissionData.label,
      );
      if (_permissionData.id != null) {
        await permissionDetails.update(permissionData.toJson()).then((value) {
          messsage = 'Permission updated';
        });
      } else {
        await permissionDetails.set(permissionData.toJson()).then((value) {
          messsage = 'Permission added';
        });
      }

      displaySnackbar(context: _scaffoldKey.currentContext!, msg: messsage);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
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
      appBar: AppBarWidget(
          title: _permissionData.id != null
              ? 'Edit Permission'
              : 'Add Permission'),
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
                      //       // bottomRight: Radius.circular(50),
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
                      //     'Permission',
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
                        child: DropdownButtonFormFieldWidget(
                          lableText: appTitleParentPermission,
                          icon: Icons.report_problem_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          value: _permissionData.parentId,
                          items: allPermissionList
                              .where((element) => element.parentId == null)
                              .toList()
                              .map(
                                (data) => DropdownMenuItem(
                                  value: data.id,
                                  child: Text(data.name!),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            // print('value----------->$value');
                          },
                          onSaved: (value) {
                            _permissionData.parentId = value;
                          },
                          onTap: () {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _permissionData.name,
                          lableText: appTitleName,
                          icon: Icons.construction_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _permissionData.name = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _permissionData.label,
                          lableText: appTitleLabel,
                          icon: Icons.construction_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _permissionData.label = value!;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      RoundButtonWidget(
                        width: deviceSize.width * 0.5,
                        label: _permissionData.id != null ? 'Update' : 'Add',
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
