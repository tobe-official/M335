import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';


class FakePersonalStatsPage extends StatelessWidget {
  const FakePersonalStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFD2D2D2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // HEADER
              const Text(
                "Here are your stats:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const Divider(thickness: 1, height: 20),
              const SizedBox(height: 20),

              // STATS
              const _FakeStatRow(label: "Total steps today:", value: "5432"),
              const _FakeStatRow(label: "Total steps last week:", value: "30021"),
              const _FakeStatRow(label: "Walking pace (km/h):", value: "4.23"),
              const _FakeStatRow(label: "Total KM today:", value: "3.80 KM"),

              const Spacer(),

              // BUTTON
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "See Saved Routes",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FakeStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _FakeStatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens("PersonalStats Fake Snapshot", (tester) async {
    await tester.pumpWidgetBuilder(
      const FakePersonalStatsPage(),
      surfaceSize: const Size(390, 844),
    );

    await tester.pumpAndSettle();

    await screenMatchesGolden(tester, "personal_stats_page_fake");
  });
}
