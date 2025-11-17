import 'package:WalkeRoo/pages/personal_stats_page/statRow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:WalkeRoo/global_widgets/custom_navigation_bar.dart';
import 'package:WalkeRoo/controller/route_controller.dart';
import 'package:WalkeRoo/pages/routes_page/routes_page.dart';
import 'package:WalkeRoo/data_fetching/user_service.dart';

class PersonalStatsPage extends StatefulWidget {
  const PersonalStatsPage({super.key});

  @override
  State<PersonalStatsPage> createState() => _PersonalStatsPageState();
}

class _PersonalStatsPageState extends State<PersonalStatsPage> {
  final _routeController = RouteController();
  bool _isLoading = false;

  Future<void> _openRoutesPage(BuildContext context) async {
    setState(() => _isLoading = true);
    await _routeController.loadRoutes();
    setState(() => _isLoading = false);

    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const RoutesPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFD2D2D2),
      body: _body(),
      bottomNavigationBar: CustomNavigationBar(initialIndexOfScreen: 1),
    );
  }

  Widget _body() {
    final userService = UserService();

    return SafeArea(
      child: FutureBuilder(
        future: Future.wait([
          userService.getCurrentUserProfile().first,
          userService.getTotalStepsLast7Days(),
          _routeController.loadRoutes(),
        ]),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userSnap = snapshot.data![0] as DocumentSnapshot<Map<String, dynamic>>;
          final totalStepsWeek = snapshot.data![1] as int;

          if (!userSnap.exists) {
            return const Center(child: Text('No user data found', style: TextStyle(fontSize: 18)));
          }

          final userData = userSnap.data()!;
          final totalStepsToday = userData['totalSteps'] ?? 0;

          const double averageStepLengthMeters = 0.78;
          double totalDistanceKmToday = (totalStepsToday * averageStepLengthMeters) / 1000;

          final routesToday = _routeController.getRoutesFromToday();
          final totalMinutesToday = _routeController.getTotalMinutesFromToday();

          double kmTodayFromRoutes = 0;

          for (var r in routesToday) {
            kmTodayFromRoutes += (r.stepCount * averageStepLengthMeters) / 1000;
          }

          double paceKmPerHour = totalMinutesToday > 0 ? kmTodayFromRoutes / (totalMinutesToday / 60) : 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text("Here are your stats:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                const Divider(thickness: 1, height: 20),
                const SizedBox(height: 20),

                StatRow(label: "Total steps today:", value: "$totalStepsToday"),
                StatRow(label: "Total steps last week:", value: "$totalStepsWeek"),
                StatRow(label: "Walking pace (km/h):", value: paceKmPerHour.toStringAsFixed(2)),
                StatRow(label: "Total KM today:", value: "${totalDistanceKmToday.toStringAsFixed(2)} KM"),

                const Spacer(),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        onPressed: () {
                          _openRoutesPage(context);
                        },
                        child: const Text(
                          "See Saved Routes",
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
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
