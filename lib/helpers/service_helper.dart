import '../models/service.dart';
import '../values/api_end_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceHelper {
  Stream<List<Service>> getAllServicesStream() {
    return FirebaseFirestore.instance.collection(apiServices).snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Service.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<Service>> gellAllServiceList() async {
    final snapshot = FirebaseFirestore.instance.collection(apiServices).get();

    return snapshot.then((value) => value.docs
        .map(
          (doc) => Service.fromJson(
            doc.data(),
          ),
        )
        .toList());
  }

  Future<Service?> getServiceDetails(String? serviceId) async {
    if (serviceId != null) {
      final serviceDetails =
          FirebaseFirestore.instance.collection(apiServices).doc(serviceId);
      final snapshot = await serviceDetails.get();
      if (snapshot.exists) {
        return Service.fromJson(snapshot.data()!);
      }
    }
    return null;
  }
}
