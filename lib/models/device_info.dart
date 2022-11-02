class DeviceInfo {
  String? id;
  final String? userId;
  final String? deviceId;
  final String? deviceModel;
  final String? fcmToken;
  final String? deviceOs;
  final String? deviceOsVersion;
  final String? sdkVersion;
  final String? manufacturer;

  DeviceInfo({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.deviceModel,
    required this.deviceOs,
    required this.deviceOsVersion,
    required this.fcmToken,
    this.manufacturer,
    this.sdkVersion,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'deviceId': deviceId,
        'deviceModel': deviceModel,
        'deviceOs': deviceOs,
        'deviceOsVersion': deviceOsVersion,
        'fcmToken': fcmToken,
        'manufacturer': manufacturer,
        'sdkVersion': sdkVersion,
      };

  static DeviceInfo fromJson(Map<String, dynamic> json) => DeviceInfo(
        id: json['id'],
        userId: json['userId'],
        deviceId: json['deviceId'],
        deviceModel: json['deviceModel'],
        deviceOs: json['deviceOs'],
        deviceOsVersion: json['deviceOsVersion'],
        fcmToken: json['fcmToken'],
        manufacturer: json['manufacturer'],
        sdkVersion: json['sdkVersion'],
      );
}
