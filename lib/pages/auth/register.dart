import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:m_335_flutter/singletons/all_users_singleton.dart';
import 'package:m_335_flutter/models/user_model.dart';
import 'package:m_335_flutter/temporary_data/data_fetching.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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

  String? _validateRequired(String? v, String label) => (v == null || v.trim().isEmpty) ? 'Please enter $label' : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final r = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return r.hasMatch(v) ? null : 'Invalid email format';
  }

  bool _is18OrOlder(DateTime d) {
    final now = DateTime.now();
    final eighteen = DateTime(now.year - 18, now.month, now.day);
    return d.isBefore(eighteen) || d.isAtSameMomentAs(eighteen);
  }

  InputDecoration _dec(String label) =>
      InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)));

  String _birthDateLabel(DateTime? d) {
    if (d == null) return '';
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final minDate = DateTime(1900, 1, 1);
    final maxDate = DateTime(now.year - 18, now.month, now.day);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SizedBox(
          height: 260,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text('Select your birth date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initial,
                  minimumDate: minDate,
                  maximumDate: maxDate,
                  onDateTimeChanged: (d) => setState(() => _birthDate = d),
                ),
              ),
            ],
          ),
        );
      },
    );
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

    final user = UserModel(
      username: username,
      password: _passwordC.text.trim(),
      email: _emailC.text.trim(),
      name: '',
      aboutMe: '',
      friends: <UserModel>[],
      age: _birthDate!,
      creationTime: DateTime.now(),
    );

    try {
      userData.add(user);
      AllUsersSingleton().allUsers ??= [];
      AllUsersSingleton().allUsers!.add(user);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error while registering: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _header() {
    return Column(
      children: const [
        Icon(Icons.person_add_alt_1, size: 60, color: Color(0xFF123456)),
        SizedBox(height: 10),
        Text('Create your account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _dec(label),
      ),
    );
  }

  Widget _birthDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: _pickBirthDate,
        child: AbsorbPointer(
          child: TextFormField(
            controller: TextEditingController(text: _birthDateLabel(_birthDate)),
            validator: (_) => _birthDate == null ? 'Please select your birth date' : null,
            decoration: _dec('Birth Date'),
          ),
        ),
      ),
    );
  }

  Widget _registerButton() {
    if (_loading) return const CircularProgressIndicator();
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF123456),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Register', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _header(),
                const SizedBox(height: 30),
                _field(_usernameC, 'Username', validator: (v) => _validateRequired(v, 'Username')),
                _field(_passwordC, 'Password', obscure: true, validator: (v) => _validateRequired(v, 'Password')),
                _field(_emailC, 'Email', keyboardType: TextInputType.emailAddress, validator: _validateEmail),
                _birthDateField(),
                const SizedBox(height: 25),
                _registerButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
