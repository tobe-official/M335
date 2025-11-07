import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  //final _firstNameController = TextEditingController();
  //final _lastNameController = TextEditingController();
  int? _age;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final isTaken = AllUsersSingleton().allUsers?.any((u) => u.username == username) ?? false;

    if (isTaken) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Username already taken. Please choose another.")));
      return;
    }

    setState(() => _isLoading = true);

    final user = UserModel(
      username: username,
      password: _passwordController.text.trim(),
      email: _emailController.text.trim(),
      /*age: _age ?? 0,
      creationTime: DateTime.now(),*/
    );

    try {
      userData.add(user);
      AllUsersSingleton().allUsers ??= [];
      AllUsersSingleton().allUsers!.add(user);

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error with registering: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.person_add_alt_1, size: 60, color: Color(0xFF123456)),
                const SizedBox(height: 10),
                const Text("Create your account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                _buildTextField(_usernameController, "Username"),
                _buildTextField(_passwordController, "Password", obscure: true),
                _buildTextField(_emailController, "Email"),
                //_buildTextField(_firstNameController, "First Name"),
                //_buildTextField(_lastNameController, "Last Name"),
                _buildAgePickerField(),
                const SizedBox(height: 25),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF123456),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Register", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    String? Function(String?)? validator;

    if (label == "Email") {
      validator = (value) {
        if (value == null || value.trim().isEmpty) return "Please enter your email";
        final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
        return emailRegex.hasMatch(value) ? null : "Invalid email format";
      };
    } else {
      validator = (value) => value == null || value.trim().isEmpty ? "Please enter $label" : null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildAgePickerField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: _showAgePicker,
        child: AbsorbPointer(
          child: TextFormField(
            controller: TextEditingController(text: _age != null ? _age.toString() : ""),
            decoration: InputDecoration(
              labelText: "Age",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            validator: (value) => _age == null ? "Please select your age" : null,
          ),
        ),
      ),
    );
  }

  void _showAgePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text("Select your age", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(initialItem: (_age ?? 10) - 10),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _age = index + 10;
                    });
                  },
                  children: List<Widget>.generate(83, (index) {
                    return Center(child: Text('${index + 10}', style: const TextStyle(color: Colors.black)));
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
