import 'package:flutter/material.dart';

class ServiceProvider with ChangeNotifier {
  String? id;
  String? userId;
  String? fullName;
  String? mobile;
  String? email;

  ServiceProvider({
    required this.id,
    required this.userId,
    required this.email,
    required this.fullName,
    required this.mobile,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'email': email,
        'fullName': fullName,
        'mobile': mobile,
      };

  static ServiceProvider fromJson(Map<String, dynamic> json) => ServiceProvider(
        id: json['id'],
        userId: json['userId'],
        email: json['email'],
        fullName: json['fullName'],
        mobile: json['mobile'],
      );
}
