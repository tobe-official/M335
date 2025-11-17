import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

}
