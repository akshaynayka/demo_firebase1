import 'dart:convert';

import 'package:demo_firebase1/config/api_key_config.dart';

import '../../http_request/http_request.dart';
import '../../models/predicted_location.dart';
import '../../widgets/appbar_widget.dart';
import '../../widgets/text_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchLocationWidget extends StatefulWidget {
  const SearchLocationWidget({Key? key}) : super(key: key);

  @override
  State<SearchLocationWidget> createState() => _SearchLocationWidgetState();
}

class _SearchLocationWidgetState extends State<SearchLocationWidget> {
  List<PredictedLocation>? _searchedLocationList = [];
  Future<List<PredictedLocation>?> _getAddressList(
      {required String searchText, BuildContext? context}) async {
    List<PredictedLocation>? locationList = [];
    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchText&key=$googleMapApiKey';
      // print(url);
      final response = await HttpRequest().getRequest(
        url,
        '',
        context: context,
      );
      final extractedData = json.decode(response.body)['predictions'];

      locationList = extractedData
          .map<PredictedLocation>((json) => PredictedLocation.formJson(json))
          .toList();
      // print(locationList![0].description);
      return locationList;
    } catch (error) {
      rethrow;
    }
  }

  Future<LatLng?> _getLatLongByPlaceId({required String placeId}) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      backgroundColor: Colors.black26,
      body: Column(
        children: [
          TextFormFieldWidget(
            autofocus: true,
            suffixIcon: IconButton(
                onPressed: () async {
                  await _getAddressList(
                      searchText: 'demo 1 navsari', context: context);
                },
                icon: const Icon(Icons.search)),
            onChanged: (value) async {
              if (value.length > 3) {
                final locationList =
                    await _getAddressList(searchText: value, context: context);
                setState(() {
                  _searchedLocationList = locationList;
                });
              } else if (value.isEmpty) {
                _searchedLocationList = [];
                setState(() {});
              }
            },
          ),
          Expanded(
            child: _searchedLocationList!.isEmpty
                ? GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                : ListView.builder(
                    itemCount: _searchedLocationList!.length,
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        title: Text(_searchedLocationList![index].description!),
                        onTap: () async {
                          Navigator.of(context)
                              .pop(_searchedLocationList![index].placeId);
                          await _getLatLongByPlaceId(
                              placeId: _searchedLocationList![index].placeId!);
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
