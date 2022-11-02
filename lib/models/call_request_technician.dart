class CallRequestTechnician {
  String? id;
  final String? technicianId;
  String? serviceProviderId;
  String? status;
  String? oldStatus;
  final String? callRequestId;

  CallRequestTechnician({
    required this.id,
    required this.technicianId,
    this.serviceProviderId,
    required this.callRequestId,
    required this.status,
    required this.oldStatus,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'technicianId': technicianId,
        'callRequestId': callRequestId,
        'status': status,
        'oldStatus': oldStatus,
        'serviceProviderId': serviceProviderId,
      };

  static CallRequestTechnician fromJson(Map<String, dynamic> json) =>
      CallRequestTechnician(
        id: json['id'],
        technicianId: json['technicianId'],
        callRequestId: json['callRequestId'],
        status: json['status'],
        oldStatus: json['oldStatus'],
        serviceProviderId: json['serviceProviderId'],
      );
}
