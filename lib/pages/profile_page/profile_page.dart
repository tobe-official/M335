import 'package:flutter/material.dart';
import 'package:m_335_flutter/global_widgets/custom_navigation_bar.dart';
import 'package:m_335_flutter/models/user_model.dart';
import 'package:m_335_flutter/singletons/active_user_singleton.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final UserModel? currentUser = ActiveUserSingleton().activeUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
      bottomNavigationBar: CustomNavigationBar(initialIndexOfScreen: 4),
      backgroundColor: const Color(0XFFD2D2D2),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('@${currentUser!.username}', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))],
      ),
    );
  }
}
