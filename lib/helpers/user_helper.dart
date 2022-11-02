import 'dart:convert';
import 'package:demo_firebase1/config/firebase_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../helpers/permission_helper.dart';
import '../models/permission_data.dart';
import '../values/app_permissions.dart';
import '../values/static_values.dart';
import '../http_request/http_request.dart';
import '../models/device_info.dart';
import '../models/http_exception.dart';

import '../models/user.dart' as user;

import '../values/api_end_points.dart';

class UsersHelper {
  Stream<List<user.User>> gellAllUsersStream({String? role}) {
    final userInstance = FirebaseFirestore.instance.collection(apiUsers);
    var userSnapshot = userInstance.snapshots();
    if (role != null) {
      userSnapshot = userInstance.where('role', isEqualTo: role).snapshots();
    }
    return userSnapshot.map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => user.User.fromJson(
              doc.data(),
            ),
          )
          .toList(),
    );
  }

  Future<List<user.User>> gellAllUserList() async {
    final snapshot = FirebaseFirestore.instance.collection(apiUsers).get();

    return snapshot.then((value) => value.docs
        .map(
          (doc) => user.User.fromJson(
            doc.data(),
          ),
        )
        .toList());
  }

  Future<user.User?> getUserDetails(String? userId) async {
    if (userId != null) {
      final userDetails =
          FirebaseFirestore.instance.collection(apiUsers).doc(userId);
      final snapshot = await userDetails.get();
      if (snapshot.exists) {
        return user.User.fromJson(snapshot.data()!);
      }
    }
    return null;
  }

  Future<user.User?> getCurrentUserDetails() async {
    final authId = FirebaseAuth.instance.currentUser?.uid;
    if (authId != null) {
      final userData = await FirebaseFirestore.instance
          .collection(apiUsers)
          .where('authId', isEqualTo: authId)
          .get();

      // userData.docs.map((doc) {
      //   print('userdata---->${doc.data()}');
      //   return user.User.fromJson(
      //     doc.data(),
      //   );
      // }).toList();

      final userList = userData.docs
          .map(
            (doc) => user.User.fromJson(
              doc.data(),
            ),
          )
          .toList();
      if (userList.isNotEmpty) {
        return userList.first;
      }
    }
    return null;
  }

  // Future<String?> createFirebaseAuthUser(
  //     {required String email,
  //     required String password,
  //     required BuildContext context}) async {
  //   try {
  //     final authUser = await FirebaseAuth.instance
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //     return authUser.user!.uid;
  //   } catch (error) {
  //     rethrow;
  //   }
  // }

  Future<String?> createFirebaseAuthUserWithApi(
      {required String email,
      required String password,
      required BuildContext context}) async {
    String? userId;
    const String signupUrl =
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$webFireBaseApiKey';
    try {
      final response = await HttpRequest().postRequest(
        signupUrl,
        {
          'email': email,
          'password': password,
          // 'displayName': name,
          'returnSecureToken': 'true',
        },
        '',
        context: context,
      );

      final responseData = json.decode(response.body);
      // print(responseData);
      if (response.statusCode == 200) {
        userId = responseData['localId'];
      } else {
        throw HttpException(responseData['error']['message']);
      }
      return userId;
    } catch (error) {
      rethrow;
    }
  }

  Future<String?> createAppUser({required user.User userData}) async {
    try {
      final userInstance =
          FirebaseFirestore.instance.collection(apiUsers).doc();

      final appUser = user.User(
        id: userInstance.id,
        email: userData.email,
        fullName: userData.fullName,
        role: userData.role,
        mobile: userData.mobile,
        authId: userData.authId,
      );
      await userInstance.set(appUser.toJson());

      return userInstance.id;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> storeDeviceInfo({
    Map<String, dynamic>? deviceData,
    required String? userId,
  }) async {
    try {
      if (deviceData != null) {
        final firestoreInstance = FirebaseFirestore.instance;

        final dataInstance = await firestoreInstance
            .collection(apiDeviceInformation)
            .where('deviceId', isEqualTo: deviceData['id'])
            .where('userId', isEqualTo: userId)
            .get();
        final isEmpty = dataInstance.docs.isEmpty;

        if (isEmpty) {
          final firebaseToken = await FirebaseMessaging.instance.getToken();

          final deviceInfoInstance =
              firestoreInstance.collection(apiDeviceInformation).doc();
          final deviceInfo = DeviceInfo(
            id: deviceInfoInstance.id,
            userId: userId,
            deviceId: deviceData['id'],
            deviceModel: deviceData['model'],
            deviceOs: null,
            deviceOsVersion: deviceData['version']['release'],
            fcmToken: firebaseToken,
            sdkVersion: deviceData['version']['sdkInt'].toString(),
            manufacturer: deviceData['manufacturer'],
          );
          await deviceInfoInstance.set(deviceInfo.toJson());
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  // Future<PermissionData?> _getPermissionDetails(String? permissionId) async {
  //   print('permission id-->');
  //   print(permissionId);
  //   if (permissionId != null) {
  //     final permissionDetails = FirebaseFirestore.instance
  //         .collection(apiPermissions)
  //         .doc(permissionId);
  //     final snapshot = await permissionDetails.get();
  //     if (snapshot.exists) {
  //       return PermissionData.fromJson(snapshot.data()!);
  //     }
  //   }
  //   return null;
  // }

  Future<List<PermissionData>> getDefaultPermission(
      {required String userType}) async {
    List<String> permissionList = [
      appPermissionCallList,
      appPermissionServiceProvidersList,
      appPermissionTechnicianList
    ];

    final allPermissionList = await PermissionHelper().getAllPermissionList();
    if (userType == appRoleAdmin) {
      permissionList = [];
    } else if (userType == appRoleCustomer) {
      permissionList = [
        appPermissionCallList,
        appPermissionServiceProvidersList,
        appPermissionTechnicianList
      ];
    } else if (userType == appRoleTechnician) {
      permissionList = [
        appPermissionCallList,
        appPermissionCustomerList,
        appPermissionServiceProvidersList,
        appPermissionAddEditCall,
      ];
    } else if (userType == appRoleServiceProvider) {
      permissionList = [
        appPermissionCallList,
        appPermissionAddEditCustomer,
        appPermissionCustomerList,
        appPermissionTechnicianList,
        appPermissionAddEditCall,
        appPermissionAddressList,
        appPermissionAddEditAddress,
      ];
    }
    List<PermissionData> userPermissionList = [];
    for (var data in permissionList) {
      final permissionData = allPermissionList.firstWhere(
          (element) => element.name == data,
          orElse: () => PermissionData(
              id: null, parentId: null, name: null, label: null));
      if (permissionData.id != null) {
        userPermissionList.add(permissionData);
      }
    }

    return userPermissionList;
  }
}
