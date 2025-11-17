import 'package:WalkeRoo/models/map_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:latlong2/latlong.dart';

class FakeFlutterMap extends StatelessWidget {
  const FakeFlutterMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      height: 800,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Text('MAP PLACEHOLDER', style: TextStyle(color: Colors.black54)),
    );
  }
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('RoutesPage snapshot with one selected route', (tester) async {
    RouteModel(
      id: 'r1',
      username: 'tester',
      startTime: DateTime(2024, 1, 1, 12, 00),
      endTime: DateTime(2024, 1, 1, 12, 30),
      stepCount: 1200,
      points: [LatLng(46.95, 7.44), LatLng(46.96, 7.45)],
      stopPoints: [LatLng(46.95, 7.44)],
    );

    final widgetUnderTest = MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: ListView(
                children: [ListTile(title: const Text('Route 1'), subtitle: const Text('Steps: 1200 | Time: 30 min'))],
              ),
            ),

            const Expanded(flex: 2, child: FakeFlutterMap()),
          ],
        ),
      ),
    );

    await tester.pumpWidgetBuilder(widgetUnderTest, surfaceSize: const Size(900, 600));

    await screenMatchesGolden(tester, 'routes_page_snapshot');
  });
}
