import 'package:flutter/material.dart';

class UserPermission with ChangeNotifier {
  String? id;
  String? userId;
  String? permissionId;

  UserPermission({
    required this.id,
    required this.userId,
    required this.permissionId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'permissionId': permissionId,
      };

  static UserPermission fromJson(Map<String, dynamic> json) => UserPermission(
        id: json['id'],
        userId: json['userId'],
        permissionId: json['permissionId'],
      );
}
