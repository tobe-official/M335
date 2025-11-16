import 'package:flutter/material.dart';
import 'package:WalkeRoo/pages/auth/auth_page.dart';
import 'package:WalkeRoo/pages/home_page/home_page.dart';
import 'package:WalkeRoo/storage/local_user_storage.dart';
import 'package:WalkeRoo/singletons/active_user_singleton.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final savedUser = await LocalUserStorage.loadUser();

    if (!mounted) return;

    if (savedUser != null) {
      ActiveUserSingleton().activeUser = savedUser;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: _SplashContent()),
    );
  }
}

class _SplashContent extends StatelessWidget {
  static const Color brandBlue = Color(0xFF123456);

  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 6))
            ],
          ),
          child: ClipOval(
            child: Image.asset('assets/icon/icon.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(brandBlue),
          ),
        ),
      ],
    );
  }
}
