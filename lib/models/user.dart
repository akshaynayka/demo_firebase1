import 'package:flutter/material.dart';

class User with ChangeNotifier {
  String? id;
  String? fullName;
  String? mobile;
  String? password;
  String? email;
  String? role;
  String? authId;
  String? imageUrl;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.mobile,
    this.password,
    required this.role,
    required this.authId,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'mobile': mobile,
        'role': role,
        'authId': authId,
        'imageUrl': imageUrl,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        email: json['email'],
        fullName: json['fullName'],
        mobile: json['mobile'],
        role: json['role'],
        authId: json['authId'],
        imageUrl: json['imageUrl'],
      );
}
