import 'package:flutter/material.dart';
import 'package:m_335_flutter/pages/home_page/home_page.dart';

import 'package:m_335_flutter/singletons/all_users_singleton.dart';

import 'package:m_335_flutter/singletons/active_user_singleton.dart';

import 'package:m_335_flutter/models/user_model.dart';
import 'package:m_335_flutter/temporary_data/data_fetching.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> loadUsersAndDays() async {
    final users = userData;
    AllUsersSingleton().setUsers(users);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    loadUsersAndDays();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text.trim();

      if (username.isEmpty || password.isEmpty) {
        throw Exception("Please fill out all fields");
      }

      final activeUser = AllUsersSingleton().allUsers!.cast<UserModel?>().firstWhere(
        (user) => user?.username == username && user?.password == password,
        orElse: () => null,
      );

      if (activeUser == null) {
        throw Exception("User not found or wrong credentials!");
      }

      ActiveUserSingleton().setUser(activeUser);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username or password wrong!")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Enter your login details", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildTextField(_usernameController, "Username", false),
            const SizedBox(height: 10),
            _buildTextField(_passwordController, "Password", true),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF123456),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
    );
  }
}
