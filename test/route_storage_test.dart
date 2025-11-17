import 'package:WalkeRoo/models/map_model.dart';
import 'package:flutter_test/flutter_test.dart';

class MockRouteStorage {
  final List<RouteModel> saved = [];

  Future<void> save(RouteModel route) async {
    saved.add(route);
  }

  Future<List<RouteModel>> getAll() async {
    return saved;
  }

  Future<void> clear() async {
    saved.clear();
  }
}

void main() {
  group('MockRouteStorage', () {
    late MockRouteStorage storage;

    setUp(() {
      storage = MockRouteStorage();
    });

    test('multiple routes are saved independently', () async {
      final r1 = RouteModel(
        id: 'r1',
        username: 'u1',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        stepCount: 100,
        points: [],
        stopPoints: [],
      );

      final r2 = RouteModel(
        id: 'r2',
        username: 'u2',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        stepCount: 200,
        points: [],
        stopPoints: [],
      );

      await storage.save(r1);
      await storage.save(r2);

      final all = await storage.getAll();

      expect(all.length, 2);
      expect(all.map((e) => e.id), containsAll(['r1', 'r2']));
    });

    test('clear removes all routes', () async {
      await storage.save(RouteModel(
        id: 'test',
        username: 'x',
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        stepCount: 5,
        points: [],
        stopPoints: [],
      ));

      await storage.clear();
      final all = await storage.getAll();

      expect(all.isEmpty, true);
    });
  });
}