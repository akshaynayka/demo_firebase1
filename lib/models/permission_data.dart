import 'package:flutter/material.dart';

class PermissionData with ChangeNotifier {
  String? id;
  String? parentId;
  String? name;
  String? label;

  PermissionData({
    required this.id,
    required this.parentId,
    required this.name,
    required this.label,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'name': name,
        'label': label,
      };

  static PermissionData fromJson(Map<String, dynamic> json) => PermissionData(
        id: json['id'],
        parentId: json['parentId'],
        name: json['name'],
        label: json['label'],
      );
}
