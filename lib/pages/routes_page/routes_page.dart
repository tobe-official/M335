import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:m_335_flutter/controller/route_controller.dart';
import 'package:m_335_flutter/models/map_model.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final _routeController = RouteController();
  RouteModel? _selectedRoute;
  late final FMTCStore _store;

  @override
  void initState() {
    super.initState();
    _store = FMTCStore('mapStore')..manage.create();
    RouteController().loadRoutes();
  }

  @override
  Widget build(BuildContext context) {
    final routes = _routeController.allRoutes;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Routes')),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, i) {
                final r = routes[i];
                final duration = r.endTime.difference(r.startTime);
                final durationText =
                    '${duration.inMinutes} min ${duration.inSeconds % 60}s';

                return ListTile(
                  title: Text(
                    'Route ${i + 1}\n${r.startTime.toLocal().toString().substring(0, 16)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Steps: ${r.stepCount} | Dauer: $durationText',
                    style: const TextStyle(fontSize: 13),
                  ),
                  onTap: () => setState(() => _selectedRoute = r),
                );
              },
            ),
          ),

          Expanded(
            flex: 2,
            child: _selectedRoute == null || !RouteController().isValidRoute(_selectedRoute!)
                ? const Center(child: Text('Choose a route to display'))
                : FlutterMap(
              options: MapOptions(
                initialCenter: _selectedRoute!.points.first,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://api.maptiler.com/maps/base-v4/{z}/{x}/{y}.png?key=1gzJrHLaOPeEElnmEFEe',
                  userAgentPackageName: 'ch.m335.walkeroo',
                  tileProvider: _store.getTileProvider(),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _selectedRoute!.points,
                      color: Colors.blueAccent,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
