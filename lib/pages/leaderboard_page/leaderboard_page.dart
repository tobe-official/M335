import 'package:flutter/material.dart';
import 'package:WalkeRoo/global_widgets/custom_navigation_bar.dart';

import '../../data_fetching/friends_service.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDADADA),
      body: _body(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDADADA),
        elevation: 0,
          leading: IconButton(
            onPressed: () => _onNotification(context),
            icon: const Icon(Icons.mail_outline),
          ),
          actions: [
            IconButton(
              onPressed: () => _onAddFriends(context),
              icon: const Icon(Icons.person_add_alt_1),
            )
          ]
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
                  margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
                  decoration: BoxDecoration(
                    color: isHighlighted ? const Color(0xFFB9E2A5) : const Color(0xFFFFFCD6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Text('${index + 1}.', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Text(item['distance']!, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  void _onAddFriends(BuildContext context) {
    String username = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Friend"),
          content: TextField(
            decoration: const InputDecoration(hintText: "Enter username"),
            onChanged: (v) => username = v.trim(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FriendsService().sendFriendRequest(username);
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }


  void _onNotification(BuildContext context) async {
    final requests = await FriendsService().getFriendRequests();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Friend Requests"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: requests.isEmpty
                ? const Center(child: Text("No requests"))
                : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (c, i) {
                final r = requests[i];
                return ListTile(
                  title: Text(r['fromUsername']),
                  trailing: TextButton(
                    child: const Text("Accept"),
                    onPressed: () async {
                      await FriendsService()
                          .acceptFriendRequest(r['id'], r['fromUid']);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }


}
