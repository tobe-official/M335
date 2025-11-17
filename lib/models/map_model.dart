import 'package:latlong2/latlong.dart';

class RouteModel {
  final String id;
  final String username;
  final DateTime startTime;
  final DateTime endTime;
  final int stepCount;
  final List<LatLng> points;
  final List<LatLng> stopPoints;

  RouteModel({
    required this.id,
    required this.username,
    required this.startTime,
    required this.endTime,
    required this.stepCount,
    required this.points,
    required this.stopPoints,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'stepCount': stepCount,
    'points': points
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList(),
    'stopPoints': stopPoints
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList(),
  };

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
    id: json['id'],
    username: json['username'] ?? '',
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    stepCount: json['stepCount'] ?? 0,
    points: (json['points'] as List)
        .map((p) => LatLng(p['lat'], p['lng']))
        .toList(),
   stopPoints: (json['stopPoints'] as List? ?? [])
      .map((e) => LatLng(e['lat'], e['lng']))
      .toList()
  );
}
