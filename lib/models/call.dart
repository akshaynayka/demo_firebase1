import 'package:flutter/material.dart';
import '../models/service.dart';

class Call with ChangeNotifier {
  String? id;
  String? serviceProviderId;
  String? customerId;
  String? technicianId; 
  String? addressId;
  String? etimatedDuration;
  List<Service>? serviceList;
  String? status;

  Call({
    required this.id,
    required this.serviceProviderId,
    required this.customerId,
    required this.technicianId,
    required this.addressId,
    required this.status,
    required this.etimatedDuration,
    this.serviceList,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceProviderId': serviceProviderId,
        'customerId': customerId,
        'addressId':addressId,
        'technicianId': technicianId,
        'etimatedDuration': etimatedDuration,
        'status': status,
      };

  static Call fromJson(Map<String, dynamic> json) => Call(
        id: json['id'],
        serviceProviderId: json['serviceProviderId'],
        customerId: json['customerId'],
        technicianId: json['technicianId'],
        addressId: json['addressId'],
        etimatedDuration: json['etimatedDuration'],
        status: json['status'],
      );
}
