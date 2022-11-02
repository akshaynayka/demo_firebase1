import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/service_provider_helper.dart';
import '../helpers/technician_helper.dart';
import '../models/service_provider_technician_request.dart';
import '../models/user.dart';
import '../values/api_end_points.dart';
import '../values/static_values.dart';
import '../widgets/circular_loader_widget.dart';

class ServiceProviderTechnicianListTileWidget extends StatefulWidget {
  const ServiceProviderTechnicianListTileWidget(
      {required this.requestData,
      required this.userData,
      this.onTap,
      this.onLongPress,
      Key? key})
      : super(key: key);

  final ServiceProviderTechnicianRequest requestData;
  final User userData;
  final void Function()? onTap;
  final void Function()? onLongPress;
  @override
  State<ServiceProviderTechnicianListTileWidget> createState() =>
      _ServiceProviderTechnicianListTileWidgetState();
}

class _ServiceProviderTechnicianListTileWidgetState
    extends State<ServiceProviderTechnicianListTileWidget> {
  var _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      // _selectedAddress = await AddressesHelper()
      //     .getAddressDetails(addressId: widget.callData.addressId);

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }

    setState(() {
      _isInit = false;
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularLoaderWidget()
        : FutureBuilder<dynamic>(
            future: widget.userData.role != appRoleTechnician
                ? TechnicianHelper().getTechnicianDetails(
                    technicianId: widget.requestData.technicianId)
                : ServiceProviderHelper().getServiceProviderDetails(
                    widget.requestData.serviceProviderId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularLoaderWidget();
              } else {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      snapshot.data!.fullName!.substring(0, 1).toUpperCase(),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(snapshot.data!.fullName!),
                      if (widget.requestData.status != 'accepted')
                        widget.requestData.requestedBy != widget.userData.role
                            ? const Icon(Icons.arrow_back)
                            : const Icon(Icons.arrow_forward),
                    ],
                  ),
                  subtitle: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(snapshot.data!.fullName!),
                      // Text(callDetails.serviceId!),
                      // Text('Navsari'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.requestData.status == 'requested' &&
                          widget.requestData.requestedBy !=
                              widget.userData.role)
                        IconButton(
                          icon: const FaIcon(
                            FontAwesomeIcons.check,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            widget.requestData.status = 'accepted';

                            await TechnicianHelper()
                                .addServiceProviderTechnicianData(
                                    requestData: widget.requestData);
                          },
                        ),
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.xmark,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection(apiServiceprovidertechnician)
                              .doc(widget.requestData.id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                );
              }
            });
  }
}
