class ServiceProviderTechnicianRequest {
  String? id;
  String? requestedBy;
  String? serviceProviderId;
  String? technicianId;
  String? status;

  ServiceProviderTechnicianRequest({
    required this.id,
    required this.requestedBy,
    required this.serviceProviderId,
    required this.technicianId,
    required this.status,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'requestedBy': requestedBy,
        'serviceProviderId': serviceProviderId,
        'technicianId': technicianId,
        'status': status,
      };

  static ServiceProviderTechnicianRequest fromJson(Map<String, dynamic> json) =>
      ServiceProviderTechnicianRequest(
        id: json['id'],
        requestedBy: json['requestedBy'],
        serviceProviderId: json['serviceProviderId'],
        technicianId: json['technicianId'],
        status: json['status'],
      );
}
