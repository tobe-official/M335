import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:m_335_flutter/models/map_model.dart';

class RouteController {
  static final RouteController _instance = RouteController._internal();
  factory RouteController() => _instance;
  RouteController._internal();

  final List<RouteModel> _routes = [];

  List<RouteModel> get allRoutes => List.unmodifiable(_routes);

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/routes.json');
  }

  Future<void> loadRoutes() async {
    final file = await _getFile();
    if (!await file.exists()) return;

    final jsonData = json.decode(await file.readAsString()) as List;
    _routes
      ..clear()
      ..addAll(jsonData.map((e) => RouteModel.fromJson(e)));
  }

  Future<void> saveRoutes() async {
    final file = await _getFile();
    final jsonData = json.encode(_routes.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonData);
  }

  Future<void> addRoute({
    required List<LatLng> points,
    required int stepDiff,
    required DateTime start,
    required DateTime end,
  }) async {
    final route = RouteModel(
      id: DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      startTime: start,
      endTime: end,
      stepCount: stepDiff,
      points: points,
    );

    if (isValidRoute(route)) {
      _routes.add(route);
    await saveRoutes();
  } else {
      print('Invalid Route. Won`t be saved.');
    }
}

  Future<void> deleteRoute(String id) async {
    _routes.removeWhere((r) => r.id == id);
    await saveRoutes();
  }

  bool isValidRoute(RouteModel route) {
    final duration = route.endTime.difference(route.startTime);
    return route.points.isEmpty && route.startTime.isBefore(route.endTime) && route.stepCount < 0 && duration.inMinutes < 1;
  }
}