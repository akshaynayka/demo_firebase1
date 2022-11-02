import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../values/static_values.dart';
import '../common_methods/common_methods.dart';
import '../helpers/addresses_helper.dart';
import '../helpers/location_helper.dart';
import '../models/address.dart';
import '../models/call_time_log.dart';
import '../values/api_end_points.dart';
import '../helpers/calls_helper.dart';
import '../models/call.dart';
import '../widgets/circular_loader_widget.dart';

class CallListTileWidget extends StatefulWidget {
  const CallListTileWidget({
    required this.callData,
    this.onTap,
    this.onLongPress,
    required this.ctx,
    Key? key,
  }) : super(key: key);
  final void Function()? onTap;
  final Call callData;
  final void Function()? onLongPress;
  final BuildContext ctx;

  @override
  State<CallListTileWidget> createState() => _CallListTileWidgetState();
}

class _CallListTileWidgetState extends State<CallListTileWidget> {
  var _isLoading = true;
  bool _isInit = true;
  Address? _selectedAddress;
  User? _userData;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _userData = Provider.of<UserProvider>(context, listen: false).currentUser;
      _selectedAddress = await AddressesHelper()
          .getAddressDetails(addressId: widget.callData.addressId);
      if (!kIsWeb) {
        await requestLocationPermission();
      }

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

  Future<void> _clockIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentLocation = await LocationHelper().getCurrentLocation();

      final configurationSnapshot =
          await FirebaseFirestore.instance.collection(apiConfigurations).get();

      final radiusDataInstance = configurationSnapshot.docs.first;
      final radiusData = radiusDataInstance.data()['radius'];
      final radiusValue = double.parse(radiusData);
      final distanceValue = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation.longitude,
        double.parse(_selectedAddress!.latitude!),
        double.parse(_selectedAddress!.longitude!),
      );
      debugPrint('distance--->$distanceValue');
      final distanceToClient = (distanceValue).toStringAsFixed(2);
      if (distanceValue < radiusValue) {
        debugPrint('You are in');
        final callTimeLog = CallTimeLog(
          id: null,
          callId: widget.callData.id,
          clockInTime: DateTime.now().toIso8601String(),
          clockOutTime: null,
          clockInLatitude: currentLocation.latitude.toString(),
          clockInLongitude: currentLocation.longitude.toString(),
          clockOutLatitude: null,
          clockOutLongitude: null,
        );
        await CallsHelper().addUpdateCallLog(callTimeLog: callTimeLog);
        if (!mounted) return;
        displaySnackbar(
            context: widget.ctx, msg: 'You are in $distanceToClient');
        await FirebaseFirestore.instance
            .collection(apiCalls)
            .doc(widget.callData.id)
            .update({'status': 'running'});
        setState(() {
          _isLoading = false;
        });
      } else {
        debugPrint('You are out');
        setState(() {
          _isLoading = false;
        });
        // displaySnackbar(context, 'You are not in range');
        if (!mounted) return;
        showErrorDialog(
            'You are $distanceToClient meters away from client', context);
      }
    } catch (error) {
      debugPrint('error->$error');
      rethrow;
    }

    // setState(() {
    //   _isLoading = false;
    // });
  }

  Future<void> _clockOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentLocation = await LocationHelper().getCurrentLocation();

      final distanceValue = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation.longitude,
        double.parse(_selectedAddress!.latitude!),
        double.parse(_selectedAddress!.longitude!),
      );
      // debugPrint('distance--->$distanceValue');
      final distanceToClient = (distanceValue).toStringAsFixed(2);
      final configurationSnapshot =
          await FirebaseFirestore.instance.collection(apiConfigurations).get();
      final radiusDataInstance = configurationSnapshot.docs.first;
      final radiusData = radiusDataInstance.data()['radius'];
      final radiusValue = double.parse(radiusData);

      if (distanceValue < radiusValue) {
        debugPrint('You are in');

        final callTimeLogInstance = await FirebaseFirestore.instance
            .collection(apiCallTimeLogs)
            .where('callId', isEqualTo: widget.callData.id)
            .where('clockOutTime', isNull: true)
            .get();
        final timeLogValues = callTimeLogInstance.docs;
        if (timeLogValues.isNotEmpty) {
          var callTimeLog = CallTimeLog.fromJson(timeLogValues[0].data());
          callTimeLog.clockOutTime = DateTime.now().toIso8601String();
          callTimeLog.clockOutLatitude = currentLocation.latitude.toString();
          callTimeLog.clockOutLongitude = currentLocation.longitude.toString();
          await CallsHelper().addUpdateCallLog(callTimeLog: callTimeLog);
          if (!mounted) return;
          displaySnackbar(
              context: widget.ctx, msg: 'You are in $distanceToClient');
          await FirebaseFirestore.instance
              .collection(apiCalls)
              .doc(widget.callData.id)
              .update({'status': 'close'});
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        debugPrint('You are out');
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;

        displaySnackbar(context: context, msg: 'You are not in range');
        if (!mounted) return;
        showErrorDialog(
            'You are $distanceToClient meters away from client', context);
      }
    } catch (error) {
      debugPrint('error->$error');
      rethrow;
    }

    // setState(() {
    //   _isLoading = false;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const CircularLoaderWidget()
        : FutureBuilder<Map<String, dynamic>>(
            future: CallsHelper().getCallCombineData(widget.callData),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularLoaderWidget();
              } else {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      snapshot.data!['customer'].fullName
                          .substring(0, 1)
                          .toUpperCase(),
                    ),
                  ),
                  title: Text(snapshot.data!['customer'].fullName),
                  subtitle: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.callData.status!),
                      // Text(callDetails.serviceId!),
                      // Text('Navsari'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_userData!.role == appRoleTechnician)
                        if (!['request', 'close']
                            .contains(widget.callData.status))
                          IconButton(
                            icon: FaIcon(
                              Icons.timer_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              if (widget.callData.status == 'open') {
                                _clockIn();
                              } else if (widget.callData.status == 'running') {
                                debugPrint('clock Out--->');
                                _clockOut();
                              }
                            },
                          ),
                      IconButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          String url =
                              "whatsapp://send?phone=9725106424&text=hello";
                          await canLaunchUrl(Uri.parse(url))
                              ? launchUrl(Uri.parse(url))
                              : debugPrint('Can\'t open whatsapp');
                        },
                      ),
                      IconButton(
                        icon: const FaIcon(
                          Icons.phone_outlined,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          String url = "tel://9725106999";
                          await canLaunchUrl(Uri.parse(url))
                              ? launchUrl(Uri.parse(url))
                              : debugPrint('Can\'t open Phone');
                        },
                      ),
                      IconButton(
                        icon: const FaIcon(
                          Icons.pin_drop_outlined,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          const String lat = "20.94659479038634";
                          const String long = "72.93720838248731";

                          const String googleMapslocationUrl =
                              "https://www.google.com/maps/search/?api=1&query=$lat,$long";

                          final String url =
                              Uri.encodeFull(googleMapslocationUrl);

                          await canLaunchUrl(Uri.parse(url))
                              ? launchUrl(Uri.parse(url))
                              : debugPrint('Can\'t open Maps');
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
