import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../widgets/location/pick_location_widget.dart';
import '../../helpers/location_helper.dart';
import '../../helpers/addresses_helper.dart';
import '../../models/address.dart';
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

class AddEditAddressScreen extends StatefulWidget {
  const AddEditAddressScreen({Key? key}) : super(key: key);

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  bool _isInit = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _cityTextEditingController =
      TextEditingController();
  final TextEditingController _stateTextEditingController =
      TextEditingController();
  final TextEditingController _countryTextEditingController =
      TextEditingController();
  final TextEditingController _pincodeTextEditingController =
      TextEditingController();
  var _addressData = Address(
    id: null,
    address1: '',
    address2: '',
    city: '',
    country: '',
    createdAt: null,
    createdBy: null,
    deletedAt: null,
    deletedBy: null,
    latitude: '',
    longitude: '',
    model: null,
    modelId: null,
    name: '',
    pincode: null,
    state: null,
    updatedAt: null,
    updatedBy: null,
    userId: null,
  );
  var _isLoading = false;
  String? _addressId;
  String? _userId;
  String? _imagePreviewUrl;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _addressId = args['addressId'];
      _userId = args['userId'];

      if (!kIsWeb) {
        await requestLocationPermission();
      }
      final Position? currentLocation =
          await LocationHelper().getCurrentLocation();

      if (currentLocation != null) {
        _addressData.latitude = currentLocation.latitude.toString();
        _addressData.longitude = currentLocation.longitude.toString();
      }

      if (args['addressId'] != null) {
        final data =
            await AddressesHelper().getAddressDetails(addressId: _addressId);

        _addressData = data!;

        _cityTextEditingController.text = _addressData.city!;
        _stateTextEditingController.text = _addressData.state!;
        _countryTextEditingController.text = _addressData.country!;
        _pincodeTextEditingController.text = _addressData.pincode!;
      } else {
        if (currentLocation != null) {
          final currentAddressData = await LocationHelper().getCurrentAddress(
              lat: currentLocation.latitude, long: currentLocation.longitude);

          _setDataFromResponse(responseData: currentAddressData);
          // print(currentAddressData);
          // currentAddressData['address_components'].forEach((value) {
          //   print(value['types']);
          //   if (value['types'].contains('administrative_area_level_2')) {
          //     print('this---->$value');
          //     _addressData.city = value['long_name'];
          //   }
          //   if (value['types'].contains('administrative_area_level_1')) {
          //     print('this---->$value');
          //     _addressData.state = value['long_name'];
          //   }
          //   if (value['types'].contains('country')) {
          //     print('this---->$value');
          //     _addressData.country = value['long_name'];
          //   }
          //   if (value['types'].contains('postal_code')) {
          //     print('this---->$value');
          //     _addressData.pincode = value['long_name'];
          //   }
          // });

          // List temp = [];
          // temp.contains(element)

        }
      }

      await _getLocationOnMap(
          latitude: double.parse(_addressData.latitude!),
          longitude: double.parse(_addressData.longitude!));
      setState(() {
        _isLoading = false;
      });
    }
    setState(() {
      _isInit = false;
    });
    super.didChangeDependencies();
  }

  _setDataFromResponse({required Map<String, dynamic> responseData}) {
    responseData['address_components'].forEach((value) {
      if (value['types'].contains('administrative_area_level_2')) {
        _addressData.city = value['long_name'];
        _cityTextEditingController.text = _addressData.city!;
      }
      if (value['types'].contains('administrative_area_level_1')) {
        _addressData.state = value['long_name'];
        _stateTextEditingController.text = _addressData.state!;
      }
      if (value['types'].contains('country')) {
        _addressData.country = value['long_name'];
        _countryTextEditingController.text = _addressData.country!;
      }
      if (value['types'].contains('postal_code')) {
        _addressData.pincode = value['long_name'];
        _pincodeTextEditingController.text = _addressData.pincode!;
      }
    });
  }

  Future<void> _getLocationOnMap({
    required double latitude,
    required double longitude,
  }) async {
    final staticMapImageUrl = LocationHelper.generateImagePreviewImage(
      latitude: latitude,
      longitude: longitude,
    );

    setState(() {
      _imagePreviewUrl = staticMapImageUrl;
    });
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
      final address = FirebaseFirestore.instance
          .collection(apiAddresses)
          .doc(_addressData.id);

      final addressData = Address(
        id: _addressData.id ?? address.id,
        userId: _userId,
        address1: _addressData.address1,
        address2: _addressData.address2,
        city: _addressData.city,
        country: _addressData.country,
        name: _addressData.name,
        state: _addressData.state,
        pincode: _addressData.pincode,
        latitude: _addressData.latitude,
        longitude: _addressData.longitude,
        model: _addressData.model,
        modelId: _addressData.modelId,
        createdAt: _addressData.createdAt,
        createdBy: _addressData.createdBy,
        deletedAt: _addressData.deletedAt,
        deletedBy: _addressData.deletedBy,
        updatedAt: _addressData.updatedAt,
        updatedBy: _addressData.updatedBy,
      );
      if (_addressData.id != null) {
        await address.update(addressData.toJson()).then((value) {
          messsage = 'Address updated';
        });
      } else {
        await address.set(addressData.toJson()).then((value) {
          messsage = 'Address added';
        });
      }

      displaySnackbar(context: _scaffoldKey.currentContext!, msg: messsage);
      if (!mounted) return;
      Navigator.of(context).pop();
      // Navigator.of(context).pushNamedAndRemoveUntil(
      //     appRouteCustomerListScreen, ModalRoute.withName('/'));
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
      appBar: const AppBarWidget(title: 'Customer Address'),
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
                      //     appTitleAddressDetails,
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

                      SizedBox(
                          height: 170.0,
                          child: _imagePreviewUrl == null
                              ? const Center(
                                  child: Text(
                                    'No location chosen',
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    final selectedLocation =
                                        await Navigator.of(context)
                                            .push<LatLng?>(
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (ctx) => PickLocationWidget(
                                          isSelecting: true,
                                          latitude: double.parse(
                                              _addressData.latitude!),
                                          longitude: double.parse(
                                              _addressData.longitude!),
                                        ),
                                      ),
                                    );

                                    if (selectedLocation != null) {
                                      _addressData.latitude =
                                          selectedLocation.latitude.toString();

                                      _addressData.longitude =
                                          selectedLocation.longitude.toString();
                                      final currentAddressData =
                                          await LocationHelper()
                                              .getCurrentAddress(
                                                  lat:
                                                      selectedLocation.latitude,
                                                  long: selectedLocation
                                                      .longitude);

                                      _setDataFromResponse(
                                          responseData: currentAddressData);
                                      _imagePreviewUrl = LocationHelper
                                          .generateImagePreviewImage(
                                        latitude: selectedLocation.latitude,
                                        longitude: selectedLocation.longitude,
                                      );

                                      setState(() {});
                                    }
                                  },
                                  child: Image.network(
                                    _imagePreviewUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                  ),
                                )),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _addressData.name,
                          lableText: appTitleFullName,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _addressData.name = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _addressData.address1,
                          lableText: appTitleAddress1,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _addressData.address1 = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          initialValue: _addressData.address2,
                          lableText: appTitleAddress2,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          // validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _addressData.address2 = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          controller: _cityTextEditingController,
                          lableText: appTitleCity,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _addressData.city = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          // initialValue: _addressData.state,
                          controller: _stateTextEditingController,
                          lableText: appTitleState,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _addressData.state = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          // initialValue: _addressData.country,
                          controller: _countryTextEditingController,
                          lableText: appTitleCountry,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _addressData.country = value!;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: TextFormFieldWidget(
                          // initialValue: _addressData.pincode,
                          controller: _pincodeTextEditingController,
                          lableText: appTitlePincode,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          validator: nameValidator,
                          textInputAction: TextInputAction.next,
                          onSaved: (value) {
                            _addressData.pincode = value!;
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 30.0,
                      ),
                      RoundButtonWidget(
                        width: deviceSize.width * 0.5,
                        label: _addressData.id != null
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
