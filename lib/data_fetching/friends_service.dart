import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserUid => _auth.currentUser?.uid;

  Future<void> sendFriendRequest(String toUsername) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    final userSnap = await _firestore
        .collection('users')
        .where('username', isEqualTo: toUsername)
        .limit(1)
        .get();

    if (userSnap.docs.isEmpty) {
      throw Exception('User not found');
    }

    final targetUid = userSnap.docs.first.id;

    await _firestore
        .collection('users')
        .doc(targetUid)
        .collection('friendRequests')
        .add({
      'fromUid': currentUser.uid,
      'fromUsername': currentUser.displayName ?? currentUser.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    final snap = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('friendRequests')
        .orderBy('timestamp', descending: true)
        .get();

    return snap.docs
        .map((d) => {
      'id': d.id,
      'fromUid': d['fromUid'],
      'fromUsername': d['fromUsername'],
    })
        .toList();
  }

  Future<void> acceptFriendRequest(String requestId, String fromUid) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not logged in');

    await _firestore.collection('users').doc(currentUser.uid).update({
      'friendsUids': FieldValue.arrayUnion([fromUid])
    });

    await _firestore.collection('users').doc(fromUid).update({
      'friendsUids': FieldValue.arrayUnion([currentUser.uid])
    });

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('friendRequests')
        .doc(requestId)
        .delete();
  }

  Future<List<Map<String, dynamic>>> getLeaderboardWithUser() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    // Hole User + Friends
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    final friends = userData['friendsUids']?.cast<String>() ?? [];
    final allIds = [...friends, user.uid];

    List<Map<String, dynamic>> result = [];

    for (final id in allIds) {
      final weeklySteps = await _getStepsForLast7DaysForUser(id);

      final userSnap = await _firestore.collection('users').doc(id).get();
      final data = userSnap.data() ?? {};

      result.add({
        'id': id,
        'username': data['username'] ?? 'unknown',
        'steps7days': weeklySteps,
      });
    }

    result.sort((a, b) => b['steps7days'].compareTo(a['steps7days']));

    return result;
  }

  Future<int> _getStepsForLast7DaysForUser(String uid) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final snap = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: uid)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(weekAgo))
        .orderBy('timestamp', descending: true)
        .get();

    var total = 0;
    for (final doc in snap.docs) {
      total += (doc['steps'] as num?)?.toInt() ?? 0;
    }
    return total;
  }

}
