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
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userService.getCurrentUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                  child: Text('No user data found', style: TextStyle(fontSize: 18)));
            }

            final userData = snapshot.data!.data()!;
            final totalSteps = userData['totalSteps'] ?? 0;
            final totalDistanceKm = userData['totalDistanceKm'] ?? 0.0;
            final walkingPace = userData['walkingPace'] ?? 0.0;
            final totalStepsWeek = userData['totalStepsWeek'] ?? 0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mo 27.01.25",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.signal_cellular_alt, size: 18),
                          SizedBox(width: 4),
                          Text("5G"),
                          SizedBox(width: 4),
                          Icon(Icons.battery_full, size: 20),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Here are your stats:",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const Divider(thickness: 1, height: 20),

                  const SizedBox(height: 20),

                  StatRow(label: "Total steps today:", value: "$totalSteps"),
                  StatRow(label: "Total steps last week:", value: "$totalStepsWeek"),
                  StatRow(label: "Walking pace (km/h):", value: "$walkingPace km/h"),
                  StatRow(label: "Total KM today:", value: "$totalDistanceKm KM"),

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
                          onPressed: () {
                            // TODO: Navigate to Saved Routes page
                          },
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

