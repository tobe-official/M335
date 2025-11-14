import 'package:flutter/material.dart';
import 'package:WalkeRoo/global_widgets/custom_navigation_bar.dart';

class PersonalStatsPage extends StatelessWidget {
  const PersonalStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar: CustomNavigationBar(initialIndexOfScreen: 1));
  }
}
