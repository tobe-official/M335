import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_335_flutter/pages/home_page/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return const MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false);
  }
}
