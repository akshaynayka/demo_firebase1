import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_request.dart';
import '../values/static_values.dart';
import '../models/call_time_log.dart';
import '../helpers/service_helper.dart';
import '../models/call.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../values/api_end_points.dart';

class CallsHelper {
  Stream<List<Call>> getAllCallsStream({
    List<String?>? statusList,
    required String userRole,
    String? technicianId,
    String? serviceProviderId,
    String? customerId,
  }) {
    var callInstance = FirebaseFirestore.instance
        .collection(apiCalls)
        .where('status', whereIn: statusList)
        // .where('status', isEqualTo: status)
        .where('technicianId', isEqualTo: technicianId);
    if (userRole == appRoleAdmin) {
      callInstance = FirebaseFirestore.instance
          .collection(apiCalls)
          .where('status', whereIn: statusList);
    } else if (userRole == appRoleServiceProvider) {
      callInstance = FirebaseFirestore.instance
          .collection(apiCalls)
          .where('status', whereIn: statusList)
          .where('serviceProviderId', isEqualTo: serviceProviderId);
    } else if (userRole == appRoleCustomer) {
      callInstance = FirebaseFirestore.instance
          .collection(apiCalls)
          .where('status', whereIn: statusList)
          .where('customerId', isEqualTo: customerId);
    }
    final dataList = callInstance.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Call.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
    return dataList;
  }

  Future<Call?> getCallDetails(String? callId) async {
    if (callId != null) {
      final callDetails = await FirebaseFirestore.instance
          .collection(apiCalls)
          .doc(callId)
          .get();
      // final snapshot = await callDetails.get();

      if (callDetails.exists) {
        var callData = Call.fromJson(callDetails.data()!);

        callData.serviceList = await getAllCallServices(callId: callData.id);
        return callData;
      }
    }
    return null;
  }

  Future<Call?> getCallDetailsFromRequestId(String? callRequestId) async {
    if (callRequestId != null) {
      final callDetails = await FirebaseFirestore.instance
          .collection(apiCalls)
          .where('callRequestId', isEqualTo: callRequestId)
          .get()
          .then((value) =>
              value.docs.map((doc) => Call.fromJson(doc.data())).toList());
      if (callDetails.isNotEmpty) {
        return callDetails[0];
      }

      // }
    }
    return null;
  }

  Future<List<Service>> getAllCallServices({required String? callId}) async {
    List<Service> serviceList = [];
    final callSevices = await FirebaseFirestore.instance
        .collection(apiCallServices)
        .where('callId', isEqualTo: callId)
        .get();
    for (var data in callSevices.docs) {
      final service =
          await ServiceHelper().getServiceDetails(data.data()['serviceId']);
      serviceList.add(service!);
    }
    return serviceList;
  }

  Future<bool> addCallServiceList({
    required List<Service> selectedServiceList,
    required String callId,
  }) async {
    var status = false;
    for (var data in selectedServiceList) {
      await _addUpdateCallService(
        callId: callId,
        serviceId: data.id!,
        callServiceId: null,
      );
    }
    return status;
  }

  Future<bool> updateCallServiceList({
    required List<Service> selectedServiceList,
    required String callId,
  }) async {
    var status = false;

    final callServiceList = await getAllCallServices(callId: callId);

    final List<Service> commonList = [];
    final List<Service> newList = [];
    bool checkContainsOrNot(List<Service> serviceList, String serviceId) {
      return serviceList
                  .firstWhere((data) => data.id == serviceId,
                      orElse: () => Service(
                            id: null,
                            name: null,
                            description: null,
                            etimatedDuration: null,
                            status: null,
                          ))
                  .id !=
              null
          ? true
          : false;
    }

    for (var i = 0; i < selectedServiceList.length; i++) {
      final contains =
          checkContainsOrNot(callServiceList, selectedServiceList[i].id!);
      if (contains) {
        commonList.add(selectedServiceList[i]);
      } else {
        newList.add(selectedServiceList[i]);
      }
    }

    for (var i = 0; i < callServiceList.length; i++) {
      final containsOld =
          checkContainsOrNot(commonList, callServiceList[i].id!);

      if (!containsOld) {
        _deleteCallService(
            callId: callId,
            serviceId: callServiceList[i].id!,
            callServiceId: null);
      }
    }
    for (var i = 0; i < newList.length; i++) {
      _addUpdateCallService(
        callId: callId,
        serviceId: newList[i].id!,
        callServiceId: null,
      );
    }

    return status;
  }

  Future<bool> _addUpdateCallService(
      {required String callId,
      required String serviceId,
      required String? callServiceId}) async {
    var status = false;
    final callService = FirebaseFirestore.instance
        .collection(apiCallServices)
        .doc(callServiceId);

    final callServiceData = {
      'id': callService.id,
      'callId': callId,
      'serviceId': serviceId,
    };
    await callService.set(callServiceData).then((value) {
      status = true;
    });
    return status;
  }

  Future<bool> _deleteCallService(
      {required String callId,
      required String serviceId,
      required String? callServiceId}) async {
    var status = false;

    final callSevices = await FirebaseFirestore.instance
        .collection(apiCallServices)
        .where('callId', isEqualTo: callId)
        .where('serviceId', isEqualTo: serviceId)
        .get();

    await FirebaseFirestore.instance
        .collection(apiCallServices)
        .doc(callSevices.docs[0].id)
        .delete()
        .then((value) {
      status = true;
    });

    return status;
  }

  Future<Map<String, dynamic>> getCallCombineData(Call? callData) async {
    Customer? customer;
    if (callData != null) {
      final customerData = await FirebaseFirestore.instance
          .collection(apiCustomers)
          .doc(callData.customerId)
          .get();

      customer = Customer.fromJson(customerData.data()!);
      // final serviceData = await FirebaseFirestore.instance
      //     .collection(apiServices)
      //     .doc(callData.serviceId)
      //     .get();
      // print(serviceData.data());
    }
    return {
      'customer': customer,
    };
  }

  Stream<List<CallTimeLog>> getAllCallLogStream({String? callId}) {
    return FirebaseFirestore.instance
        .collection(apiCallTimeLogs)
        .where('callId', isEqualTo: callId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CallTimeLog.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<bool> addUpdateCallLog({
    required CallTimeLog callTimeLog,
  }) async {
    var status = false;
    try {
      final callTimeLogInstance = FirebaseFirestore.instance
          .collection(apiCallTimeLogs)
          .doc(callTimeLog.id);
      if (callTimeLog.id != null) {
        await callTimeLogInstance.update(callTimeLog.toJson()).then((value) {
          status = true;
        });
      } else {
        callTimeLog.id = callTimeLogInstance.id;
        await callTimeLogInstance.set(callTimeLog.toJson()).then((value) {
          status = true;
        });
      }
    } catch (error) {
      debugPrint('error-->$error');
    }

    return status;
  }

  Future<bool> createCallFromRequest(
      {required CallRequest callRequestData,
      required String technicianId}) async {
    var status = false;

    final callInstance = FirebaseFirestore.instance.collection(apiCalls).doc();
    // callRequestData.id = callInstance.id;
    // callRequestData.status = 'open';

    var callData = Call(
        id: callInstance.id,
        serviceProviderId: callRequestData.serviceProviderId,
        customerId: callRequestData.customerId,
        technicianId: technicianId,
        addressId: callRequestData.addressId,
        status: 'open',
        etimatedDuration: callRequestData.etimatedDuration);
    await callInstance.set(callData.toJson()).then((value) {
      // messsage = 'Call added';
    });

    await addCallServiceList(
      selectedServiceList: callRequestData.serviceList!,
      callId: callInstance.id,
    );

    return status;
  }
}
