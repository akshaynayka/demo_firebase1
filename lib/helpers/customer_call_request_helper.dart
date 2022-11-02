import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/calls_helper.dart';
import '../helpers/customers_helper.dart';
import '../helpers/service_helper.dart';
import '../helpers/service_provider_helper.dart';
import '../helpers/technician_helper.dart';
import '../models/call.dart';
import '../models/customer.dart';
import '../models/customer_call_request.dart';
import '../models/service.dart';
import '../models/service_provider.dart';
import '../models/technician.dart';
import '../values/api_end_points.dart';
import '../values/static_values.dart';

class CustomerCallRequestHelper {
  Future<bool> addCustomerCallRequestServiceList({
    required List<Service> selectedServiceList,
    required String customerCallRequestId,
  }) async {
    var status = false;
    for (var data in selectedServiceList) {
      await _addUpdateCallService(
        customerCallRequestId: customerCallRequestId,
        serviceId: data.id!,
        callServiceId: null,
      );
    }
    return status;
  }

  Future<bool> _addUpdateCallService(
      {required String customerCallRequestId,
      required String serviceId,
      required String? callServiceId}) async {
    var status = false;
    final customerCallRequestService = FirebaseFirestore.instance
        .collection(apiCustomerCallRequestServices)
        .doc(callServiceId);

    final callServiceData = {
      'id': customerCallRequestService.id,
      'customerCallRequestId': customerCallRequestId,
      'serviceId': serviceId,
    };
    await customerCallRequestService.set(callServiceData).then((value) {
      status = true;
    });
    return status;
  }

  Stream<List<CustomerCallRequest>> getCustomerCallRequestStream({
    String? status,
    required String userRole,
    String? technicianId,
    String? customerId,
    String? serviceProviderId,
  }) {
    var callInstance = FirebaseFirestore.instance
        .collection(apiCustomerCallRequests)
        .where('status', isEqualTo: status)
        .where('technicianId', isEqualTo: technicianId);
    if (userRole == appRoleAdmin) {
      callInstance = FirebaseFirestore.instance
          .collection(apiCustomerCallRequests)
          .where('status', isEqualTo: status);
    } else if (userRole == appRoleServiceProvider) {
      callInstance = FirebaseFirestore.instance
          .collection(apiCustomerCallRequests)
          .where('status', isEqualTo: status)
          .where('serviceProviderId', isEqualTo: serviceProviderId);
    } else if (userRole == appRoleCustomer) {
      callInstance = FirebaseFirestore.instance
          .collection(apiCustomerCallRequests)
          .where('status', isEqualTo: status)
          .where('customerId', isEqualTo: customerId);
    }
    final dataList = callInstance.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CustomerCallRequest.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );

    return dataList;
  }

  Future<Map<String, dynamic>> getCustomerCallRequestTechnicianCombineData(
      {required CustomerCallRequest? customerCallRequestTechnicianData}) async {
    Customer? customer;
    Technician? technician;
    ServiceProvider? serviceProvider;

    if (customerCallRequestTechnicianData != null) {
      // final callRequestData = await FirebaseFirestore.instance
      //     .collection(apiCustomerCallRequests)
      //     .doc(customerCallRequestTechnicianData.id)
      //     .get();

      customer = await CustomersHelper()
          .getCustomerDetails(customerCallRequestTechnicianData.customerId);
      // final technicianData = await FirebaseFirestore.instance
      //     .collection(apiTechnicians)
      //     .doc(customerCallRequestTechnicianData.technicianId)
      //     .get();
      // technician = Technician.fromJson(technicianData.data()!);

      technician = await TechnicianHelper().getTechnicianDetails(
          technicianId: customerCallRequestTechnicianData.technicianId);
      serviceProvider = await ServiceProviderHelper().getServiceProviderDetails(
          customerCallRequestTechnicianData.serviceProviderId);
    }

    return {
      'customer': customer,
      'technician': technician,
      'serviceProvider': serviceProvider,
    };
  }

  Future<bool> addUpdateCallRequestTechnician(
      {required CustomerCallRequest callRequestTechnician}) async {
    var status = false;
    final callRequestTechnicianInstance = FirebaseFirestore.instance
        .collection(apiCustomerCallRequests)
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

  Future<CustomerCallRequest?> getCustomerCallRequestDetails(
      String? customerCallRequestId) async {
    if (customerCallRequestId != null) {
      final callDetails = await FirebaseFirestore.instance
          .collection(apiCustomerCallRequests)
          .doc(customerCallRequestId)
          .get();
      // final snapshot = await callDetails.get();

      if (callDetails.exists) {
        var callData = CustomerCallRequest.fromJson(callDetails.data()!);

        callData.serviceList =
            await getCustomerCallRequestServices(callId: callData.id);
        // callData.technicianList = await CallRequestsHelper()
        //     .getAllCallRequestTechniciansData(callRequestId: callData.id);

        return callData;
      }
    }
    return null;
  }

  Future<List<Service>> getCustomerCallRequestServices(
      {required String? callId}) async {
    List<Service> serviceList = [];

    final callSevices = await FirebaseFirestore.instance
        .collection(apiCustomerCallRequestServices)
        .where('customerCallRequestId', isEqualTo: callId)
        .get();
    for (var data in callSevices.docs) {
      final service =
          await ServiceHelper().getServiceDetails(data.data()['serviceId']);
      serviceList.add(service!);
    }
    return serviceList;
  }

  Future<bool> createCallFromCustomerRequest({
    required CustomerCallRequest customerCallRequestData,
  }) async {
    var status = false;

    final callInstance = FirebaseFirestore.instance.collection(apiCalls).doc();
    // callRequestData.id = callInstance.id;
    // callRequestData.status = 'open';

    var callData = Call(
        id: callInstance.id,
        serviceProviderId: null,
        customerId: customerCallRequestData.customerId,
        technicianId: customerCallRequestData.technicianId,
        addressId: customerCallRequestData.addressId,
        status: 'open',
        etimatedDuration: null);
    await callInstance.set(callData.toJson()).then((value) {
      // messsage = 'Call added';
    });

    await CallsHelper().addCallServiceList(
      selectedServiceList: customerCallRequestData.serviceList!,
      callId: callInstance.id,
    );

    return status;
  }

  // Future<bool> addCallServiceList({
  //   required List<Service> selectedServiceList,
  //   required String callId,
  // }) async {
  //   var status = false;
  //   for (var data in selectedServiceList) {
  //     await _addUpdateCallService(
  //       customerCallRequestId: callId,
  //       serviceId: data.id!,
  //       callServiceId: null,
  //     );
  //   }
  //   return status;
  // }
}
