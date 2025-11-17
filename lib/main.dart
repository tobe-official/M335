import 'package:WalkeRoo/pages/auth/splash_page.dart';
import 'package:WalkeRoo/sync/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
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
  SyncService().start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return const MaterialApp(home: SplashPage(), debugShowCheckedModeBanner: false, title: 'WalkeRoo');
  }
}
