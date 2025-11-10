import 'package:flutter/material.dart';
import 'package:m_335_flutter/global_widgets/custom_navigation_bar.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDEB),
      body: _body(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFDEB),
        elevation: 0,
        leading:IconButton(
            onPressed: _onNotification,
            icon: const Icon(Icons.mail_outline, color: Colors.black, size: 30),
            tooltip: 'Friend Requests',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6, right: 10),
            child: IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Colors.black, size: 30),
              onPressed: _onAddFriends,
              tooltip: 'Add Friend',
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(initialIndexOfScreen: 3),
    );
  }

  Widget _body() {
    final leaderboard = [
      {'name': 'Jana L.', 'distance': '23km'},
      {'name': 'Jona P.', 'distance': '22km'},
      {'name': 'Jano W.', 'distance': '21km'},
      {'name': 'Jona P.', 'distance': '20km'},
      {'name': 'Jonas D.', 'distance': '19km'},
      {'name': 'Lina P.', 'distance': '18km'},
    ];
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Icon(Icons.emoji_events, size: 80, color: Colors.black),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final item = leaderboard[index];
                final isHighlighted = index == 3;
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isHighlighted
                            ? const Color(0xFFB9E2A5)
                            : const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Text(
                      '${index + 1}.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    title: Text(
                      item['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      item['distance']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 10),
          const Text(
            'This is the leaderboard of the last 7 Days',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }


  void _onAddFriends() {}

  void _onNotification() {}
}
