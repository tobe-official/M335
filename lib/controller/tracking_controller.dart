import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class TrackingController {
  static final TrackingController _instance = TrackingController._internal();
  factory TrackingController() => _instance;
  TrackingController._internal();

  final List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionStreamSub;
  DateTime? _trackingStartTime;
  DateTime? _trackingEndTime;
  int? _startSteps;
  int? _endSteps;
  bool _isTracking = false;
  bool get isTracking => _isTracking;
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);

  Future<void> startTracking(int startSteps) async {
    if (_isTracking) return;
    _isTracking = true;
    _routePoints.clear();
    recordStartSteps(startSteps);
    _trackingStartTime = DateTime.now();

    final settings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _positionStreamSub =
        Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
          _routePoints.add(LatLng(pos.latitude, pos.longitude));
        });
  }

  Future<void> stopTracking(int endSteps) async {
    recordEndSteps(endSteps);
    _trackingEndTime = DateTime.now();

    if (!_isTracking) return;
    _isTracking = false;
    await _positionStreamSub?.cancel();
    _positionStreamSub = null;
  }

  List<DateTime?> getLastTrackingTimes() {
    return [_trackingStartTime, _trackingEndTime];
  }

  void recordStartSteps(int steps) {
    _startSteps = steps;
  }

  void recordEndSteps(int steps) {
    _endSteps = steps;
  }

  int getLastStepsDifference() {
    if (_startSteps == null || _endSteps == null) return 0;
    return (_endSteps! - _startSteps!).clamp(0, 999999);
  }
}
