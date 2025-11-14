import 'package:flutter/material.dart';
import 'package:WalkeRoo/pages/auth/auth_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white, body: Center(child: _SplashContent()));
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
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 6))],
          ),
          child: ClipOval(child: Image.asset('assets/icon/icon.png', fit: BoxFit.cover)),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(brandBlue)),
        ),
      ],
    );
  }
}
