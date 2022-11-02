import 'package:cloud_firestore/cloud_firestore.dart';
import '../values/api_end_points.dart';
import '../values/static_values.dart';

class ResetDataHelper {
  Future<void> _deleteCollectionData(String collectionName) async {
    final instance = FirebaseFirestore.instance;
    final batch = instance.batch();
    final collection = instance.collection(collectionName);
    final snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      if (collectionName == apiUsers) {
        if (doc.data()['role'] == appRoleAdmin) {
          continue;
        }
        if (doc.data()['email'] == 'developers.' '@gmail.com') {
          continue;
        }
      }

      if (collectionName == apiCustomers) {
        if (doc.data()['email'] == 'developers.' '@gmail.com') {
          continue;
        }
      }
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> resetAllData() async {
    final collectionList = [
      apiAddresses,
      apiCallRequests,
      apiCallRequestServices,
      apiCallRequestTechnicians,
      apiCalls,
      apiCallServices,
      apiCallTimeLogs,
      apiCustomerCallRequests,
      apiCustomerCallRequestServices,
      apiCustomers,
      apiServicesProviders,
      apiServiceprovidertechnician,
      apiTechnicians,
      apiUserPermissions,
      apiUsers,
    ];

    for (var collectionName in collectionList) {
      await _deleteCollectionData(collectionName);
    }
  }
}
