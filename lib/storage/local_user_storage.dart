import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:WalkeRoo/models/user_model.dart';

import '../enums/user_motivation_enum.dart';

class LocalUserStorage {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/local_user.json");
  }

  static Future<void> saveUser(UserModel user) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode({
      "username": user.username,
      "email": user.email,
      "name": user.name,
      "age": user.age.toIso8601String(),
      "friends": user.friends,
      "aboutMe": user.aboutMe,
      "motivation": user.userMotivation?.name,
      "creationTime": user.creationTime.toIso8601String(),
      "totalSteps": user.totalSteps,
    }));
  }

  static Future<UserModel?> loadUser() async {
    final file = await _getFile();
    if (!await file.exists()) return null;

    final map = jsonDecode(await file.readAsString());
    return UserModel(
      username: map["username"],
      email: map["email"],
      name: map["name"],
      aboutMe: map["aboutMe"],
      friends: List<String>.from(map["friends"]),
      age: DateTime.parse(map["age"]),
      creationTime: DateTime.parse(map["creationTime"]),
      userMotivation: UserMotivation.values.firstWhere(
            (m) => m.name == map["motivation"],
        orElse: () => UserMotivation.other,
      ),
      totalSteps: map["totalSteps"],
    );
  }

  static Future<void> deleteUser() async {
    final file = await _getFile();
    if (await file.exists()) await file.delete();
  }
}
