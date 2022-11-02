import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../values/api_end_points.dart';

class UserRoleHelper {
  Stream<List<User>>? getRoleStream(
      {required String authId, required BuildContext context}) {
    // FirebaseFirestore.instance
    //     .collection(apiUsers)
    //     .where('userId', isEqualTo: authId)
    //     .snapshots()
    //     .map(
    //       (snapshot) => snapshot.docs
    //           .map(
    //             (doc) => User.fromJson(
    //               doc.data(),
    //             ),
    //           )
    //           .toList(),
    //     );

    Future<User> getUserData(QuerySnapshot<Map<String, dynamic>> data) async {
      final userList = data.docs
          .map(
            (doc) => User.fromJson(
              doc.data(),
            ),
          )
          .toList();
      // print(userList.length);
      // print('_getUserData start--->');
      // print(userList[0].fullName);
      try {
        // print('calling set user data method');
        await Provider.of<UserProvider>(context, listen: false)
            .setCurrentUser(userData: userList[0]);
      } catch (error) {
        // print('error------------>');
        if (kDebugMode) {
          print(error);
        }
      }
      // print('_getUserData end--->');

      return userList[0];
    }

    return FirebaseFirestore.instance
        .collection(apiUsers)
        .where('authId', isEqualTo: authId)
        .snapshots()
        .asyncMap((data) => Future.wait([getUserData(data)]));
  }
}
