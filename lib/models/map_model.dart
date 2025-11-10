import 'package:latlong2/latlong.dart';

class RouteModel {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int stepCount;
  final List<LatLng> points;

  RouteModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.stepCount,
    required this.points,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'stepCount': stepCount,
    'points': points
        .map((p) => {'lat': p.latitude, 'lng': p.longitude})
        .toList(),
  };

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
    id: json['id'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    stepCount: json['stepCount'] ?? 0,
    points: (json['points'] as List)
        .map((p) => LatLng(p['lat'], p['lng']))
        .toList(),
  );
}
