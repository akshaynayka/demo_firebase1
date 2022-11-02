import 'package:flutter/material.dart';

class Customer with ChangeNotifier {
  String? id;
  String? userId;
  String? fullName;
  String? mobile;
  String? address;
  String? email;
  String? latitude;
  String? longitude;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  Customer({
    required this.id,
    required this.userId,
    required this.address,
    required this.email,
    required this.fullName,
    required this.latitude,
    required this.longitude,
    required this.mobile,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'address': address,
        'email': email,
        'fullName': fullName,
        'latitude': latitude,
        'longitude': longitude,
        'mobile': mobile,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  static Customer fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        userId: json['userId'],
        address: json['address'],
        email: json['email'],
        fullName: json['fullName'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        mobile: json['mobile'],
        createdAt: json['createdAt'],
        createdBy: json['createdBy'],
        updatedAt: json['updatedAt'],
        updatedBy: json['updatedBy'],
      );
}
