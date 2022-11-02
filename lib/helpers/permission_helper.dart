import '../values/app_permissions.dart';
import '../values/static_values.dart';

import '../models/permission_data.dart';
import '../models/user.dart';
import '../models/user_permission.dart';

import '../values/api_end_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PermissionHelper {
  Stream<List<PermissionData>> getAllPermissionStream() {
    return FirebaseFirestore.instance
        .collection(apiPermissions)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PermissionData.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<List<PermissionData>> getAllPermissionList() async {
    final snapshot =
        FirebaseFirestore.instance.collection(apiPermissions).get();

    return snapshot.then((value) => value.docs
        .map(
          (doc) => PermissionData.fromJson(
            doc.data(),
          ),
        )
        .toList());
  }

  Future<PermissionData?> getPermissionDetails(String? permissionId) async {
    if (permissionId != null) {
      final permissionInstance = FirebaseFirestore.instance
          .collection(apiPermissions)
          .doc(permissionId);
      final snapshot = await permissionInstance.get();
      if (snapshot.exists) {
        return PermissionData.fromJson(snapshot.data()!);
      }
    }
    return null;
  }

  Future<List<PermissionData>> getAllUserPermissions(
      {required String? userId}) async {
    List<PermissionData> permissionList = [];

    final userPermissions = await FirebaseFirestore.instance
        .collection(apiUserPermissions)
        .where('userId', isEqualTo: userId)
        .get();
    for (var data in userPermissions.docs) {
      final permission = await PermissionHelper()
          .getPermissionDetails(data.data()['permissionId']);
      if (permission != null) {
        permissionList.add(permission);
      }
    }
    return permissionList;
  }

  Future<bool> updateUserPermissionList({
    required List<PermissionData> selectedPermissionList,
    required String userId,
  }) async {
    var status = false;

    final userPermissionList = await getAllUserPermissions(userId: userId);

    final List<PermissionData> commonList = [];
    final List<PermissionData> newList = [];
    bool checkContainsOrNot(
        List<PermissionData> permissionList, String serviceId) {
      return permissionList
                  .firstWhere((data) => data.id == serviceId,
                      orElse: () => PermissionData(
                            id: null,
                            parentId: null,
                            name: null,
                            label: null
                          ))
                  .id !=
              null
          ? true
          : false;
    }

    for (var i = 0; i < selectedPermissionList.length; i++) {
      final contains = checkContainsOrNot(
          userPermissionList, selectedPermissionList[i].id!);
      if (contains) {
        commonList.add(selectedPermissionList[i]);
      } else {
        newList.add(selectedPermissionList[i]);
      }
    }

    for (var i = 0; i < userPermissionList.length; i++) {
      final containsOld =
          checkContainsOrNot(commonList, userPermissionList[i].id!);

      if (!containsOld) {
        _deleteUserPermission(
          userId: userId,
          permissionId: userPermissionList[i].id!,
        );
      }
    }
    for (var i = 0; i < newList.length; i++) {
      _addUpdateUserPermission(
        userId: userId,
        permissionId: newList[i].id!,
        userPermissionId: null,
      );
    }
    return status;
  }

  Future<bool> _deleteUserPermission({
    required String userId,
    required String permissionId,
  }) async {
    var status = false;

    final callSevices = await FirebaseFirestore.instance
        .collection(apiUserPermissions)
        .where('userId', isEqualTo: userId)
        .where('permissionId', isEqualTo: permissionId)
        .get();

    await FirebaseFirestore.instance
        .collection(apiUserPermissions)
        .doc(callSevices.docs[0].id)
        .delete()
        .then((value) {
      status = true;
    });

    return status;
  }

  Future<bool> _addUpdateUserPermission(
      {required String userId,
      required String permissionId,
      required String? userPermissionId}) async {
    var status = false;
    final userPermissionInstance = FirebaseFirestore.instance
        .collection(apiUserPermissions)
        .doc(userPermissionId);

    final userPermissionData = UserPermission(
      id: userPermissionInstance.id,
      userId: userId,
      permissionId: permissionId,
    );
    await userPermissionInstance.set(userPermissionData.toJson()).then((value) {
      status = true;
    });
    return status;
  }

  // bool _checkPermissionContainsOrNot(
  //     List<PermissionData> permissionList, String permissionId) {
  //   return permissionList
  //               .firstWhere((data) => data.id == permissionId,
  //                   orElse: () => PermissionData(
  //                         id: null,
  //                         name: null,
  //                       ))
  //               .id !=
  //           null
  //       ? true
  //       : false;
  // }

  // bool validateUserPermission({
  //   required List<PermissionData> allPermissionList,
  //   required List<PermissionData> userPermissionList,
  // }) {
  //   var status = false;

  //   for (var i = 0; i < userPermissionList.length; i++) {
  //     final result = _checkPermissionContainsOrNot(
  //         allPermissionList, userPermissionList[i].id!);

  //     if (result) {
  //       status = true;
  //       return status;
  //     }
  //   }

  //   return status;
  // }

  bool validateUserPermission({
    required String permission,
    required List<PermissionData> userPermissionList,
    required User userData,
  }) {
    var status = false;
    if (userData.role == 'admin') {
      return true;
    }
    for (var i = 0; i < userPermissionList.length; i++) {
      // final conditionStatus = permission == userPermissionList[i].name;
      if (permission == userPermissionList[i].name) {
        status = true;
        return status;
      }
    }

    // if (userRole == roleList[0]) {
    //   status = true;
    // }
    return status;
  }

  Future<List<PermissionData>> getDefaultPermission(
      {required String userType}) async {
    final allPermissionList = await PermissionHelper().getAllPermissionList();
    List<PermissionData> userPermissionList = [];
    List<String> permissionList = [];
    if (userType == appRoleCustomer) {
      permissionList = [
        appPermissionCallList,
        appPermissionServiceProvidersList,
        appPermissionTechnicianList,
        appPermissionAddressList,
        appPermissionAddEditAddress,
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

    for (var data in permissionList) {
      final permissionData = allPermissionList.firstWhere(
          (element) => element.name == data,
          orElse: () => PermissionData(id: null, parentId: null, name: null,label: null));
      if (permissionData.id != null) {
        userPermissionList.add(permissionData);
      }
    }

    return userPermissionList;
  }
}
