import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Minimal Firestore stubs to replace temp UI data with real reads/writes.
class UserProfileService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> upsertProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _users.doc(uid).set(data, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamProfile(String uid) {
    return _users.doc(uid).snapshots();
  }
}

class WorkoutService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _workouts =>
      _db.collection('workouts');

  Future<DocumentReference<Map<String, dynamic>>> createWorkout(
    Map<String, dynamic> data,
  ) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _workouts.add({
      ...data,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUserWorkouts(String uid) {
    return _workouts
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateWorkout(String id, Map<String, dynamic> data) async {
    await _workouts.doc(id).update(data);
  }

  Future<void> deleteWorkout(String id) async {
    await _workouts.doc(id).delete();
  }
}

class FeedService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _feed =>
      _db.collection('feed');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamFeed({int limit = 25}) {
    return _feed
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> addFeedEntry(
    Map<String, dynamic> data,
  ) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _feed.add({
      ...data,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

class ChallengeService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _challenges =>
      _db.collection('challenges');

  Future<void> joinChallenge(String challengeId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = _challenges.doc(challengeId).collection('participants').doc(uid);
    await ref.set({
      'joinedAt': FieldValue.serverTimestamp(),
      'status': 'active',
      'uid': uid,
    });
  }

  Future<void> leaveChallenge(String challengeId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = _challenges.doc(challengeId).collection('participants').doc(uid);
    await ref.delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveChallenges() {
    final now = Timestamp.now();
    return _challenges
        .where('endDate', isGreaterThanOrEqualTo: now)
        .orderBy('endDate')
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamParticipant(
      String challengeId, String uid) {
    return _challenges
        .doc(challengeId)
        .collection('participants')
        .doc(uid)
        .snapshots();
  }

  Future<void> upsertProgress({
    required String challengeId,
    required String uid,
    required String dayKey,
    required int count,
  }) async {
    final ref =
        _challenges.doc(challengeId).collection('progress').doc(uid);
    await ref.set({
      'ownerId': uid,
      'uid': uid,
      'records': {dayKey: count},
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> createChallenge({
    required String title,
    required String description,
    required String difficulty,
    required String authorUid,
    required String authorName,
    DateTime? endDate,
  }) async {
    await _challenges.add({
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'authorUid': authorUid,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
      'endDate': endDate != null
          ? Timestamp.fromDate(endDate)
          : Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamProgress(
      String challengeId, String uid) {
    return _challenges
        .doc(challengeId)
        .collection('progress')
        .doc(uid)
        .snapshots();
  }
}

class PhotoJournalService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _entries =>
      _db.collection('journalPhotos');

  Future<DocumentReference<Map<String, dynamic>>> addEntry(
    Map<String, dynamic> data,
  ) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _entries.add({
      ...data,
      'ownerId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamEntries(String uid) {
    return _entries
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateEntry(String id, Map<String, dynamic> data) async {
    await _entries.doc(id).update(data);
  }

  Future<void> deleteEntry(String id) async {
    await _entries.doc(id).delete();
  }
}
