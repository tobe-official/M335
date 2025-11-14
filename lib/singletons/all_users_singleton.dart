import 'package:WalkeRoo/models/user_model.dart';

class AllUsersSingleton {
  static final AllUsersSingleton _allUsersSingleton = AllUsersSingleton._internal();

  List<UserModel>? allUsers;

  factory AllUsersSingleton() {
    return _allUsersSingleton;
  }

  AllUsersSingleton._internal();

  void setUsers(List<UserModel> users) {
    allUsers = users;
  }

  void clearUsers() {
    allUsers = null;
  }
}
