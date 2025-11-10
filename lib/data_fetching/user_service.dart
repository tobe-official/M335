import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// UserService – kümmert sich um alle Firebase–Operationen
/// erstellen, lesen, aktualisieren, Aktivitäten hinzufügen
class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Erstellt ein neues Benutzerprofil nach der Registrierung.
  Future<void> createUserProfile(String name, String email) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kein Benutzer angemeldet');

    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'totalSteps': 0,
    });
  }

  /// Gibt das aktuelle Benutzerprofil als Stream zurück.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kein Benutzer angemeldet');
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  /// Aktualisiert Benutzerdaten
  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kein Benutzer angemeldet');
    await _firestore.collection('users').doc(user.uid).update(data);
  }

  /// Fügt eine Aktivität hinzu (Trackingdaten).
  Future<void> addActivity(int steps, double distance) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kein Benutzer angemeldet');

    await _firestore.collection('activities').add({
      'userId': user.uid,
      'steps': steps,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Optional: direkt die Gesamtschritte im User-Profil erhöhen
    await _firestore.collection('users').doc(user.uid).update({
      'totalSteps': FieldValue.increment(steps),
      'totalDistance': FieldValue.increment(distance),
    });
  }

  /// Holt alle Aktivitäten eines bestimmten Benutzers.
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserActivities() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kein Benutzer angemeldet');

    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Löscht den aktuellen Benutzer und alle Daten.
  Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Kein Benutzer angemeldet');

    // Alle Aktivitäten löschen
    final activities = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: user.uid)
        .get();
    for (var doc in activities.docs) {
      await doc.reference.delete();
    }

    // User-Profil löschen
    await _firestore.collection('users').doc(user.uid).delete();

    // Benutzer aus Auth entfernen
    await user.delete();
  }
}
