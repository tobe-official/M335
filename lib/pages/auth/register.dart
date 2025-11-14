import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:WalkeRoo/data_fetching/user_service.dart';
import 'package:WalkeRoo/singletons/all_users_singleton.dart';
import 'package:WalkeRoo/models/user_model.dart';
import 'package:WalkeRoo/singletons/active_user_singleton.dart';
import 'package:WalkeRoo/pages/home_page/home_page.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  static const Color brandBlue = Color(0xFF123456);
  static const Color accent = Color(0xFFF3F3E0);
  final _userService = UserService();

  final _formKey = GlobalKey<FormState>();
  final _usernameC = TextEditingController();
  final _passwordC = TextEditingController();
  final _emailC = TextEditingController();

  DateTime? _birthDate;
  bool _loading = false;

  @override
  void dispose() {
    _usernameC.dispose();
    _passwordC.dispose();
    _emailC.dispose();
    super.dispose();
  }

  bool _is18OrOlder(DateTime d) {
    final now = DateTime.now();
    final cut = DateTime(now.year - 18, now.month, now.day);
    return !d.isAfter(cut);
  }

  String? _required(String? v, String label) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null;

  String? _emailVal(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final r = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return r.hasMatch(v) ? null : 'Invalid email format';
  }

  String? _passwordVal(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter Password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'\d').hasMatch(v)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String _fmt(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))],
    ),
    child: child,
  );

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final minDate = DateTime(1900, 1, 1);
    final maxDate = DateTime(now.year - 18, now.month, now.day);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              height: 360,
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  const Text('Select your birth date', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initial.isAfter(maxDate) ? maxDate : initial,
                      minimumDate: minDate,
                      maximumDate: maxDate,
                      onDateTimeChanged: (d) => setState(() => _birthDate = d),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
    setState(() {});
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null || !_is18OrOlder(_birthDate!)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must be at least 18 years old to register.')));
      return;
    }

    final username = _usernameC.text.trim();
    final taken = AllUsersSingleton().allUsers?.any((u) => u.username == username) ?? false;
    if (taken) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username already taken. Please choose another.')));
      return;
    }

    setState(() => _loading = true);

    final String email = _emailC.text.trim();
    final String password = _passwordC.text.trim();
    final DateTime birthDate = _birthDate!;

    try {
      final UserModel user = await _userService.createUserProfile(
        email: email,
        password: password,
        username: username,
        birthDate: birthDate,
      );

      AllUsersSingleton().allUsers ??= [];
      AllUsersSingleton().allUsers!.add(user);
      ActiveUserSingleton().activeUser = user;

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while registering: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _title() => const Column(
    children: [
      Text('Create your account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      SizedBox(height: 6),
      Text('Join WalkeRoo and start moving', style: TextStyle(fontSize: 14, color: Colors.black54)),
    ],
  );

  Widget _usernameField() => TextFormField(
    controller: _usernameC,
    enableSuggestions: false,
    autocorrect: false,
    autofillHints: const [],
    validator: (v) => _required(v, 'Username'),
    decoration: _inputStyle('Username'),
  );

  Widget _passwordField() => TextFormField(
    enableSuggestions: false,
    autocorrect: false,
    autofillHints: const [],
    controller: _passwordC,
    obscureText: true,
    validator: _passwordVal,
    decoration: _inputStyle('Password'),
  );

  Widget _emailField() => TextFormField(
    enableSuggestions: false,
    autocorrect: false,
    autofillHints: const [],
    controller: _emailC,
    keyboardType: TextInputType.emailAddress,
    validator: _emailVal,
    decoration: _inputStyle('Email'),
  );

  Widget _birthField() => GestureDetector(
    onTap: _pickBirthDate,
    child: AbsorbPointer(
      child: TextFormField(
        controller: TextEditingController(text: _fmt(_birthDate)),
        validator: (_) => _birthDate == null ? 'Please select your birth date' : null,
        decoration: _inputStyle('Birth Date'),
      ),
    ),
  );

  Widget _submit() => SizedBox(
    height: 56,
    child: ElevatedButton(
      onPressed: _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 2,
      ),
      child: const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFDADADA),
      ),
      backgroundColor: const Color(0xFFDADADA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _title(),
                    const SizedBox(height: 24),
                    _card(
                      child: Column(
                        children: [
                          _usernameField(),
                          const SizedBox(height: 12),
                          _passwordField(),
                          const SizedBox(height: 12),
                          _emailField(),
                          const SizedBox(height: 12),
                          _birthField(),
                          const SizedBox(height: 18),
                          _loading ? const CircularProgressIndicator() : _submit(),
                        ],
                      ),
                    ),
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
