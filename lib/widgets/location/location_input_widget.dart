// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class LocationInputWidget extends StatefulWidget {
//   const LocationInputWidget({Key? key}) : super(key: key);

//   @override
//   State<LocationInputWidget> createState() => _LocationInputWidgetState();
// }

// class _LocationInputWidgetState extends State<LocationInputWidget> {
//   @override
//   void initState() {
//     _getCurrentLocation();
//     super.initState();
//   }

//   var _isLoading;
//   Future<void> _getCurrentLocation() async {
//     setState(() {
//       _isLoading = true;
//     });
//     _currentLocation = await LocationHelper().getCurrentLocation();

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   String? _imagePreviewUrl;
//   Position? _currentLocation;

//   Future<void> _getLocationOnMap({
//     required double latitude,
//     required double longitude,
//   }) async {
//     final staticMapImageUrl = LocationHelper.generateImagePreviewImage(
//       latitude: latitude,
//       longitude: longitude,
//     );

//     setState(() {
//       _imagePreviewUrl = staticMapImageUrl;
//     });
//   }

//   Future<void> _selectOnMap() async {
//     final selectedLocation = await Navigator.of(context).push<LatLng?>(
//       MaterialPageRoute(
//         fullscreenDialog: true,
//         builder: (ctx) => PickLocationWidget(
//           isSelecting: true,
//           latitude: _currentLocation!.latitude,
//           longitude: _currentLocation!.longitude,
//         ),
//       ),
//     );
//     if (selectedLocation != null) {
//       _getLocationOnMap(
//           latitude: selectedLocation.latitude,
//           longitude: selectedLocation.longitude);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(
//             height: 170.0,
//             child: _imagePreviewUrl == null
//                 ? Text(
//                     'No location chosen',
//                     textAlign: TextAlign.center,
//                   )
//                 : Image.network(
//                     _imagePreviewUrl!,
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     alignment: Alignment.center,
//                   )),
//         Row(
//           children: [
//             ElevatedButton.icon(
//                 onPressed: () {
//                   _getLocationOnMap(
//                       latitude: _currentLocation!.latitude,
//                       longitude: _currentLocation!.longitude);
//                 },
//                 icon: Icon(Icons.location_pin),
//                 label: Text('Current Location')),
//             ElevatedButton.icon(
//                 onPressed: _selectOnMap,
//                 icon: Icon(Icons.map_outlined),
//                 label: Text('Chose on map')),
//           ],
//         )
//       ],
//     );
//   }
// }
