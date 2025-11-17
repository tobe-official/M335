import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:WalkeRoo/models/map_model.dart';
import '../singletons/active_user_singleton.dart';

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
      ..addAll(
        jsonData
            .map((e) => RouteModel.fromJson(e))
            .where((route) => route.username == (ActiveUserSingleton().activeUser?.username ?? "offline")),
      );
  }

  Future<void> saveRoutes() async {
    final file = await _getFile();
    final jsonData = json.encode(_routes.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonData);
  }

  Future<void> addRoute({
    required List<LatLng> points,
    required List<LatLng> stopPoints,
    required int stepDiff,
    required DateTime start,
    required DateTime end,
  }) async {
    final username = ActiveUserSingleton().activeUser?.username ?? "offline";

    final route = RouteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      startTime: start,
      endTime: end,
      stepCount: stepDiff,
      points: points,
      stopPoints: stopPoints,
    );

    if (isValidRoute(route)) {
      _routes.add(route);
      await saveRoutes();
    } else {
      print(route.stepCount);
      print(route.points.toString());
      print(route.stopPoints.toString());
      print('Invalid Route. Won`t be saved.');
    }
  }

  Future<void> deleteRoute(String id) async {
    _routes.removeWhere((r) => r.id == id);
    await saveRoutes();
  }

  bool isValidRoute(RouteModel route) {
    final duration = route.endTime.difference(route.startTime);
    return route.startTime.isBefore(route.endTime) && route.stepCount > 0 && duration.inSeconds > 60;
  }

  List<RouteModel> getRoutesFromToday() {
    final now = DateTime.now();
    return _routes
        .where((r) => r.startTime.year == now.year && r.startTime.month == now.month && r.startTime.day == now.day)
        .toList();
  }

  int getTotalMinutesFromToday() {
    final routes = getRoutesFromToday();
    int minutes = 0;

    for (var r in routes) {
      minutes += r.endTime.difference(r.startTime).inMinutes;
    }

    return minutes;
  }
}
