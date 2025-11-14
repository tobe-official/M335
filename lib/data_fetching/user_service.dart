import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // creates new user profile
  Future<void> createUserProfile(String name, String email) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');

    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'friendsUUIDs': [],
      'createdAt': FieldValue.serverTimestamp(),
      'totalSteps': 0,
    });
  }

  // returns userprofile as stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      if (user == null) throw Exception('No user is logged in');
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  // update user profile data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');
    await _firestore.collection('users').doc(user.uid).update(data);
  }

  //adds activity for current user aka steps
  Future<void> addActivity(int steps, double distance) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');

    await _firestore.collection('activities').add({
      'userId': user.uid,
      'steps': steps,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _firestore.collection('users').doc(user.uid).update({
      'totalSteps': FieldValue.increment(steps),
    });
  }

  // get all user activities as a stream
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserActivities() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');

    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  //delete current user account along with their data
  Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');

    // delete user activities
    final activities = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: user.uid)
        .get();
    for (var doc in activities.docs) {
      await doc.reference.delete();
    }

    // delete user profile
    await _firestore.collection('users').doc(user.uid).delete();

    // remove user authentication
    await user.delete();
  }
}
