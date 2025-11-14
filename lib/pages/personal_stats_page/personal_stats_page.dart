import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:m_335_flutter/data_fetching/user_service.dart';
import 'package:m_335_flutter/global_widgets/custom_navigation_bar.dart';
import 'package:m_335_flutter/pages/personal_stats_page/statRow.dart';

class PersonalStatsPage extends StatelessWidget {
  const PersonalStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFD2D2D2),
        body: _body(),
        bottomNavigationBar: CustomNavigationBar(initialIndexOfScreen: 1));
  }

  Widget _body() {
    final userService = UserService();

    return SafeArea(
      child: FutureBuilder(
        future: Future.wait([
          userService.getCurrentUserProfile().first,
          userService.getTotalStepsLast7Days(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userSnap = snapshot.data![0] as DocumentSnapshot<Map<String, dynamic>>;
          final totalStepsWeek = snapshot.data![1] as int;

          if (!userSnap.exists) {
            return const Center(
              child: Text('No user data found', style: TextStyle(fontSize: 18)),
            );
          }

          final userData = userSnap.data()!;
          final totalStepsToday = userData['totalSteps'] ?? 0;

          const double averageStepLengthMeters = 0.78;
          double totalDistanceKmToday =
              (totalStepsToday * averageStepLengthMeters) / 1000;

          double distanceWeekKm =
              (totalStepsWeek * averageStepLengthMeters) / 1000;

          double walkingPaceKmPerDay = distanceWeekKm / 7.0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text(
                  "Here are your stats:",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const Divider(thickness: 1, height: 20),
                const SizedBox(height: 20),

                StatRow(label: "Total steps today:", value: "$totalStepsToday"),
                StatRow(label: "Total steps last week:", value: "$totalStepsWeek"),
                StatRow(label: "Walking pace (km/day):",
                    value: walkingPaceKmPerDay.toStringAsFixed(2)),
                StatRow(label: "Total KM today:",
                    value: "${totalDistanceKmToday.toStringAsFixed(2)} KM"),

                const Spacer(),

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
          );
        },
      ),
    );
  }

}

