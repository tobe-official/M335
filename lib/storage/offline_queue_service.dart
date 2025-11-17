import 'dart:convert';
import 'dart:io';

import 'package:WalkeRoo/models/offline_activity.dart';
import 'package:path_provider/path_provider.dart';

class OfflineQueue {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/offline_queue.json');
  }

  static Future<void> add(OfflineActivity act) async {
    final file = await _getFile();

    List list = [];
    if (await file.exists()) {
      list = json.decode(await file.readAsString());
    }

    list.add(act.toJson());
    await file.writeAsString(json.encode(list));
  }

  static Future<List<OfflineActivity>> load() async {
    final file = await _getFile();
    if (!await file.exists()) return [];

    final data = json.decode(await file.readAsString()) as List;

    return data.map((e) => OfflineActivity.fromJson(e)).toList();
  }

  static Future<void> clear() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.writeAsString(json.encode([]));
    }
  }
}
