import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common_methods/common_methods.dart';
import '../../helpers/addresses_helper.dart';
import '../../helpers/customer_call_request_helper.dart';
import '../../helpers/customers_helper.dart';
import '../../helpers/service_provider_helper.dart';
import '../../helpers/technician_helper.dart';
import '../../models/address.dart';
import '../../models/customer.dart';
import '../../models/customer_call_request.dart';
import '../../models/service.dart';
import '../../models/service_provider.dart';
import '../../models/technician.dart';
import '../../providers/user_provider.dart';
import '../../values/api_end_points.dart';
import '../../values/colors.dart';
import '../../values/static_values.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/service_search_dropdown_widget.dart';
import '../../widgets/text_form_field_widget.dart';

class AddEditCustomerCallRequestScreen extends StatefulWidget {
  const AddEditCustomerCallRequestScreen({Key? key}) : super(key: key);

  @override
  State<AddEditCustomerCallRequestScreen> createState() =>
      _AddEditCustomerCallRequestScreenState();
}

class _AddEditCustomerCallRequestScreenState
    extends State<AddEditCustomerCallRequestScreen> {
  var _isLoading = true;
  bool _isInit = true;
  String? _technicianId;
  String? _serviceProviderId;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Service> _selectedServiceList = [];
  Technician? _technicianData;
  ServiceProvider? _serviceProviderData;
  Customer? _customerData;
  Address? _selectedAddress;
  final CustomerCallRequest _customerCallRequestData = CustomerCallRequest(
    id: null,
    technicianId: null,
    serviceProviderId: null,
    customerId: null,
    addressId: null,
    status: 'requested',
  );
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      final routeContext = ModalRoute.of(context);
      final customerProvider = Provider.of<UserProvider>(context);
      final args = routeContext!.settings.arguments as Map<String, String?>;

      if (args['userRole'] == appRoleTechnician) {
        _technicianId = args['id'];
        _technicianData = await TechnicianHelper()
            .getTechnicianDetails(technicianId: _technicianId);
      } else {
        _serviceProviderId = args['id'];
        _serviceProviderData = await ServiceProviderHelper()
            .getServiceProviderDetails(_serviceProviderId);
      }

      if (args.isNotEmpty) {
        setState(() {
          _isLoading = true;
        });
        _customerCallRequestData.serviceProviderId = _serviceProviderData?.id;
        _customerCallRequestData.technicianId = _technicianData?.id;
        final customerId = customerProvider.currentCustomer;
        _customerData = await CustomersHelper().getCustomerDetails(customerId);
        _customerCallRequestData.customerId = _customerData?.id;

        setState(() {
          _isLoading = false;
        });
      } else {
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

  Widget _addressTile(
      {required Address addressData,
      bool selected = false,
      Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        // height: 150,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xff008ecc),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(addressData.id!),
            Text(
              addressData.name!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: buttonTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              addressData.pincode!,
              style: const TextStyle(
                color: buttonTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${addressData.address1} ${addressData.address2} ${addressData.city} ${addressData.state} ${addressData.country}',
              style: const TextStyle(
                color: buttonTextColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
                // wordSpacing: 5,
              ),
            ),
            const SizedBox(height: 5),
            if (selected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue[400],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'Selected',
                  style: TextStyle(
                    color: buttonTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext ctx, List<Address> addressList) {
    showModalBottomSheet(
      // isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              const Text('Select Address'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var data in addressList)
                      _addressTile(
                          selected: _selectedAddress?.id == data.id,
                          addressData: data,
                          onTap: () {
                            setState(() {
                              _selectedAddress = data;
                            });
                            Navigator.of(context).pop();
                          }),
                  ],
                ),
              ),
              // const Expanded(child: SizedBox()),
              // ElevatedButton(
              //   child: const Text(appTitleDone),
              //   onPressed: () async {
              //     // Provider.of<Services>(context, listen: false)
              //     //     .resetsearchServices();

              //     Navigator.of(context).pop();
              //   },
              // ),
              // const SizedBox(
              //   height: 30.0,
              // ),
            ],
          );
        });
      },
    ).then((value) => setState(() {}));
  }

  void _submitForm() async {
    var messsage = appTitleSomethingWentWrong;
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedServiceList.isEmpty) {
      showErrorDialog('Select Service', context);
      return;
    }

    if (_selectedAddress == null) {
      showErrorDialog('Select Address', context);
      return;
    }
    _formKey.currentState!.save();

    try {
      final call =
          FirebaseFirestore.instance.collection(apiCustomerCallRequests).doc();

      final callRequestData = CustomerCallRequest(
        id: call.id,
        technicianId: _customerCallRequestData.technicianId,
        serviceProviderId: _customerCallRequestData.serviceProviderId,
        serviceList: _customerCallRequestData.serviceList,
        customerId: _customerCallRequestData.customerId,
        addressId: _selectedAddress?.id,
        status: _customerCallRequestData.status,
      );

      final navigator = Navigator.of(context);
      if (_customerCallRequestData.id != null) {
        await call.update(callRequestData.toJson()).then((value) {
          messsage = 'Call updated';
        });

        // await CallRequestsHelper().updateCallServiceList(
        //   selectedServiceList: _selectedServiceList,
        //   callId: callData.id!,
        // );

        // await CallRequestsHelper().addCallRequestTechnicianList(
        //   selectedTechnicianList: _selectedTechnicianList,
        //   callRequestId: callData.id!,
        // );
      } else {
        await call.set(callRequestData.toJson()).then((value) {
          messsage = 'Call added';
        });

        await CustomerCallRequestHelper().addCustomerCallRequestServiceList(
          selectedServiceList: _selectedServiceList,
          customerCallRequestId: call.id,
        );
      }

      displaySnackbar(context: _scaffoldKey.currentContext!, msg: messsage);
      navigator.pop();
    } catch (error) {
      debugPrint('error---> $error');
      const errorMessage = appTitleSomethingWentWrong;
      showErrorDialog(errorMessage, context);
    }

    // setState(() {
    //   _isLoading = true;
    // });
  }

  void _showServiceBottomSheet(BuildContext ctx, serviceList) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: ServiceSearchDropdownWidget(
            callback: (val) => setState(() {
              _selectedServiceList = val;
            }),
            serviceList: serviceList,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    double h = deviceSize.height * 0.01;
    double w = deviceSize.width * 0.02;
    return Scaffold(
      key: _scaffoldKey,
      appBar: const AppBarWidget(title: 'Call Request'),
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
                      //     'Call Request',
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
                          initialValue: _customerData?.fullName,
                          lableText: appTitleCustomer,
                          icon: Icons.my_location_outlined,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          readOnly: true,
                        ),
                      ),
                      if (_technicianData != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: TextFormFieldWidget(
                            initialValue: _technicianData?.fullName,
                            lableText: appTitleTechnician,
                            icon: Icons.my_location_outlined,
                            labelColor: Theme.of(context).primaryColor,
                            iconColor: Theme.of(context).primaryColor,
                            readOnly: true,
                          ),
                        ),
                      if (_serviceProviderData != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: TextFormFieldWidget(
                            initialValue: _serviceProviderData?.fullName,
                            lableText: appTitleServiceProvider,
                            icon: Icons.my_location_outlined,
                            labelColor: Theme.of(context).primaryColor,
                            iconColor: Theme.of(context).primaryColor,
                            readOnly: true,
                          ),
                        ),

                      // Text(_selectedAddress != null
                      //     ? 'Selected address'
                      //     : 'Please select address'),
                      // if (_selectedAddress != null)
                      //   Text(_selectedAddress!.name!),
                      InkWell(
                        onTap: () async {
                          if (_customerData?.userId == null) {
                            showErrorDialog(
                              'Please Select Customer first',
                              context,
                            );
                            return;
                          }
                          await AddressesHelper()
                              .getUserAddressList(
                                  userId: _customerData!.userId!)
                              .then((value) {
                            _showAddressBottomSheet(context, value);
                          });
                        },
                        child: SizedBox(
                          // decoration: BoxDecoration(
                          //     border: Border.all(width: 1)),
                          height: MediaQuery.of(context).size.height * 0.06,

                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  appTitleAddress,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    // padding:
                                    //     EdgeInsets.only(right: w * 2.5),
                                    child: Icon(Icons.search_rounded,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: _selectedAddress != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedAddress!.name!,
                                      style:const  TextStyle(
                                        // fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(_selectedAddress!.address1 ?? ''),
                                    Text(_selectedAddress!.address2 ?? ''),
                                    Text(_selectedAddress!.city ?? ''),
                                    Text(
                                        '${_selectedAddress!.state ?? ''} - ${_selectedAddress!.pincode ?? ''}'),
                                    Text(_selectedAddress!.country ?? ''),
                                  ],
                                )
                              : const Text('Please select address'),
                        ),
                      ),
                      Card(
                        // elevation: 0,
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                _showServiceBottomSheet(
                                    context, _selectedServiceList);
                              },
                              child: SizedBox(
                                // decoration: BoxDecoration(
                                //     border: Border.all(width: 1)),
                                height:
                                    MediaQuery.of(context).size.height * 0.06,

                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: w * 2.2),
                                      child: Text(
                                        appTitleService,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        // padding:
                                        //     EdgeInsets.only(right: w * 2.5),
                                        child: Icon(Icons.search_rounded,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(
                              height: 0,
                            ),
                            if (_selectedServiceList.isNotEmpty)
                              Container(
                                margin: EdgeInsets.all(w * 0.8),
                                height: MediaQuery.of(context).size.height *
                                    (_selectedServiceList.length <= 1
                                        ? 0.0755
                                        : _selectedServiceList.length <= 2
                                            ? 0.16
                                            : 0.236),
                                child: Scrollbar(
                                  interactive: true,
                                  // controller: _servicesScrollController,
                                  scrollbarOrientation:
                                      ScrollbarOrientation.left,
                                  // radius: Radius.circular(h),
                                  child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    // controller: _servicesScrollController,
                                    itemCount: _selectedServiceList.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.all(h * 0.6),
                                        padding: EdgeInsets.all(h * 1.2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(40),
                                          ),
                                        ),
                                        height: h * 6.5,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedServiceList[index]
                                                    .name!,
                                                style: const TextStyle(
                                                    color: buttonTextColor),
                                              ),
                                            ),
                                            FittedBox(
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedServiceList
                                                        .removeAt(index);
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.remove_circle_rounded,
                                                  color: Colors.white,
                                                  size: h * h,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50.0,
                      ),
                      RoundButtonWidget(
                        // width: deviceSize.width * 0.3,
                        label: appTitleSendRequest,
                        onPressed: _submitForm,
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
