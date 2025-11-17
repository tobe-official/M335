import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/offline_activity.dart';
import '../storage/offline_queue_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final _firestore = FirebaseFirestore.instance;
  Timer? _timer;

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 5), (t) => sync());
  }

  Future<void> sync() async {
    final conn = await Connectivity().checkConnectivity();
    if (conn == ConnectivityResult.none) return;

    final List<OfflineActivity> jobs = await OfflineQueue.load();
    if (jobs.isEmpty) return;

    OfflineActivity? lastAct;
    for (final act in jobs) {
      if (act != lastAct) {
        await _firestore.collection('activities').add({
          'userId': act.userId,
          'steps': act.steps,
          'timestamp': act.timestamp,
        });

        await _firestore.collection('users').doc(act.userId).update({
          'totalSteps': FieldValue.increment(act.steps),
        });
      }
      lastAct = act;
    }

    await OfflineQueue.clear();
  }
}
