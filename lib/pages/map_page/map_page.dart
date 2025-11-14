import 'package:flutter/material.dart';
import 'package:WalkeRoo/global_widgets/custom_navigation_bar.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(bottomNavigationBar: CustomNavigationBar(initialIndexOfScreen: 0));
  }
}
