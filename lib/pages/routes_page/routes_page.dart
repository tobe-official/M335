import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:WalkeRoo/controller/route_controller.dart';
import 'package:WalkeRoo/models/map_model.dart';
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
    _routeController.loadRoutes().then((_) => setState(() {}));
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
            child: routes.isEmpty
                ? _noRoutesList()
                : ListView.builder(
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
                    'Steps: ${r.stepCount} | Time: $durationText',
                    style: const TextStyle(fontSize: 13),
                  ),
                  onTap: () => setState(() => _selectedRoute = r),
                );
              },
            ),
          ),

          Expanded(
            flex: 2,
            child: routes.isEmpty
                ? _noRoutesWidget()
                : _selectedRoute == null
                ? _chooseRouteWidget()
                : _routeMapWidget(),
          ),
        ],
      ),
    );
  }

  Widget _noRoutesList() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No routes stored.',
          style: TextStyle(fontSize: 18, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _noRoutesWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.route, size: 90, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No routes saved yet',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Start walking to save your first route.',
            style: TextStyle(fontSize: 16, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _chooseRouteWidget() {
    return const Center(
      child: Text(
        'Choose a route from the list',
        style: TextStyle(fontSize: 20, color: Colors.black54),
      ),
    );
  }

  Widget _routeMapWidget() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _selectedRoute!.points.first,
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate:
          'https://api.maptiler.com/maps/base-v4/{z}/{x}/{y}.png?key=qOEvgITUDNZbmeiArIhP',
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
        MarkerLayer(
          markers: _selectedRoute!.stopPoints.map((p) {
            return Marker(
              point: p,
              width: 20,
              height: 20,
              child: const Icon(
                Icons.circle,
                color: Colors.red,
                size: 14,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
