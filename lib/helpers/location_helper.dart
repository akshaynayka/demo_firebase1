import 'dart:convert';

import 'package:demo_firebase1/config/api_key_config.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../http_request/http_request.dart';

final HttpRequest _httpRequest = HttpRequest();

class LocationHelper {
  Future<Position?> getCurrentLocation() async {
    final userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      // timeLimit: Duration(seconds: 10),
    );
    // final distance = Geolocator.distanceBetween(
    //     20.9471109, 72.9371427, 20.947281, 72.936593);
    debugPrint('current location');
    debugPrint(userPosition.latitude.toString());
    debugPrint(userPosition.longitude.toString());
    // if (!init) {
    //   final currentAddress = await getCurrentAddress(
    //       lat: userPosition.latitude, long: userPosition.longitude);
    // }
    return userPosition;
  }

  Future<dynamic> getCurrentAddress({
    required double lat,
    required double long,
    BuildContext? context,
  }) async {
    debugPrint('get crrent address------');
    try {
      final response = await _httpRequest.getRequest(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$googleMapApiKey',
        '',
        context: context,
      );

      final extractedData = json.decode(response.body)['results'][0];

      return extractedData;
    } catch (error) {
      rethrow;
    }
  }

  Future<LatLng?> getLatLongByPlaceId(
      {required String placeId, BuildContext? context}) async {
    LatLng? latLong;
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapApiKey";
    final response = await HttpRequest().getRequest(url, '', context: context);
    final extractedData =
        json.decode(response.body)['result']['geometry']['location'];
    latLong = LatLng(
      extractedData['lat'],
      extractedData['lng'],
    );
    return latLong;
  }

  static String generateImagePreviewImage(
      {required double latitude, required double longitude}) {
    return "https://maps.googleapis.com/maps/api/staticmap?center=&$latitude&$longitude&zoom=18&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$googleMapApiKey";
  }
}
