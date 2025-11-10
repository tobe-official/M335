import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class TrackingController {
  static final TrackingController _instance = TrackingController._internal();
  factory TrackingController() => _instance;
  TrackingController._internal();

  final List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => List.unmodifiable(_routePoints);

  StreamSubscription<Position>? _positionSub;
  bool _tracking = false;

  bool get isTracking => _tracking;

  Future<void> start() async {
    if (_tracking) return;
    _tracking = true;
    _routePoints.clear();

    final settings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      _routePoints.add(LatLng(pos.latitude, pos.longitude));
    });
  }

  Future<void> stop() async {
    _tracking = false;
    await _positionSub?.cancel();
    _positionSub = null;
  }

  void dispose() {
    _positionSub?.cancel();
  }
}
