// lib/services/local_profile_service.dart
// Persists lightweight profile info locally so user doesn't re-onboard on every launch.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class LocalProfile {
  final String uid;
  final String name;
  final String emoji;

  const LocalProfile({
    required this.uid,
    required this.name,
    required this.emoji,
  });

  Map<String, dynamic> toMap() => {'uid': uid, 'name': name, 'emoji': emoji};

  factory LocalProfile.fromMap(Map<String, dynamic> m) => LocalProfile(
        uid: m['uid'] ?? '',
        name: m['name'] ?? 'Farmer',
        emoji: m['emoji'] ?? '🌱',
      );
}

class LocalProfileService {
  static const _kProfiles = 'rootio_profiles';
  static const _kLastUid = 'rootio_last_uid';

  Future<List<LocalProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kProfiles) ?? [];
    return raw
        .map((s) => LocalProfile.fromMap(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<String?> getLastUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastUid);
  }

  Future<void> saveProfile(LocalProfile p) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getProfiles();
    // Replace if uid already exists, else append
    final updated = [
      ...existing.where((e) => e.uid != p.uid),
      p,
    ];
    await prefs.setStringList(
        _kProfiles, updated.map((e) => jsonEncode(e.toMap())).toList());
    await prefs.setString(_kLastUid, p.uid);
  }

  Future<void> setLastUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastUid, uid);
  }

  Future<void> removeProfile(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getProfiles();
    final updated = existing.where((e) => e.uid != uid).toList();
    await prefs.setStringList(
        _kProfiles, updated.map((e) => jsonEncode(e.toMap())).toList());
    final last = prefs.getString(_kLastUid);
    if (last == uid) await prefs.remove(_kLastUid);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kProfiles);
    await prefs.remove(_kLastUid);
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('rootio_user_profile_') || key.startsWith('rootio_plans_')) {
        await prefs.remove(key);
      }
    }
  }

  Future<void> saveUserProfileLocal(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rootio_user_profile_${profile.uid}', jsonEncode(profile.toMap()));
  }

  Future<UserProfile?> loadUserProfileLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('rootio_user_profile_$uid');
    if (raw == null) return null;
    try {
      return UserProfile.fromMap(uid, jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteUserProfileLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rootio_user_profile_$uid');
  }

  Future<void> savePlansLocal(String uid, List<CropPlan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = plans.map((p) => p.toMap()).toList();
    await prefs.setString('rootio_plans_$uid', jsonEncode(raw));
  }

  Future<List<CropPlan>> loadPlansLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('rootio_plans_$uid');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((m) => CropPlan.fromMap(m['id'] ?? '', Map<String, dynamic>.from(m))).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deletePlansLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rootio_plans_$uid');
  }
}
