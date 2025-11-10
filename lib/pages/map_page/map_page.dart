import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:m_335_flutter/global_widgets/custom_navigation_bar.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  static const mapTilerKey = 'YOUR_MAPTILER_KEY';
  static const _urlTemplate =
      'https://api.maptiler.com/maps/darkmatter/{z}/{x}/{y}.png?key=$mapTilerKey';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomNavigationBar(initialIndexOfScreen: 0),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(46.948, 7.4474),
              initialZoom: 13,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate: _urlTemplate,
                userAgentPackageName: 'ch.m335.walkeroo',
                tileProvider: NetworkTileProvider(),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
                border: Border.all(color: Colors.white12),
              ),
              child: const Text(
                'Kartenansicht',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(
                Icons.my_location,
                size: 56,
                color: Colors.white38,
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Kartenquelle: MapTiler / OpenStreetMap contributors',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
