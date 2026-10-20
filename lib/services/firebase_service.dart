import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/models.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Auth ──────────────────────────────────────────────────────────────────

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── User Profile ──────────────────────────────────────────────────────────

  DocumentReference _userDoc(String uid) => _db.collection('users').doc(uid);

  Future<void> saveUserProfile(UserProfile profile) =>
      _userDoc(profile.uid).set(profile.toMap(), SetOptions(merge: true));

  Future<UserProfile?> loadUserProfile(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return null;
    return UserProfile.fromMap(uid, snap.data() as Map<String, dynamic>);
  }

  Future<void> updateProfileField(String uid, Map<String, dynamic> fields) =>
      _userDoc(uid).update(fields);

  // ── Sessions & Crop Plans ─────────────────────────────────────────────────

  DocumentReference _sessionDoc(String uid, String sessionId) =>
      _userDoc(uid).collection('sessions').doc(sessionId);

  CollectionReference _plansCol(String uid, String sessionId) =>
      _sessionDoc(uid, sessionId).collection('plans');

  Future<void> savePlan(String uid, String sessionId, CropPlan plan) {
    plan.sessionId = sessionId;
    return _plansCol(uid, sessionId).doc(plan.id).set(plan.toMap());
  }

  Future<void> updatePlan(String uid, String sessionId, String planId, Map<String, dynamic> fields) =>
      _plansCol(uid, sessionId).doc(planId).update(fields);

  Future<List<CropPlan>> loadPlans(String uid, String sessionId) async {
    if (sessionId.isEmpty) return [];
    final snap = await _plansCol(uid, sessionId)
        .where('isActive', isEqualTo: true)
        .orderBy('startedAt', descending: false)
        .get();
    return snap.docs
        .map((d) => CropPlan.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<List<CropPlan>> plansStream(String uid, String sessionId) {
    if (sessionId.isEmpty) return Stream.value([]);
    return _plansCol(uid, sessionId)
        .where('isActive', isEqualTo: true)
        .orderBy('startedAt')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => CropPlan.fromMap(d.id, d.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  /// Remove a crop (mark inactive)
  Future<void> removeCrop(String uid, String sessionId, String planId, String reason) =>
      _plansCol(uid, sessionId).doc(planId).update({
        'isActive': false,
        'removalReason': reason,
      });

  /// Delete a plan entirely
  Future<void> deletePlan(String uid, String sessionId, String planId) =>
      _plansCol(uid, sessionId).doc(planId).delete();

  Future<void> deleteAllPlans(String uid, String sessionId) async {
    final snap = await _plansCol(uid, sessionId).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ── Activity Tracking ─────────────────────────────────────────────────────

  CollectionReference _activityCol(String uid, String sessionId) =>
      _sessionDoc(uid, sessionId).collection('activity');

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> recordActivity(String uid, String sessionId, int tasksCount) async {
    final key = _todayKey();
    final ref = _activityCol(uid, sessionId).doc(key);
    await ref.set({
      'date': key,
      'tasksCompleted': FieldValue.increment(tasksCount),
    }, SetOptions(merge: true));
  }

  Future<List<WeeklyActivityEntry>> loadWeeklyActivity(String uid, String sessionId) async {
    if (sessionId.isEmpty) return List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      return WeeklyActivityEntry(date: '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}', tasksCompleted: 0);
    });
    final keys = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    });

    final entries = <WeeklyActivityEntry>[];
    for (final key in keys) {
      final snap = await _activityCol(uid, sessionId).doc(key).get();
      if (snap.exists) {
        entries.add(WeeklyActivityEntry.fromMap(snap.data() as Map<String, dynamic>));
      } else {
        entries.add(WeeklyActivityEntry(date: key, tasksCompleted: 0));
      }
    }
    return entries;
  }

  Future<void> updateStreak(String uid) async {
    final today = _todayKey();
    final snap = await _userDoc(uid).get();
    final data = snap.data() as Map<String, dynamic>? ?? {};
    final lastActive = data['lastActiveDate'] ?? '';
    final streak = (data['streakDays'] ?? 0) as int;

    if (lastActive == today) return; 

    final yesterday = () {
      final d = DateTime.now().subtract(const Duration(days: 1));
      return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }();

    final newStreak = lastActive == yesterday ? streak + 1 : 1;
    await _userDoc(uid).update({
      'streakDays': newStreak,
      'lastActiveDate': today,
    });
  }

  // ── Firebase Storage (photos) ─────────────────────────────────────────────

  Future<String> uploadPhoto(String uid, String sessionId, String planId, String localPath) async {
    final file = File(localPath);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref('users/$uid/sessions/$sessionId/plans/$planId/$fileName');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deletePhoto(String storageUrl) async {
    try {
      final ref = _storage.refFromURL(storageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting photo from storage: $e');
    }
  }

  // ── AI Insights Cache ─────────────────────────────────────────────────────

  CollectionReference _insightsCol(String uid, String sessionId) =>
      _sessionDoc(uid, sessionId).collection('insights');

  Future<void> saveInsights(String uid, String sessionId, List<AiInsight> insights) async {
    final batch = _db.batch();
    final old = await _insightsCol(uid, sessionId).get();
    for (final doc in old.docs) {
      batch.delete(doc.reference);
    }
    for (int i = 0; i < insights.length; i++) {
      final ref = _insightsCol(uid, sessionId).doc('insight_$i');
      batch.set(ref, {
        ...insights[i].toMap(),
        'generatedAt': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit();
  }

  Future<List<AiInsight>> loadInsights(String uid, String sessionId) async {
    if (sessionId.isEmpty) return [];
    final snap = await _insightsCol(uid, sessionId).orderBy('generatedAt').get();
    return snap.docs
        .map((d) => AiInsight.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }
}
