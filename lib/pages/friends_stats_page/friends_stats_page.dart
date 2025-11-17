import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data_fetching/user_service.dart';
import '../../controller/route_controller.dart';


class FriendsStatsPage extends StatefulWidget {
  final String userId;

  const FriendsStatsPage({required this.userId, super.key});

  @override
  State<FriendsStatsPage> createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<FriendsStatsPage> {
  final _routeController = RouteController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFD2D2D2),
      appBar: AppBar(
        title: const Text("User Stats"),
        backgroundColor: Color(0XFFD2D2D2),
        elevation: 0,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final firestore = FirebaseFirestore.instance;

    return FutureBuilder(
      future: Future.wait([
        firestore.collection('users').doc(widget.userId).get(),
        UserService().getStepsLast7DaysFor(widget.userId),
        UserService().getStepsTodayFor(widget.userId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userDoc = snapshot.data![0] as DocumentSnapshot<
            Map<String, dynamic>>;
        final steps7Days = snapshot.data![1] as int;

        final user = userDoc.data()!;
        final username = user['username'];
        final todaySteps = snapshot.data![2] as int;

        const stepLength = 0.78;
        final kmToday = (todaySteps * stepLength) / 1000;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username, style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Divider(),

              const SizedBox(height: 20),
              _stat("Steps today", "$todaySteps"),
              _stat("Steps last 7 days", "$steps7Days"),
              _stat("Distance today", "${kmToday.toStringAsFixed(2)} km"),

              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget _stat(String label, String value) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(value, style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}