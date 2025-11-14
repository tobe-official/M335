import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // follow a friend (adds friend's uid to current user's freindsUUIDs)
  Future<void> followFriend(String friendUid) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');
    if (user.uid == friendUid) throw Exception('Cannot follow yourself');

    final userRef = _firestore.collection('users').doc(user.uid);

    await userRef.update({
      'friendsUUIDs': FieldValue.arrayUnion([friendUid]),
    });
  }

  // unfollow a friend (removes friend's uid from current user's freindsUUIDs)
  Future<void> unfollowFriend(String friendUid) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');
    if (user.uid == friendUid) throw Exception('Cannot unfollow yourself');

    final userRef = _firestore.collection('users').doc(user.uid);

    await userRef.update({
      'friendsUUIDs': FieldValue.arrayRemove([friendUid]),
    });
  }

  // returns list of friend profiles sorted by totalSteps descending
  // each item is a Map with at least 'id' and the user's fields
  // TODO: as you create the leaderboard sort the current user as well in this list
  Future<List<Map<String, dynamic>>> getFriendsSortedBySteps() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user is logged in');

    final userDoc =
    await _firestore.collection('users').doc(user.uid).get();

    final data = userDoc.data();
    if (data == null) return [];

    final List<dynamic> rawFriends = data['friendsUUIDs'] ?? [];
    final List<String> friendIds =
    rawFriends.whereType<String>().toList();

    if (friendIds.isEmpty) return [];

    // Firestore 'whereIn' supports up to 10 items -> batch if needed
    final List<Map<String, dynamic>> results = [];
    const int batchSize = 10;
    for (var i = 0; i < friendIds.length; i += batchSize) {
      final chunk = friendIds.skip(i).take(batchSize).toList();
      final query = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (var doc in query.docs) {
        final item = <String, dynamic>{
          'id': doc.id,
          ...?doc.data(),
        };
        results.add(item);
      }
    }

    // sort by totalSteps descending (missing or non-int treated as 0)
    results.sort((a, b) {
      final aSteps = (a['totalSteps'] is num) ? (a['totalSteps'] as num).toInt() : 0;
      final bSteps = (b['totalSteps'] is num) ? (b['totalSteps'] as num).toInt() : 0;
      return bSteps.compareTo(aSteps);
    });

    return results;
  }
}
