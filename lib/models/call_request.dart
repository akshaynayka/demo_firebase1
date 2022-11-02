import 'package:flutter/material.dart';
import '../models/technician.dart';
import '../models/service.dart';

class CallRequest with ChangeNotifier {
  String? id;
  String? serviceProviderId;
  String? customerId;
  String? addressId;
  String? etimatedDuration;
  List<Service>? serviceList;
  List<Technician>? technicianList;
  String? status;
  String? oldStatus;

  CallRequest({
    required this.id,
    required this.serviceProviderId,
    required this.customerId,
    required this.addressId,
    required this.status,
    required this.oldStatus,
    required this.etimatedDuration,
    this.serviceList,
    this.technicianList,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceProviderId': serviceProviderId,
        'customerId': customerId,
        'addressId': addressId,
        'etimatedDuration': etimatedDuration,
        'status': status,
        'oldStatus': oldStatus,
      };

  static CallRequest fromJson(Map<String, dynamic> json) => CallRequest(
        id: json['id'],
        serviceProviderId: json['serviceProviderId'],
        customerId: json['customerId'],
        addressId: json['addressId'],
        etimatedDuration: json['etimatedDuration'],
        status: json['status'],
        oldStatus: json['oldStatus'],
      );
}
