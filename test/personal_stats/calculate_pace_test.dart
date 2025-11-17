import 'package:flutter_test/flutter_test.dart';
import 'package:WalkeRoo/pages/personal_stats_page/stats_calculations.dart';

void main() {
  group("calculatePaceKmH()", () {
    test("Positive: pace is calculated correctly", () {
      final kmh = calculatePaceKmH(4.0, 60);
      expect(kmh, 4.0);
    });

    test("Negative: zero minutes returns 0", () {
      final kmh = calculatePaceKmH(3.0, 0);
      expect(kmh, 0);
    });
  });
}
