import 'package:flutter/material.dart';
import 'package:m_335_flutter/global_widgets/custom_navigation_bar.dart';

class PersonalStatsPage extends StatelessWidget {
  const PersonalStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar: CustomNavigationBar(initialIndexOfScreen: 1));
  }
}
