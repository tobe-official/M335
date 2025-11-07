import 'package:flutter/material.dart';
import 'package:m_335_flutter/pages/home_page/home_page.dart';
import 'package:m_335_flutter/pages/leaderboard_page/leaderboard_page.dart';
import 'package:m_335_flutter/pages/map_page/map_page.dart';
import 'package:m_335_flutter/pages/personal_stats_page/personal_stats_page.dart';
import 'package:m_335_flutter/pages/profile_page/profile_page.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key, required this.initialIndexOfScreen});

  final int? initialIndexOfScreen;

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int? _currentIndex;
  bool isHome = false;
  bool isMap = false;
  bool isLeaderboard = false;
  bool isPersonalStats = false;
  bool isProfile = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndexOfScreen;

    switch (_currentIndex) {
      case 0:
        isMap = true;
        break;
      case 1:
        isPersonalStats = true;
        break;
      case 2:
        isHome = true;
        break;
      case 3:
        isLeaderboard = true;
        break;
      case 4:
        isProfile = true;
        break;
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _currentIndex = index;
    });

    Widget? screen;

    switch (index) {
      case 0:
        screen = const MapPage();
        break;
      case 1:
        screen = const PersonalStatsPage();
        break;
      case 2:
        !isHome ? screen = const HomePage() : null;
        break;
      case 3:
        screen = const LeaderboardPage();
        break;
      case 4:
        screen = ProfilePage();
        break;
      default:
        return;
    }

    if (screen != null) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screen!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: const Color(0xFFFFFFFF),
      currentIndex: _currentIndex!,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: const IconThemeData(size: 45),
      unselectedIconTheme: const IconThemeData(size: 35),
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Icon(isMap ? Icons.pin_drop : Icons.pin_drop_outlined, color: Colors.black),
          label: 'Maps-Page',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.show_chart, color: Colors.black), label: 'Personal-Statistics'),
        BottomNavigationBarItem(
          icon: Icon(isHome ? Icons.home : Icons.home_outlined, color: Colors.black),
          label: "Homescreen",
        ),
        BottomNavigationBarItem(
          icon: Icon(isLeaderboard ? Icons.leaderboard : Icons.leaderboard_outlined, color: Colors.black),
          label: "Leaderboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(isProfile ? Icons.account_circle : Icons.account_circle_outlined, color: Colors.black),
          label: 'Profile-Page',
        ),
      ],
    );
  }
}
