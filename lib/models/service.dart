import 'package:flutter/material.dart';

class Service with ChangeNotifier {
  String? id;
  String? name;
  String? description;
  String? etimatedDuration;
  String? status;
  String? createdAt;
  String? createdBy;
  String? updatedAt;
  String? updatedBy;
  String? deletedAt;
  String? deletedBy;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.etimatedDuration,
    required this.status,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.deletedAt,
    this.deletedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'etimatedDuration': etimatedDuration,
        'status': status,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
        'deletedAt': deletedAt,
        'deletedBy': deletedBy,
      };

  static Service fromJson(Map<String, dynamic> json) => Service(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        etimatedDuration: json['etimatedDuration'],
        status: json['status'],
        createdAt: json['createdAt'],
        createdBy: json['createdBy'],
        updatedAt: json['updatedAt'],
        updatedBy: json['updatedBy'],
        deletedAt: json['deletedAt'],
        deletedBy: json['deletedBy'],
      );
}
