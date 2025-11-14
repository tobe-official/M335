import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:m_335_flutter/enums/user_motivation_enum.dart';
import 'package:m_335_flutter/models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel> createUserProfile({
    required String email,
    required String password,
    required String username,
    required DateTime birthDate,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = credential.user!.uid;
    final now = DateTime.now();

    await _firestore.collection('users').doc(uid).set({
      'name': username,
      'username': username,
      'email': email,
      'age': birthDate,
      'friendsUids': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'totalSteps': 0,
    });

    return UserModel(
      username: username,
      email: email,
      name: username,
      age: birthDate,
      friends: const [],
      aboutMe: '',
      userMotivation: UserMotivation.other,
      creationTime: now,
      totalSteps: 0,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<UserModel> loginUser(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = credential.user!.uid;

    final ref = _firestore.collection('users').doc(uid);
    var snap = await ref.get();

    if (!snap.exists) {
      final username = email.split('@').first;
      final now = DateTime.now();
      final birthDate = now.subtract(const Duration(days: 365 * 18));

      await ref.set({
        'name': username,
        'username': username,
        'email': email,
        'age': birthDate,
        'friendsUids': <String>[],
        'aboutMe': '',
        'userMotivation': UserMotivation.other.name,
        'createdAt': FieldValue.serverTimestamp(),
        'totalSteps': 0,
      });

      return UserModel(
        username: username,
        email: email,
        name: username,
        age: birthDate,
        friends: const [],
        aboutMe: '',
        userMotivation: UserMotivation.other,
        creationTime: now,
        totalSteps: 0,
      );
    }

    final data = snap.data() ?? {};
    final now = DateTime.now();

    final username = (data['username'] as String?) ?? email.split('@').first;
    final nameFromDb = data['name'] as String?;
    final name = (nameFromDb?.trim().isNotEmpty == true) ? nameFromDb! : username;

    final ageTs = data['age'] as Timestamp?;
    final age = ageTs?.toDate() ?? now.subtract(const Duration(days: 365 * 18));

    final createdTs = data['createdAt'] as Timestamp?;
    final creationTime = createdTs?.toDate() ?? now;

    final aboutMe = (data['aboutMe'] as String?) ?? '';
    final friendsDynamic = data['friendsUids'] as List<dynamic>? ?? const [];
    final friends = friendsDynamic.map((e) => e as String).toList();

    final totalSteps = (data['totalSteps'] as num?)?.toInt() ?? 0;

    final motivationRaw = data['userMotivation'] as String?;
    final motivation =
        motivationRaw != null
            ? UserMotivation.values.firstWhere((m) => m.name == motivationRaw, orElse: () => UserMotivation.other)
            : UserMotivation.other;

    return UserModel(
      username: username,
      email: email,
      name: name,
      age: age,
      friends: friends,
      aboutMe: aboutMe,
      userMotivation: motivation,
      creationTime: creationTime,
      totalSteps: totalSteps,
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');
    await _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<void> addActivity(int steps, double distance) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');

    await _firestore.collection('activities').add({
      'userId': user.uid,
      'steps': steps,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(user.uid).update({'totalSteps': FieldValue.increment(steps)});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserActivities() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');

    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');

    final activities = await _firestore.collection('activities').where('userId', isEqualTo: user.uid).get();

    for (var doc in activities.docs) {
      await doc.reference.delete();
    }

    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}
