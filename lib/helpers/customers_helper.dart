// import 'package:flutter/material.dart';
// import '../helpers/user_helper.dart';
// import '../models/user.dart' as user;
import '../values/string_en.dart';

import '../models/customer.dart';
import '../values/api_end_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomersHelper {
  Stream<List<Customer>> gellAllCustomersStream() {
    return FirebaseFirestore.instance.collection(apiCustomers).snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Customer.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<Customer>> gellAllCustomerList() async {
    final snapshot = FirebaseFirestore.instance.collection(apiCustomers).get();

    return snapshot.then((value) => value.docs
        .map(
          (doc) => Customer.fromJson(
            doc.data(),
          ),
        )
        .toList());
  }

  Future<Customer?> getCustomerDetails(String? cusomerId) async {
    if (cusomerId != null) {
      final customerDetails =
          FirebaseFirestore.instance.collection(apiCustomers).doc(cusomerId);
      final snapshot = await customerDetails.get();
      if (snapshot.exists) {
        return Customer.fromJson(snapshot.data()!);
      }
    }
    return null;
  }

    Future<Customer?> getCustomerDetailsByUserId(
      String? userId) async {
    if (userId != null) {
      final serviceCustomerDetails = await FirebaseFirestore.instance
          .collection(apiCustomers)
          .where('userId', isEqualTo: userId)
          .get()
          .then((value) => value.docs
              .map((doc) => Customer.fromJson(doc.data()))
              .toList());

      if (serviceCustomerDetails.isNotEmpty) {
        return serviceCustomerDetails[0];
      }
    }
    return null;
  }


  Future<String?> addCustomerData({
    required Customer customerData,
  }) async {
    try {
      var messsage = appTitleSomethingWentWrong;

      final customerInstance = FirebaseFirestore.instance
          .collection(apiCustomers)
          .doc(customerData.id);
      customerData.id = customerInstance.id;

      await customerInstance.set(customerData.toJson()).then((value) {
        messsage = 'Customer added';
      });
      return messsage;
    } catch (error) {
      // print('Customer error---->$error');
    }
    return null;
  }
}
