import 'package:WalkeRoo/enums/user_motivation_enum.dart';

class UserModel {
  const UserModel({
    required this.username,
    required this.email,
    required this.name,
    required this.age,
    required this.friends,
    this.userMotivation = UserMotivation.other,
    this.aboutMe = '',
    required this.creationTime,
    required this.totalSteps,
  });

  final String username;
  final String email;
  final List<String> friends;
  final DateTime age;
  final DateTime creationTime;
  final String name;
  final String? aboutMe;
  final UserMotivation? userMotivation;
  final int totalSteps;
}
