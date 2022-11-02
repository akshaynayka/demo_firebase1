import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../values/static_values.dart';
import '../../widgets/dropdown_form_field_widget.dart';
import '../../common_methods/common_methods.dart';
import '../../common_methods/field_validator.dart';
import '../../helpers/service_helper.dart';
import '../../models/service.dart';
import '../../values/api_end_points.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';

class AddEditServiceScreen extends StatefulWidget {
  const AddEditServiceScreen({Key? key}) : super(key: key);

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  bool _isInit = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _serviceData = Service(
    id: null,
    name: null,
    description: null,
    etimatedDuration: null,
    status: null,
    createdAt: null,
    createdBy: null,
    deletedAt: null,
    deletedBy: null,
    updatedAt: null,
    updatedBy: null,
  );
  var _isLoading = false;
  String? _serviceId;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final args = ModalRoute.of(context)!.settings.arguments as String?;
      _serviceId = args;
      if (args != null) {
        setState(() {
          _isLoading = true;
        });
        final data = await ServiceHelper().getServiceDetails(_serviceId);
        _serviceData = data!;

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
      final serviceDetails = FirebaseFirestore.instance
          .collection(apiServices)
          .doc(_serviceData.id);

      final serviceData = Service(
        id: _serviceData.id ?? serviceDetails.id,
        name: _serviceData.name,
        description: _serviceData.description,
        etimatedDuration: _serviceData.etimatedDuration,
        status: _serviceData.status,
        createdAt: _serviceData.createdAt,
        createdBy: _serviceData.createdBy,
        deletedAt: _serviceData.deletedAt,
        deletedBy: _serviceData.deletedBy,
        updatedAt: _serviceData.updatedAt,
        updatedBy: _serviceData.updatedBy,
      );
      if (_serviceData.id != null) {
        await serviceDetails.update(serviceData.toJson()).then((value) {
          messsage = 'Service updated';
        });
      } else {
        await serviceDetails.set(serviceData.toJson()).then((value) {
          messsage = 'Service added';
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
          title: _serviceData.id != null ? 'Edit Service' : 'Add Service'),
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
                      //     'Service',
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
                          initialValue: _serviceData.name,
                          lableText: appTitleName,
                          icon: Icons.construction_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _serviceData.name = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _serviceData.description,
                          lableText: appTitleDescription,
                          icon: Icons.description_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _serviceData.description = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _serviceData.etimatedDuration,
                          lableText: appTitleEtimatedDuration,
                          icon: Icons.timer_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _serviceData.etimatedDuration = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: DropdownButtonFormFieldWidget(
                          lableText: appTitleStatus,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          value: _serviceData.status,
                          items: staticStatusList
                              .map(
                                (data) => DropdownMenuItem(
                                  value: data['value'],
                                  child: Text(data['title']!),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {},
                          onSaved: (value) {
                            _serviceData.status = value;
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      RoundButtonWidget(
                        width: deviceSize.width * 0.5,
                        label: _serviceData.id != null ? 'Update' : 'Add',
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
