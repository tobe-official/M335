import 'package:m_335_flutter/models/user_model.dart';

class ActiveUserSingleton {
  static final ActiveUserSingleton _activeUserSingleton = ActiveUserSingleton._internal();

  UserModel? activeUser;

  factory ActiveUserSingleton() {
    return _activeUserSingleton;
  }

  ActiveUserSingleton._internal();

  void setUser(UserModel user) {
    activeUser = user;
  }

  void clearUser() {
    activeUser = null;
  }
}
