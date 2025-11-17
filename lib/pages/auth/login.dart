import 'package:WalkeRoo/data_fetching/user_service.dart';
import 'package:WalkeRoo/models/user_model.dart';
import 'package:WalkeRoo/pages/home_page/home_page.dart';
import 'package:WalkeRoo/singletons/active_user_singleton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../storage/local_user_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color brandBlue = Color(0xFF123456);
  static const Color accent = Color(0xFFF3F3E0);

  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();

  final _userService = UserService();

  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email.';
    final r = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return r.hasMatch(v) ? null : 'Invalid email format.';
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your password.';
    if (v.length < 6) return 'Password must be at least 6 characters.';
    if (!RegExp(r'\d').hasMatch(v)) {
      return 'Password must contain at least one number.';
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailC.text.trim();
    final password = _passwordC.text.trim();

    try {
      final UserModel user = await _userService.loginUser(email, password);
      ActiveUserSingleton().activeUser = user;

      await LocalUserStorage.saveUser(user);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      final saved = await LocalUserStorage.loadUser();
      if (saved != null) {
        ActiveUserSingleton().activeUser = saved;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        return;
      }

      _showToast(_authError(e));
    } catch (_) {
      _showToast('Login failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'Account disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Error: ${e.code}';
    }
  }

  void _showToast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  InputDecoration _inputStyle(String label, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
      ],
    ),
    child: child,
  );

  Widget _primaryButton(String label, VoidCallback onPressed) => SizedBox(
    height: 56,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );

  Widget _logo() => Container(
    width: 88,
    height: 88,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [brandBlue, Color(0xFF345C7A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 6)),
      ],
    ),
    child: const Center(
      child: Icon(Icons.directions_walk_rounded, color: Colors.white, size: 40),
    ),
  );

  Widget _title() => const Column(
    children: [
      SizedBox(height: 16),
      Text(
        'Welcome back',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      ),
      SizedBox(height: 6),
      Text(
        'Sign in to WalkeRoo',
        style: TextStyle(fontSize: 15, color: Colors.black54),
      ),
    ],
  );

  Widget _emailField() => TextFormField(
    controller: _emailC,
    keyboardType: TextInputType.emailAddress,
    decoration: _inputStyle('Email'),
    validator: _emailValidator,
    enableSuggestions: false,
    autocorrect: false,
    autofillHints: const [],
  );

  Widget _passwordField() => TextFormField(
    controller: _passwordC,
    obscureText: _obscure,
    enableSuggestions: false,
    autocorrect: false,
    autofillHints: const [],
    decoration: _inputStyle(
      'Password',
      suffix: IconButton(
        onPressed: () => setState(() => _obscure = !_obscure),
        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
      ),
    ),
    validator: _passwordValidator,
  );

  Widget _formFields() => _card(
    child: Column(
      children: [
        _emailField(),
        const SizedBox(height: 12),
        _passwordField(),
        const SizedBox(height: 18),
        _isLoading
            ? const CircularProgressIndicator()
            : _primaryButton('Login', _login),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFDADADA),
      ),
      backgroundColor: const Color(0xFFDADADA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _logo(),
                    _title(),
                    const SizedBox(height: 28),
                    _formFields(),
                    const SizedBox(height: 200),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
