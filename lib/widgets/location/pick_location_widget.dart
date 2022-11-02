import '../../helpers/location_helper.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/location/search_location_widget.dart';
import '../../widgets/round_button_widget.dart';
import '../../widgets/text_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickLocationWidget extends StatefulWidget {
  const PickLocationWidget({
    this.latitude = 37.422,
    this.longitude = -122.084,
    required this.isSelecting,
    Key? key,
  }) : super(key: key);

  final double latitude;
  final double longitude;
  final bool isSelecting;

  @override
  State<PickLocationWidget> createState() => _PickLocationWidgetState();
}

class _PickLocationWidgetState extends State<PickLocationWidget> {
  @override
  void initState() {
    _pickedLocation = LatLng(
      widget.latitude,
      widget.longitude,
    );
    super.initState();
  }

  GoogleMapController? _mapController;
  LatLng? _pickedLocation;
  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      body: Column(
        children: [
          TextFormFieldWidget(
            readOnly: true,
            onTap: () async {
              final selectedPlaceId = await Navigator.push(
                context,
                PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, _, __) =>
                        const SearchLocationWidget()),
              );

              if (selectedPlaceId != null) {
                final latLong = await LocationHelper()
                    .getLatLongByPlaceId(placeId: selectedPlaceId);
                _pickedLocation = latLong;

                setState(() {
                  _pickedLocation = latLong;

                  _mapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: _pickedLocation!, zoom: 17)));
                });
              }
            },
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                zoom: 18,
                target: _pickedLocation!,
              ),
              cameraTargetBounds: CameraTargetBounds.unbounded,
              onTap: _selectLocation,
              markers: _pickedLocation == null
                  ? {}
                  : {
                      Marker(
                          markerId: const MarkerId('m1'), position: _pickedLocation!)
                    },
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
            ),
          ),
          RoundButtonWidget(
            label: 'Pick Location',
            onPressed: _pickedLocation == null
                ? null
                : () {
                    Navigator.of(context).pop(_pickedLocation);
                  },
          ),
        ],
      ),
    );
  }
}
