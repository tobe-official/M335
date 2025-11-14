import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:m_335_flutter/pages/home_page/home_page_steps_stream.dart';

class TrackingController {
  late HomePageStepsStream stepsStream;

  static final TrackingController _instance = TrackingController._internal();
  factory TrackingController() => _instance;
  TrackingController._internal();

  final List<LatLng> _routePoints = [];
  final List<LatLng> _stopPoints = [];
  StreamSubscription<Position>? _positionSub;
  DateTime? _lastMovementTime;

  DateTime? _trackingStartTime;
  DateTime? _trackingEndTime;
  int? _startSteps;
  int? _endSteps;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  List<LatLng> get routePoints => List.unmodifiable(_routePoints);
  List<LatLng> get stopPoints  => List.unmodifiable(_stopPoints);

  void attachStepsStream(HomePageStepsStream stream) {
    stepsStream = stream;
  }

  Future<void> startTracking(int startSteps) async {
    if (_isTracking) return;
    _isTracking = true;

    _routePoints.clear();
    _stopPoints.clear();
    recordStartSteps(startSteps);
    _trackingStartTime = DateTime.now();
    _lastMovementTime = DateTime.now();

    final settings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _positionSub =
        Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
          final point = LatLng(pos.latitude, pos.longitude);
          _routePoints.add(point);

          _lastMovementTime = DateTime.now();
        });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      if (_lastMovementTime != null) {
        final diff = DateTime.now().difference(_lastMovementTime!);

        // if 15 seconds standing still AND status ist stopped-> red dot
        if (diff.inSeconds >= 5 && stepsStream.currentStatus == 'stopped') {
          if (_routePoints.isNotEmpty) {
            final lastPos = _routePoints.last;
              _stopPoints.add(lastPos);
          }

          _lastMovementTime = DateTime.now();
        }
      }
    });
  }

  Future<void> stopTracking(int endSteps) async {
    recordEndSteps(endSteps);
    _trackingEndTime = DateTime.now();

    if (!_isTracking) return;
    _isTracking = false;
    await _positionSub?.cancel();
    _positionSub = null;
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
