import 'package:flutter/material.dart';

class Technician with ChangeNotifier {
  String? id;
  String? userId;  
  String? fullName;
  String? mobile;
  String? address;
  String? email;
  String? latitude;
  String? longitude;

  Technician({
    required this.id,
    required this.userId,
    required this.address,
    required this.email,
    required this.fullName,
    required this.latitude,
    required this.longitude,
    required this.mobile,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId':userId,
        'address': address,
        'email': email,
        'fullName': fullName,
        'latitude': latitude,
        'longitude': longitude,
        'mobile': mobile,
      };

  static Technician fromJson(Map<String, dynamic> json) => Technician(
        id: json['id'],
        userId: json['userId'],
        address: json['address'],
        email: json['email'],
        fullName: json['fullName'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        mobile: json['mobile'],
      );
}
