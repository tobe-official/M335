import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:m_335_flutter/pages/auth/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Object? initErr;
  try {
    await FMTCObjectBoxBackend().initialise();
    // We don't know what errors will be thrown, we want to handle them all
    // later
    // ignore: avoid_catches_without_on_clauses
  } catch (err) {
    initErr = err;
  }
  print(initErr);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return const MaterialApp(home: AuthPage(), debugShowCheckedModeBanner: false);
  }
}
