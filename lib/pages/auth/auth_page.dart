import 'package:flutter/material.dart';
import 'package:m_335_flutter/pages/auth/register.dart';

import 'login.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to WalkeRoo",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF123456),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Register()));
              },
              child: const Text("No account? Register here", style: TextStyle(fontSize: 16, color: Color(0xFF123456))),
            ),
          ],
        ),
      ),
    );
  }
}
