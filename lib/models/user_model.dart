class UserModel {
  const UserModel({
    required this.username,
    required this.password,
    required this.email,
    required this.name,
    required this.age,
    required this.friends,
    required this.aboutMe,
    required this.creationTime,
  });

  final String username;
  final String password;
  final String email;
  final List<UserModel> friends;
  final DateTime age;
  final DateTime creationTime;
  final String name;
  final String aboutMe;
}
