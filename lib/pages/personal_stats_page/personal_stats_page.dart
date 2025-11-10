import 'package:flutter/material.dart';
import 'package:m_335_flutter/global_widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:m_335_flutter/global_widgets/custom_navigation_bar.dart';
import 'package:m_335_flutter/controller/route_controller.dart';
import 'package:m_335_flutter/pages/routes_page/routes_page.dart';

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RoutesPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomNavigationBar(initialIndexOfScreen: 1),
      backgroundColor: const Color(0xFFFFFDD0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Deine persönlichen Statistiken',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _openRoutesPage(context),
              icon: const Icon(Icons.map),
              label: Text(
                _isLoading ? 'Lädt...' : 'Gespeicherte Routen anzeigen',
                style: const TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF123456),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
