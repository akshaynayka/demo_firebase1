import 'package:flutter/material.dart';

import '../models/service_provider.dart';
import '../values/string_en.dart';
import '../values/api_end_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceProviderHelper {
  Stream<List<ServiceProvider>> getAllServiceProviderStream() {
    return FirebaseFirestore.instance
        .collection(apiServicesProviders)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ServiceProvider.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<ServiceProvider>> gellAllServiceProviderList() async {
    final snapshot =
        FirebaseFirestore.instance.collection(apiServicesProviders).get();

    return snapshot.then((value) => value.docs
        .map(
          (doc) => ServiceProvider.fromJson(
            doc.data(),
          ),
        )
        .toList());
  }

  // Future<List<Staff>> gellAllStaffList() async {
  //   final snapshot = FirebaseFirestore.instance.collection(apiStaff).get();

  //   return snapshot.then((value) => value.docs
  //       .map(
  //         (doc) => Staff.fromJson(
  //           doc.data(),
  //         ),
  //       )
  //       .toList());
  // }

  Future<ServiceProvider?> getServiceProviderDetails(
      String? serviceProviderId) async {
    if (serviceProviderId != null) {
      final serviceProviderDetails = FirebaseFirestore.instance
          .collection(apiServicesProviders)
          .doc(serviceProviderId);
      final snapshot = await serviceProviderDetails.get();
      if (snapshot.exists) {
        return ServiceProvider.fromJson(snapshot.data()!);
      }
    }
    return null;
  }

  // Future<Staff?> getStaffDetailsByUserId(String? userId) async {
  //   if (userId != null) {
  //     final staffDetails = await FirebaseFirestore.instance
  //         .collection(apiStaff)
  //         .where('userId', isEqualTo: userId)
  //         .get()
  //         .then((value) =>
  //             value.docs.map((doc) => Staff.fromJson(doc.data())).toList());

  //     if (staffDetails.isNotEmpty) {
  //       return staffDetails[0];
  //     }
  //   }
  //   return null;
  // }

  Future<ServiceProvider?> getServiceProviderDetailsByUserId(
      String? userId) async {
    if (userId != null) {
      final serviceProviderDetails = await FirebaseFirestore.instance
          .collection(apiServicesProviders)
          .where('userId', isEqualTo: userId)
          .get()
          .then((value) => value.docs
              .map((doc) => ServiceProvider.fromJson(doc.data()))
              .toList());

      if (serviceProviderDetails.isNotEmpty) {
        return serviceProviderDetails[0];
      }
    }
    return null;
  }

  Future<String?> addUpdateServiceProviderData({
    required ServiceProvider serviceProviderData,
  }) async {
    try {
      var messsage = appTitleSomethingWentWrong;

      final serviceProviderInstance = FirebaseFirestore.instance
          .collection(apiServicesProviders)
          .doc(serviceProviderData.id);

      if (serviceProviderData.id != null) {
        await serviceProviderInstance
            .update(serviceProviderData.toJson())
            .then((value) {
          messsage = 'Service Provider updated';
        });
      } else {
        serviceProviderData.id = serviceProviderInstance.id;
        await serviceProviderInstance
            .set(serviceProviderData.toJson())
            .then((value) {
          messsage = 'Service Provider added';
        });
      }

      return messsage;
    } catch (error) {
      debugPrint('service Provider error---->$error');
    }
    return null;
  }
}
