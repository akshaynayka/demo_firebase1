import 'package:flutter/material.dart';
import '../helpers/customers_helper.dart';
import '../helpers/service_provider_helper.dart';
import '../helpers/technician_helper.dart';
import '../values/static_values.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  String? _currentTechnicianId;
  String? _currentCustomerId;
  String? _currentServiceProviderId;
  User? get currentUser {
    if (_currentUser != null) {
      return _currentUser;
    }
    return null;
  }

  String? get currentTechnicianId {
    if (_currentTechnicianId != null) {
      return _currentTechnicianId;
    }
    return null;
  }

  String? get currentServiceProviderId {
    if (_currentServiceProviderId != null) {
      return _currentServiceProviderId;
    }
    return null;
  }

  String? get currentCustomer {
    if (_currentCustomerId != null) {
      return _currentCustomerId;
    }
    return null;
  }

  Future<void> setCurrentUser({required User? userData}) async {
    // print('execute set user data method--->');

    _currentUser = userData;

    if (userData!.role == appRoleTechnician) {
      final technicianDetails =
          await TechnicianHelper().getTechnicianDetailsByUserId(userData.id);
      // print('calling TechnicianHelper --->');

      // print('${technicianDetails!.toJson()}');
      _currentTechnicianId = technicianDetails!.id;
    } else if (userData.role == appRoleServiceProvider) {
      final serviceProviderDetails = await ServiceProviderHelper()
          .getServiceProviderDetailsByUserId(userData.id);
      _currentServiceProviderId = serviceProviderDetails!.id;
    } else if (userData.role == appRoleCustomer) {
      final customerDetails =
          await CustomersHelper().getCustomerDetailsByUserId(userData.id);
      _currentCustomerId = customerDetails!.id;
    }
    notifyListeners();
  }
}
