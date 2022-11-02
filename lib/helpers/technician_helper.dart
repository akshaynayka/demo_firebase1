import '../models/service_provider_technician_request.dart';
import '../values/static_values.dart';

import '../values/string_en.dart';

import '../models/technician.dart';
import '../values/api_end_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TechnicianHelper {
  Stream<List<Technician>> getAllTechnicianStream() {
    return FirebaseFirestore.instance
        .collection(apiTechnicians)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Technician.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<Technician>> getAllTechnicianList() async {
    final snapshot =
        FirebaseFirestore.instance.collection(apiTechnicians).get();

    return snapshot.then((value) => value.docs
        .map(
          (doc) => Technician.fromJson(
            doc.data(),
          ),
        )
        .toList());
  }

  Future<List<Technician>> getMyTechnicianList(
      {required String serviceProviderId}) async {
    final snapshot = FirebaseFirestore.instance
        .collection(apiServiceprovidertechnician)
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .where('status', isEqualTo: 'accepted')
        .get();
    final providerTechnicianList =
        await snapshot.then((value) => value.docs.map((doc) {
              return doc.data()['technicianId'];
            }).toList());

    final techniciansInstance = FirebaseFirestore.instance
        .collection(apiTechnicians)
        .where('id', whereIn: providerTechnicianList)
        .get();

    return techniciansInstance.then((value) => value.docs
        .map(
          (doc) => Technician.fromJson(
            doc.data(),
          ),
        )
        .toList());
  }

  Future<Technician?> getTechnicianDetails(
      {required String? technicianId}) async {
    if (technicianId != null) {
      final technicianDetails = FirebaseFirestore.instance
          .collection(apiTechnicians)
          .doc(technicianId);
      final snapshot = await technicianDetails.get();
      if (snapshot.exists) {
        return Technician.fromJson(snapshot.data()!);
      }
    }
    return null;
  }

  Future<Technician?> getTechnicianDetailsByUserId(String? userId) async {
    if (userId != null) {
      final technicianDetails = await FirebaseFirestore.instance
          .collection(apiTechnicians)
          .where('userId', isEqualTo: userId)
          .get()
          .then((value) => value.docs
              .map((doc) => Technician.fromJson(doc.data()))
              .toList());
      if (technicianDetails.isNotEmpty) {
        return technicianDetails[0];
      }
    }
    return null;
  }

  Future<String?> addTechnicianData({
    required Technician technicianData,
  }) async {
    try {
      var messsage = appTitleSomethingWentWrong;

      final technicianInstance = FirebaseFirestore.instance
          .collection(apiTechnicians)
          .doc(technicianData.id);
      technicianData.id = technicianInstance.id;

      await technicianInstance.set(technicianData.toJson()).then((value) {
        messsage = 'Technician added';
      });
      return messsage;
    } catch (error) {
      // print('Technician error---->$error');
    }
    return null;
  }

  Stream<List<ServiceProviderTechnicianRequest>> getMyTechnicianStream({
    List<String?>? status,
    required String userRole,
    String? technicianId,
    String? serviceProviderId,
  }) {
    var key = 'serviceProviderId';
    var value = serviceProviderId;
    // String? requestedBy;
    if (userRole == appRoleTechnician) {
      key = 'technicianId';
      value = technicianId;
      // if (status == 'requested') {
      //   requestedBy = appRoleServiceProvider;
      // } else {
      //   requestedBy = null;
      // }
    } 
    // else {
    //   if (status == 'requested') {
    //     requestedBy = appRoleTechnician;
    //   }
    // }
    // if (status == 'sent') {
    //   requestedBy = userRole;
    //   status = 'requested';
    // }
    var myTechnicianInstance = FirebaseFirestore.instance
        .collection(apiServiceprovidertechnician)
        .where(key, isEqualTo: value)
        // .where('requestedBy', isEqualTo: requestedBy)
        .where('status', whereIn: status);

    final dataList = myTechnicianInstance.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ServiceProviderTechnicianRequest.fromJson(doc.data()),
              )
              .toList(),
        );
    return dataList;
  }

  // Stream<List<ServiceProviderTechnicianRequest>> getMyTechnicianStream000({
  //   String? status,
  //   required String userRole,
  //   String? technicianId,
  //   String? serviceProviderId,
  // }) {
  //   var key = 'serviceProviderId';
  //   var value = serviceProviderId;
  //   String? requestedBy;
  //   if (userRole == appRoleTechnician) {
  //     key = 'technicianId';
  //     value = technicianId;
  //     if (status == 'requested') {
  //       requestedBy = appRoleServiceProvider;
  //     } else {
  //       requestedBy = null;
  //     }
  //   } else {
  //     if (status == 'requested') {
  //       requestedBy = appRoleTechnician;
  //     }
  //   }
  //   if (status == 'sent') {
  //     requestedBy = userRole;
  //     status = 'requested';
  //   }
  //   var myTechnicianInstance = FirebaseFirestore.instance
  //       .collection(apiServiceprovidertechnician)
  //       .where(key, isEqualTo: value)
  //       // .where('requestedBy', isEqualTo: requestedBy)
  //       .where('status', isEqualTo: status);

  //   final dataList = myTechnicianInstance.snapshots().map(
  //         (snapshot) => snapshot.docs
  //             .map(
  //               (doc) => ServiceProviderTechnicianRequest.fromJson(doc.data()),
  //             )
  //             .toList(),
  //       );
  //   return dataList;
  // }

  //   Stream<List<ServiceProviderTechnicianRequest>> getMyTechnicianStream({
  //   List<String?>? status,
  //   required String userRole,
  //   String? technicianId,
  //   String? serviceProviderId,
  // }) {
  //   var key = 'serviceProviderId';
  //   var value = serviceProviderId;
  //   String? requestedBy;
  //   if (userRole == appRoleTechnician) {
  //     key = 'technicianId';
  //     value = technicianId;
  //     // if (status == 'requested') {
  //     //   requestedBy = appRoleServiceProvider;
  //     // } else {
  //     //   requestedBy = null;
  //     // }
  //   } else {
  //     // if (status == 'requested') {
  //     //   requestedBy = appRoleTechnician;
  //     // }
  //   }
  //   // if (status == 'sent') {
  //   //   requestedBy = userRole;
  //   //   status = 'requested';
  //   // }
  //   var myTechnicianInstance = FirebaseFirestore.instance
  //       .collection(apiServiceprovidertechnician)
  //       .where(key, isEqualTo: value)
  //       .where('requestedBy', isEqualTo: requestedBy)
  //       .where('status', whereIn: ['requested']);

  //   final dataList = myTechnicianInstance.snapshots().map(
  //         (snapshot) => snapshot.docs
  //             .map(
  //               (doc) => ServiceProviderTechnicianRequest.fromJson(doc.data()),
  //             )
  //             .toList(),
  //       );
  //   return dataList;
  // }

  Future<List<ServiceProviderTechnicianRequest>> getMyTechnicianRequestList({
    String? status,
    required String userRole,
    String? technicianId,
    String? serviceProviderId,
  }) async {
    var key = 'serviceProviderId';
    var value = serviceProviderId;
    String? requestedBy;
    if (userRole == appRoleTechnician) {
      key = 'technicianId';
      value = technicianId;
      if (status == 'requested') {
        requestedBy = appRoleServiceProvider;
      } else {
        requestedBy = null;
      }
    } else {
      if (status == 'requested') {
        requestedBy = appRoleTechnician;
      }
    }
    if (status == 'sent') {
      requestedBy = userRole;
      status = 'requested';
    }
    var myTechnicianList = await FirebaseFirestore.instance
        .collection(apiServiceprovidertechnician)
        .where(key, isEqualTo: value)
        .where('requestedBy', isEqualTo: requestedBy)
        .where('status', isEqualTo: status)
        .get()
        .then((value) => value.docs
            .map((doc) => ServiceProviderTechnicianRequest.fromJson(doc.data()))
            .toList());

    // final dataList = myTechnicianInstance.snapshots().map(
    //       (snapshot) => snapshot.docs
    //           .map(
    //             (doc) => ServiceProviderTechnicianRequest.fromJson(doc.data()),
    //           )
    //           .toList(),
    //     );
    return myTechnicianList;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMyTechnicianCounterStream({
    required String userRole,
    String? technicianId,
    String? serviceProviderId,
  }) {
    technicianId = technicianId ?? '';
    serviceProviderId = serviceProviderId ?? '';
    var key = 'serviceProviderId';
    var value = serviceProviderId;
    if (userRole == appRoleTechnician) {
      key = 'technicianId';
      value = technicianId;
    }
    var myTechnicianInstance = FirebaseFirestore.instance
        .collection(apiServiceprovidertechnician)
        .where(key, isEqualTo: value)
        .where('status', isEqualTo: 'accepted');

    final dataList = myTechnicianInstance.snapshots();
    // .map(
    //       (snapshot) => snapshot.docs
    //           .map(
    //             (doc) => ServiceProviderTechnicianRequest.fromJson(doc.data()),
    //           )
    //           .toList(),
    //     );
    return dataList;
  }

  Future<String?> addServiceProviderTechnicianData(
      {required ServiceProviderTechnicianRequest requestData}) async {
    try {
      var messsage = appTitleSomethingWentWrong;

      final serviceProviderTechnicianInstance = FirebaseFirestore.instance
          .collection(apiServiceprovidertechnician)
          .doc(requestData.id);
      // technicianData.id = serviceProviderTechnician.id;
      // final data = {
      //   'id': serviceProviderTechnician.id,
      //   'technicianId': technicianId,
      //   'serviceProviderId': serviceProviderId,
      //   'requestedBy': requestedBy,
      //   'status': 'requested',
      // };

      if (requestData.id != null) {
        await serviceProviderTechnicianInstance
            .update(requestData.toJson())
            .then((value) {
          messsage = 'ServiceProvider updated';
        });
      } else {
        requestData.id = serviceProviderTechnicianInstance.id;
        // final data = {
        //   'id': serviceProviderTechnicianInstance.id,
        //   'technicianId': requestData.technicianId,
        //   'serviceProviderId': requestData.serviceProviderId,
        //   'requestedBy': requestData.requestedBy,
        //   'status': 'requested',
        // };
        await serviceProviderTechnicianInstance
            .set(requestData.toJson())
            .then((value) {
          messsage = 'ServiceProvider added';
        });
      }

      return messsage;
    } catch (error) {
      // print('Technician error---->$error');
    }
    return null;
  }
}
