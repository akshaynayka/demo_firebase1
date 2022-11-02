import 'package:flutter/material.dart';

class CallTimeLog with ChangeNotifier {
  String? id;
  String? callId;
  String? clockInTime;
  String? clockOutTime;
  String? clockInLatitude;
  String? clockInLongitude;
  String? clockOutLatitude;
  String? clockOutLongitude;

  CallTimeLog({
    required this.id,
    required this.callId,
    required this.clockInTime,
    required this.clockOutTime,
    required this.clockInLatitude,
    required this.clockInLongitude,
    required this.clockOutLatitude,
    required this.clockOutLongitude,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'callId': callId,
        'clockInTime': clockInTime,
        'clockOutTime': clockOutTime,
        'clockInLatitude': clockInLatitude,
        'clockInLongitude': clockInLongitude,
        'clockOutLatitude': clockOutLatitude,
        'clockOutLongitude': clockOutLongitude,
      };

  static CallTimeLog fromJson(Map<String, dynamic> json) => CallTimeLog(
        id: json['id'],
        callId: json['callId'],
        clockInTime: json['clockInTime'],
        clockOutTime: json['clockOutTime'],
        clockInLatitude: json['clockInLatitude'],
        clockInLongitude: json['clockInLongitude'],
        clockOutLatitude: json['clockOutLatitude'],
        clockOutLongitude: json['clockOutLongitude'],
      );
}
