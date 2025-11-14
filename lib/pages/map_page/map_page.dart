import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:WalkeRoo/global_widgets/custom_navigation_bar.dart';
import 'package:WalkeRoo/controller/tracking_controller.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  static const mapTilerKey = '';
  static const _urlTemplate = 'https://api.maptiler.com/maps/base-v4/{z}/{x}/{y}.png?key=$mapTilerKey';

  LatLng? _currentPosition;
  String _locationName = 'Loading location...';

  late final FMTCStore _store;

  StreamSubscription<Position>? _positionStreamSub;
  DateTime? _lastLocationUpdate;

  @override
  void initState() {
    super.initState();
    _store = FMTCStore('mapStore')..manage.create();

    _init();
  }

  Future<void> _init() async {
    final ok = await _ensureLocationPermission();
    if (!ok) {
      setState(() => _locationName = "Location permission required");
      return;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    _updateLocation(pos);

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 3),
    ).listen(_updateLocation);
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() => _locationName = 'Enable GPS');
      await Geolocator.openLocationSettings();
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      setState(() => _locationName = 'Location denied');
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationName = 'Open settings to enable location');
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  void _updateLocation(Position pos) async {
    final latLng = LatLng(pos.latitude, pos.longitude);

    setState(() => _currentPosition = latLng);
    _mapController.move(latLng, 17);

    if (_lastLocationUpdate == null || DateTime.now().difference(_lastLocationUpdate!) > const Duration(seconds: 1)) {
      _lastLocationUpdate = DateTime.now();

      final place = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

      if (place.isNotEmpty) {
        setState(() => _locationName = place.first.locality ?? "Unknown");
      }
    }
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
              initialCenter: _currentPosition ?? const LatLng(46.948, 7.4474), // Bern
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: _urlTemplate,
                userAgentPackageName: 'ch.m335.walkeroo',
                tileProvider: _store.getTileProvider(),
              ),

              if (TrackingController().routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(points: TrackingController().routePoints, color: Colors.blueAccent, strokeWidth: 5),
                  ],
                ),

              if (TrackingController().stopPoints.isNotEmpty)
                MarkerLayer(
                  markers:
                      TrackingController().stopPoints
                          .map(
                            (p) => Marker(
                              point: p,
                              width: 20,
                              height: 20,
                              child: const Icon(Icons.circle, color: Colors.red, size: 14),
                            ),
                          )
                          .toList(),
                ),

              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location, color: Colors.redAccent, size: 36),
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
                'Current location – $_locationName',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
