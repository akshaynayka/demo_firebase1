import '../models/address.dart';

import '../values/api_end_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddressesHelper {
  Stream<List<Address>> gellAllAddressesStream({required String userId}) {
    return FirebaseFirestore.instance
        .collection(apiAddresses)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Address.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<Address>> getUserAddressList({required String userId}) async {

    final snapshot = FirebaseFirestore.instance
        .collection(apiAddresses)
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.then((value) => value.docs
        .map(
          (doc) => Address.fromJson(
            doc.data(),
          ),
        )
        .toList());
  }

  Future<Address?> getAddressDetails({required String? addressId}) async {
    if (addressId != null) {
      final addressDetails =
          FirebaseFirestore.instance.collection(apiAddresses).doc(addressId);
      final snapshot = await addressDetails.get();
      if (snapshot.exists) {
        return Address.fromJson(snapshot.data()!);
      }
    }
    return null;
  }

// Future<Address?> _getDefaultAddress()async{
//   return null;
// }

}
