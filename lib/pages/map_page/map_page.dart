import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:m_335_flutter/global_widgets/custom_navigation_bar.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:m_335_flutter/controller/tracking_controller.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  static const mapTilerKey = '';
  static const _urlTemplate =
      'https://api.maptiler.com/maps/base-v4/{z}/{x}/{y}.png?key=$mapTilerKey';

  LatLng? _currentPosition;
  String _locationName = 'Loading location...';
  late final FMTCStore _store;

  final List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionStreamSub;
  bool _trackingActive = false;
  DateTime? _lastLocationUpdate;

  @override
  void initState() {
    super.initState();
    _store = FMTCStore('mapStore')..manage.create();
    _determinePosition();

    // every 0.1 seconds we track the position
    Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted && TrackingController().isTracking) setState(() {});
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationName = 'GPS blocked');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locationName = 'Location blocked');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationName = 'Location blocked');
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _updateLocation(position);
  }

  void _updateLocation(Position position) async {
    final latLng = LatLng(position.latitude, position.longitude);
    setState(() => _currentPosition = latLng);
    _mapController.move(latLng, 17);

    // all 10 seconds we update the "header" with the current location name
    if (_lastLocationUpdate == null ||
        DateTime.now().difference(_lastLocationUpdate!) > const Duration(seconds: 1)) {
      _lastLocationUpdate = DateTime.now();
      final placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        setState(() => _locationName = placemarks.first.locality ?? 'Unknown');
      }
    }
  }

  Future<void> startTracking() async {
    _routePoints.clear();
    _trackingActive = true;

    final settings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1, // every meter new "current location"
    );

    _positionStreamSub =
        Geolocator.getPositionStream(locationSettings: settings).listen((pos) {
          _updateLocation(pos);
        });
  }

  Future<void> stopTracking() async {
    _trackingActive = false;
    await _positionStreamSub?.cancel();
    _positionStreamSub = null;
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomNavigationBar(initialIndexOfScreen: 0),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? const LatLng(46.948, 7.4474),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: _urlTemplate,
                userAgentPackageName: 'ch.m335.walkeroo',
                tileProvider: _store.getTileProvider(),
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: Colors.blueAccent,
                      strokeWidth: 3,
                    ),
                  ],
                ),

              if (TrackingController().routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: TrackingController().routePoints,
                      color: Colors.blueAccent,
                      strokeWidth: 5,
                    ),
                  ],
                ),

              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location,
                          color: Colors.redAccent, size: 36),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Current location - $_locationName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}