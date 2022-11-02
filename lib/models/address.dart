import 'package:flutter/material.dart';

class Address with ChangeNotifier {
  String? id;
  String? name;
  String? userId;
  String? model;
  String? modelId;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? country;
  String? pincode;
  String? latitude;
  String? longitude;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;
  String? deletedAt;
  String? deletedBy;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.model,
    required this.modelId,
    required this.address1,
    required this.address2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    required this.deletedAt,
    required this.deletedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'userId': userId,
        'model': model,
        'modelId': modelId,
        'address1': address1,
        'address2': address2,
        'city': city,
        'state': state,
        'country': country,
        'pincode': pincode,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
        'deletedAt': deletedAt,
        'deletedBy': deletedBy,
      };

  static Address fromJson(Map<String, dynamic> json) => Address(
        id: json['id'],
        userId: json['userId'],
        name: json['name'],
        model: json['model'],
        modelId: json['modelId'],
        address1: json['address1'],
        address2: json['address2'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
        pincode: json['pincode'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        createdAt: json['createdAt'],
        createdBy: json['createdBy'],
        updatedAt: json['updatedAt'],
        updatedBy: json['updatedBy'],
        deletedAt: json['deletedAt'],
        deletedBy: json['deletedBy'],
      );
}
