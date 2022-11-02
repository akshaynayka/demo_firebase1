import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/customers_helper.dart';
import '../helpers/service_helper.dart';
import '../helpers/service_provider_helper.dart';
import '../helpers/technician_helper.dart';
import '../models/call_request.dart';
import '../models/call_request_technician.dart';
import '../models/customer.dart';
import '../models/service.dart';
import '../models/service_provider.dart';
import '../models/technician.dart';
import '../values/api_end_points.dart';
import '../values/static_values.dart';

class CallRequestsHelper {
  Stream<List<CallRequestTechnician>> getAllCallRequestTechnicianStream({
    String? status,
    required String userRole,
    String? technicianId,
    String? serviceProviderId,
  }) {
    technicianId = technicianId ?? '';
    serviceProviderId = serviceProviderId ?? '';

    var callRequestInstance = FirebaseFirestore.instance
        .collection(apiCallRequestTechnicians)
        .where('technicianId', isEqualTo: technicianId)
        .where('status', isEqualTo: status);
    if (userRole == appRoleAdmin) {
      callRequestInstance = FirebaseFirestore.instance
          .collection(apiCallRequestTechnicians)
          .where('status', isEqualTo: status);
    } else if (userRole == appRoleServiceProvider) {
      callRequestInstance = FirebaseFirestore.instance
          .collection(apiCallRequestTechnicians)
          .where('serviceProviderId', isEqualTo: serviceProviderId)
          .where('status', isEqualTo: status);
    }
    final dataList = callRequestInstance.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CallRequestTechnician.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
    return dataList;
  }

  Future<List<Technician>> getAllCallRequestTechniciansData(
      {required String? callRequestId}) async {
    List<Technician> technicianList = [];

    final callSevices = await FirebaseFirestore.instance
        .collection(apiCallRequestTechnicians)
        .where('callRequestId', isEqualTo: callRequestId)
        .get();
    for (var data in callSevices.docs) {

      final technician = await TechnicianHelper()
          .getTechnicianDetails(technicianId: data.data()['technicianId']);
      technicianList.add(technician!);
    }
    return technicianList;
  }

  Future<List<CallRequestTechnician>> getAllCallTechniciansRequestList(
      {required String? callRequestId}) async {
    final callTechnicianList = await FirebaseFirestore.instance
        .collection(apiCallRequestTechnicians)
        .where('callRequestId', isEqualTo: callRequestId)
        .get()
        .then((value) => value.docs
            .map((doc) => CallRequestTechnician.fromJson(doc.data()))
            .toList());
    // for (var data in callSevices.docs) {
    //   // print(data.data());

    //   final technician = await TechnicianHelper()
    //       .getTechnicianDetails(technicianId: data.data()['technicianId']);
    //   technicianList.add(technician!);
    // }
    return callTechnicianList;
  }

  Future<bool> addCallRequestTechnicianList({
    required List<Technician> selectedTechnicianList,
    required String callRequestId,
    String? serviceProviderId,
  }) async {
    var status = false;
    for (var data in selectedTechnicianList) {
      await addUpdateCallRequestTechnician(
        // callRequestId: callRequestId,
        // technicianId: data.id!,
        // callRequestTechnicianId: null,
        callRequestTechnician: CallRequestTechnician(
          id: null,
          technicianId: data.id!,
          callRequestId: callRequestId,
          serviceProviderId: serviceProviderId,
          status: 'requested',
          oldStatus: 'requested',
        ),
      );
    }
    return status;
  }

  Future<bool> addUpdateCallRequestTechnician(
      {required CallRequestTechnician callRequestTechnician}) async {
    var status = false;
    final callRequestTechnicianInstance = FirebaseFirestore.instance
        .collection(apiCallRequestTechnicians)
        .doc(callRequestTechnician.id);

    // final callServiceData = {
    //   'id': callRequestTechnicianInstance.id,
    //   'callRequestId': callRequestTechnician.callRequestId,
    //   'technicianId': callRequestTechnician.technicianId,
    // };
    if (callRequestTechnician.id != null) {
      await callRequestTechnicianInstance
          .update(callRequestTechnician.toJson())
          .then((value) {
        status = true;
      });
    } else {
      callRequestTechnician.id = callRequestTechnicianInstance.id;
      await callRequestTechnicianInstance
          .set(callRequestTechnician.toJson())
          .then((value) {
        status = true;
      });
    }
    return status;
  }

  Future<bool> updateCallRequestTechniciansStatus({
    // required List<CallRequestTechnician> callRequestTechnicianList,
    required String callRequestId,
    required String technicianId,
  }) async {
    var status = false;

    final callRequestTechnicianList =
        await getAllCallTechniciansRequestList(callRequestId: callRequestId);

    for (var data in callRequestTechnicianList) {
      if (data.technicianId == technicianId) {
        data.oldStatus = data.status;
        data.status = 'assigned';
      } else if (data.status == 'assigned') {
        data.oldStatus = data.status;
        data.status = 'cancel';
      } else if (data.status == 'accepted') {
        data.oldStatus = data.status;
      }
      await addUpdateCallRequestTechnician(
        callRequestTechnician: data,
      );
    }
    status = true;
    return status;
  }

  Future<bool> addCallRequestServiceList({
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

  Future<bool> _addUpdateCallService(
      {required String callId,
      required String serviceId,
      required String? callServiceId}) async {
    var status = false;
    final callService = FirebaseFirestore.instance
        .collection(apiCallRequestServices)
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

  Future<List<Service>> getAllCallServices({required String? callId}) async {
    List<Service> serviceList = [];

    final callSevices = await FirebaseFirestore.instance
        .collection(apiCallRequestServices)
        .where('callId', isEqualTo: callId)
        .get();
    for (var data in callSevices.docs) {
      final service =
          await ServiceHelper().getServiceDetails(data.data()['serviceId']);
      serviceList.add(service!);
    }
    return serviceList;
  }

  Future<bool> _deleteCallService(
      {required String callId,
      required String serviceId,
      required String? callServiceId}) async {
    var status = false;

    final callSevices = await FirebaseFirestore.instance
        .collection(apiCallRequestServices)
        .where('callId', isEqualTo: callId)
        .where('serviceId', isEqualTo: serviceId)
        .get();

    await FirebaseFirestore.instance
        .collection(apiCallRequestServices)
        .doc(callSevices.docs[0].id)
        .delete()
        .then((value) {
      status = true;
    });

    return status;
  }

  Stream<List<CallRequest>> getAllCallRequestsStream({
    String? status,
    required String userRole,
    String? serviceProviderId,
  }) {
    var callInstance = FirebaseFirestore.instance
        .collection(apiCallRequests)
        .where('status', isEqualTo: status)
        .where('serviceProviderId', isEqualTo: serviceProviderId);
    if (userRole == appRoleAdmin) {
      callInstance = FirebaseFirestore.instance
          .collection(apiCallRequests)
          .where('status', isEqualTo: status);
    } else if (userRole == appRoleAdmin) {
      callInstance = FirebaseFirestore.instance
          .collection(apiCallRequests)
          .where('status', isEqualTo: status);
    }
    final dataList = callInstance.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CallRequest.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
    return dataList;
  }

  Future<CallRequest?> getCallRequestDetails(String? callRequestId) async {
    if (callRequestId != null) {
      final callDetails = await FirebaseFirestore.instance
          .collection(apiCallRequests)
          .doc(callRequestId)
          .get();
      // final snapshot = await callDetails.get();

      if (callDetails.exists) {
        var callData = CallRequest.fromJson(callDetails.data()!);

        callData.serviceList =
            await getAllCallRequestServices(callId: callData.id);
        callData.technicianList = await CallRequestsHelper()
            .getAllCallRequestTechniciansData(callRequestId: callData.id);

        return callData;
      }
    }
    return null;
  }

  Future<List<Service>> getAllCallRequestServices(
      {required String? callId}) async {
    List<Service> serviceList = [];

    final callSevices = await FirebaseFirestore.instance
        .collection(apiCallRequestServices)
        .where('callId', isEqualTo: callId)
        .get();
    for (var data in callSevices.docs) {
      // print(data.data());

      final service =
          await ServiceHelper().getServiceDetails(data.data()['serviceId']);
      serviceList.add(service!);
    }
    return serviceList;
  }

  Future<Map<String, dynamic>> getCallRequestTechnicianCombineData(
      {required CallRequestTechnician? callRequestTechnicianData}) async {
    Customer? customer;
    Technician? technician;
    ServiceProvider? serviceProvider;
    if (callRequestTechnicianData != null) {
      final callRequestData = await FirebaseFirestore.instance
          .collection(apiCallRequests)
          .doc(callRequestTechnicianData.callRequestId)
          .get();

      customer = await CustomersHelper()
          .getCustomerDetails(callRequestData.data()!['customerId']);

      technician = await TechnicianHelper().getTechnicianDetails(
          technicianId: callRequestTechnicianData.technicianId);
      serviceProvider = await ServiceProviderHelper().getServiceProviderDetails(
          callRequestTechnicianData.serviceProviderId);
    }
    return {
      'customer': customer,
      'technician': technician,
      'serviceProvider': serviceProvider,
    };
  }

  Future<Map<String, dynamic>> getCallRequestCombineData(
      CallRequest? callData) async {
    Customer? customer;
    Service? service;
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
      service = Service(
        id: null,
        name: 'Test',
        description: '2',
        etimatedDuration: null,
        status: 'active',
        createdAt: null,
        createdBy: null,
        updatedAt: null,
        updatedBy: null,
        deletedAt: null,
        deletedBy: null,
      );
    }
    return {
      'customer': customer,
      'service': service,
    };
  }
}
