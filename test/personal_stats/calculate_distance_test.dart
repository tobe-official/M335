import 'package:WalkeRoo/pages/personal_stats_page/stats_calculations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("calculateDistanceKm()", () {
    test("Positive: distance is correctly calculated", () {
      final km = calculateDistanceKm(5000, 0.78);
      expect(km.toStringAsFixed(2), "3.90");
    });

    test("Negative: invalid input returns 0", () {
      final km = calculateDistanceKm(-10, 0.78);
      expect(km, 0);
    });
  });
}
