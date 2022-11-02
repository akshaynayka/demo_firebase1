import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../helpers/permission_helper.dart';
import '../../helpers/service_provider_helper.dart';
import '../../models/permission_data.dart';
import '../../models/service_provider.dart';
import '../../values/app_permissions.dart';
import '../../models/call_time_log.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../../widgets/timer_widget.dart';
import '../../common_methods/field_validator.dart';
import '../../helpers/addresses_helper.dart';
import '../../models/address.dart';
import '../../models/service.dart';
import '../../widgets/service_search_dropdown_widget.dart';
import '../../common_methods/common_methods.dart';
import '../../helpers/calls_helper.dart';
import '../../helpers/customers_helper.dart';
import '../../helpers/technician_helper.dart';
import '../../models/call.dart';
import '../../models/customer.dart';
import '../../models/technician.dart';
import '../../values/api_end_points.dart';
import '../../values/colors.dart';
import '../../values/static_values.dart';
import '../../values/string_en.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/circular_loader_widget.dart';
import '../../widgets/dropdown_form_field_widget.dart';
import '../../widgets/round_button_widget.dart';

class AddEditCallScreen extends StatefulWidget {
  const AddEditCallScreen({Key? key}) : super(key: key);

  @override
  State<AddEditCallScreen> createState() => _AddEditCallScreenState();
}

class _AddEditCallScreenState extends State<AddEditCallScreen> {
  bool _isInit = true;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _callData = Call(
    id: null,
    serviceProviderId: null,
    customerId: null,
    technicianId: null,
    addressId: null,
    etimatedDuration: null,
    status: 'request',
  );
  User _userData = User(
    id: null,
    email: null,
    fullName: null,
    mobile: null,
    role: null,
    authId: null,
  );
  var _isLoading = true;
  String? _callId;
  List<Customer> _customerList = [];
  List<ServiceProvider> _serviceProviderList = [];
  // List<Service> _serviceList = [];
  List<Service> _selectedServiceList = [];
  // List<Address> _addressList = [];

  List<Technician> _technicianList = [];
  Address? _selectedAddress;
  String? _selectedUserId;
  List<PermissionData> _userPermissionList = [];
  String? _serviceProviderId;

  // ScrollController _servicesScrollController = ScrollController();

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _userData =
          Provider.of<UserProvider>(context, listen: false).currentUser!;
      if (_userData.role == appRoleServiceProvider) {
        _serviceProviderId = Provider.of<UserProvider>(context, listen: false)
            .currentServiceProviderId;
      }
      final routeContext = ModalRoute.of(context);
      _customerList = await CustomersHelper().gellAllCustomerList();
      _serviceProviderList =
          await ServiceProviderHelper().gellAllServiceProviderList();

      _technicianList = _userData.role == appRoleServiceProvider
          ? await TechnicianHelper()
              .getMyTechnicianList(serviceProviderId: _serviceProviderId!)
          : await TechnicianHelper().getAllTechnicianList();
      _userPermissionList =
          await PermissionHelper().getAllUserPermissions(userId: _userData.id);
      final args = routeContext!.settings.arguments as String?;
      _callId = args;

      if (args != null) {
        setState(() {
          _isLoading = true;
        });

        final data = await CallsHelper().getCallDetails(_callId);
        _callData = data!;

        _selectedServiceList = _callData.serviceList!;
        _selectedAddress = await AddressesHelper()
            .getAddressDetails(addressId: _callData.addressId);
        _selectedUserId =
            _getUserIdFromCustomerList(customerId: _callData.customerId!);
        setState(() {
          _isLoading = false;
        });
      } else {
        _setTechnicianOrProvider();
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

  void _setTechnicianOrProvider() {
    if (_userData.role == appRoleTechnician) {
      final technicianId =
          Provider.of<UserProvider>(context, listen: false).currentTechnicianId;
      _callData.technicianId = technicianId;
    } else if (_userData.role == appRoleServiceProvider) {
      final serviceProviderId =
          Provider.of<UserProvider>(context, listen: false)
              .currentServiceProviderId;
      _callData.serviceProviderId = serviceProviderId;
    }
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
          FirebaseFirestore.instance.collection(apiCalls).doc(_callData.id);

      final callData = Call(
        id: _callData.id ?? call.id,
        serviceProviderId: _callData.serviceProviderId,
        customerId: _callData.customerId,
        addressId: _selectedAddress?.id,
        technicianId: _callData.technicianId,
        etimatedDuration: _callData.etimatedDuration,
        status: _callData.status,
      );
      final navigator = Navigator.of(context);
      if (_callData.id != null) {
        await call.update(callData.toJson()).then((value) {
          messsage = 'Call updated';
        });

        await CallsHelper().updateCallServiceList(
          selectedServiceList: _selectedServiceList,
          callId: _callData.id!,
        );
      } else {
        await call.set(callData.toJson()).then((value) {
          messsage = 'Call added';
        });

        await CallsHelper().addCallServiceList(
          selectedServiceList: _selectedServiceList,
          callId: _callData.id ?? call.id,
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

  String? _getUserIdFromCustomerList({required String customerId}) {
    final userId = _customerList
        .firstWhere((data) => data.id == customerId,
            orElse: () => Customer(
                id: null,
                userId: null,
                address: null,
                email: null,
                fullName: null,
                latitude: null,
                longitude: null,
                mobile: null))
        .userId;
    return userId;
  }

  ServiceProvider? _getServiceProviderData(
      {required String? serviceProviderId}) {
    final serviceProviderData = _serviceProviderList.firstWhere(
      (data) => data.id == serviceProviderId,
      orElse: () => ServiceProvider(
        id: null,
        userId: null,
        email: null,
        fullName: null,
        mobile: null,
      ),
    );
    return serviceProviderData;
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
              )
            ],
          );
        });
      },
    ).then((value) => setState(() {}));
  }

  Widget _callTimeLogListWidget() {
    return StreamBuilder<List<CallTimeLog>>(
      stream: CallsHelper().getAllCallLogStream(
        callId: _callId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(appTitleSomethingWentWrong);
        } else if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularLoaderWidget();
          }
          final callTimeLogList = snapshot.data;
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: callTimeLogList!.length,
            itemBuilder: (context, index) {
              return Card(
                child: callTimeLogList[index].clockOutTime != null
                    ? Text(
                        '${DateFormat('dd-MMM-yyyy H:m:s').format(DateTime.parse(callTimeLogList[index].clockInTime!))} to ${DateFormat('dd-MMM-yyyy H:m:s').format(DateTime.parse(callTimeLogList[index].clockOutTime!))}')
                    : TimerWidget(
                        clockInTime: callTimeLogList[index].clockInTime!),
              );
            },
          );
        } else {
          return const CircularLoaderWidget();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    double h = deviceSize.height * 0.01;
    double w = deviceSize.width * 0.02;
    final serviceProviderData =
        _getServiceProviderData(serviceProviderId: _callData.serviceProviderId);

    final permissionInstance = PermissionHelper();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarWidget(title: _callId != null ? 'Edit Call' : 'Add Call'),
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
                      //     'Add Call',
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

                      if (_userData.role != appRoleAdmin)
                        serviceProviderData?.id == null
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0,
                                ),
                                child: Text(serviceProviderData!.fullName!),
                              )
                      else
                        serviceProviderData?.id == null &&
                                _userData.role == appRoleAdmin &&
                                _callData.id != null
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 10.0,
                                ),
                                child: DropdownButtonFormFieldWidget(
                                  lableText: appTitleServiceProvider,
                                  icon: Icons.person,
                                  labelColor: Theme.of(context).primaryColor,
                                  iconColor: Theme.of(context).primaryColor,
                                  value: _callData.serviceProviderId,
                                  validator: _userData.role == appRoleTechnician
                                      ? null
                                      : nameValidator,
                                  readOnly: !permissionInstance
                                      .validateUserPermission(
                                    userData: _userData,
                                    userPermissionList: _userPermissionList,
                                    permission: appPermissionAddEditCall,
                                  ),
                                  items: _serviceProviderList
                                      .map(
                                        (data) => DropdownMenuItem(
                                          value: data.id,
                                          child: Text(data.fullName!),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {},
                                  onSaved: (value) {
                                    _callData.serviceProviderId = value;
                                  },
                                ),
                              ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: DropdownButtonFormFieldWidget(
                          lableText: appTitleCustomer,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          value: _callData.customerId,
                          validator: nameValidator,
                          readOnly: !permissionInstance.validateUserPermission(
                            userData: _userData,
                            userPermissionList: _userPermissionList,
                            permission: appPermissionAddEditCall,
                          ),
                          items: _customerList
                              .map(
                                (data) => DropdownMenuItem(
                                  value: data.id,
                                  child: Text(data.fullName!),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            _selectedUserId =
                                _getUserIdFromCustomerList(customerId: value!);
                          },
                          onSaved: (value) {
                            _callData.customerId = value;
                          },
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 10.0,
                        ),
                        child: DropdownButtonFormFieldWidget(
                          lableText: appTitleTechnician,
                          icon: Icons.person,
                          labelColor: Theme.of(context).primaryColor,
                          iconColor: Theme.of(context).primaryColor,
                          value: _callData.technicianId,
                          validator: nameValidator,
                          readOnly: !permissionInstance.validateUserPermission(
                            userData: _userData,
                            userPermissionList: _userPermissionList,
                            permission: appPermissionAddEditCall,
                          ),
                          items: _technicianList
                              .map(
                                (data) => DropdownMenuItem(
                                  value: data.id,
                                  child: Text(data.fullName!),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {},
                          onSaved: (value) {
                            _callData.technicianId = value;
                          },
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 20.0,
                      //     vertical: 10.0,
                      //   ),
                      //   child: TextFormFieldWidget(
                      //     initialValue: _callData.latitude,
                      //     lableText: appTitleLatitude,
                      //     icon: Icons.my_location_outlined,
                      //     labelColor: Theme.of(context).primaryColor,
                      //     iconColor: Theme.of(context).primaryColor,
                      //     onSaved: (value) {
                      //       _callData.latitude = value!;
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 20.0,
                      //     vertical: 10.0,
                      //   ),
                      //   child: TextFormFieldWidget(
                      //     initialValue: _callData.longitude,
                      //     lableText: appTitleLongitude,
                      //     icon: Icons.my_location_outlined,
                      //     labelColor: Theme.of(context).primaryColor,
                      //     iconColor: Theme.of(context).primaryColor,
                      //     onSaved: (value) {
                      //       _callData.longitude = value!;
                      //     },
                      //   ),
                      // ),
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
                          value: _callData.status,
                          validator: nameValidator,
                          readOnly: !permissionInstance.validateUserPermission(
                            userData: _userData,
                            userPermissionList: _userPermissionList,
                            permission: appPermissionAddEditCall,
                          ),
                          items: staticCallStatusList
                              .map(
                                (data) => DropdownMenuItem(
                                  value: data['value'],
                                  child: Text(data['title']!),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {},
                          onSaved: (value) {
                            _callData.status = value;
                          },
                        ),
                      ),

                      // Text(_selectedAddress != null
                      //     ? 'Selected address'
                      //     : 'Please select address'),
                      // if (_selectedAddress != null)
                      //   Text(_selectedAddress!.name!),
                      InkWell(
                        onTap: !permissionInstance.validateUserPermission(
                          userData: _userData,
                          userPermissionList: _userPermissionList,
                          permission: appPermissionAddEditCall,
                        )
                            ? null
                            : () async {
                                if (_selectedUserId == null) {
                                  showErrorDialog(
                                    'Please Select Customer first',
                                    context,
                                  );
                                  return;
                                }
                                await AddressesHelper()
                                    .getUserAddressList(
                                        userId: _selectedUserId!)
                                    .then((value) {
                                  _showAddressBottomSheet(context, value);
                                });
                              },
                        child: SizedBox(
                          // decoration: BoxDecoration(
                          //     border: Border.all(width: 1)),
                          height: MediaQuery.of(context).size.height * 0.06,

                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: w * 2.2),
                                child: Text(
                                  appTitleAddress,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
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
                              onTap: !permissionInstance.validateUserPermission(
                                userData: _userData,
                                userPermissionList: _userPermissionList,
                                permission: appPermissionAddEditCall,
                              )
                                  ? null
                                  : () {
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
                                                onTap: !permissionInstance
                                                        .validateUserPermission(
                                                  userData: _userData,
                                                  userPermissionList:
                                                      _userPermissionList,
                                                  permission:
                                                      appPermissionAddEditCall,
                                                )
                                                    ? null
                                                    : () {
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
                      // Text('data'),
                      if (_callData.id != null) _callTimeLogListWidget(),

                      const SizedBox(
                        height: 30.0,
                      ),
                      // if (_callData.id != null)
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //     children: [
                      //       RoundButtonWidget(
                      //         width: deviceSize.width * 0.3,
                      //         label: appTitleClockIn,
                      //         onPressed: _clockIn,
                      //       ),
                      //       RoundButtonWidget(
                      //         width: deviceSize.width * 0.3,
                      //         label: appTitleClockOut,
                      //         onPressed: _clockIn,
                      //       ),
                      //     ],
                      //   ),

                      const SizedBox(
                        height: 30.0,
                      ),
                      if (permissionInstance.validateUserPermission(
                        userData: _userData,
                        userPermissionList: _userPermissionList,
                        permission: appPermissionAddEditCall,
                      ))
                        RoundButtonWidget(
                          // width: deviceSize.width * 0.3,
                          label: _callId == null
                              ? appTitleAddCall
                              : appTitleUpdateCall,
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
