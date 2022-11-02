import 'package:flutter/material.dart';
import '../models/service.dart';

class CustomerCallRequest with ChangeNotifier {
  String? id;
  String? technicianId;
  String? serviceProviderId;
  String? customerId;
  String? addressId;
  List<Service>? serviceList;
  String? status;


  CustomerCallRequest({
    required this.id,
    required this.technicianId,
    required this.serviceProviderId,
    required this.customerId,
    required this.addressId,
    required this.status,
    this.serviceList,

  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'technicianId':technicianId,
        'serviceProviderId':serviceProviderId,
        'addressId': addressId,
        'status': status,

      };

  static CustomerCallRequest fromJson(Map<String, dynamic> json) => CustomerCallRequest(
        id: json['id'],
        customerId: json['customerId'],
        technicianId:json['technicianId'],
        serviceProviderId:json['serviceProviderId'],
        addressId: json['addressId'],
        status: json['status'],
      );
}
