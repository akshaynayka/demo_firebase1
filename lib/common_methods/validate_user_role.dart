bool validateUserRole({
  required String userRole,
  required List<String> roleList,
}) {
  var status = false;

  for (var i = 0; i < roleList.length; i++) {
    final conditionStatus = userRole == roleList[i];
    if (conditionStatus == true) {
      status = true;
      return status;
    }
  }

  // if (userRole == roleList[0]) {
  //   status = true;
  // }
  return status;
}

