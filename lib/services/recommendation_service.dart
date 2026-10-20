// lib/services/recommendation_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Rule-based crop recommendation engine.
// Filters the local catalog (or Firestore catalog if available) based on
// user's profile: location, water, climate, experience, time.
// ─────────────────────────────────────────────────────────────────────────────

import '../models/models.dart';
import '../data/catalog_data.dart';

class RecommendationService {
  /// Returns filtered & scored catalog crops for the given user profile.
  List<CatalogCrop> getRecommendations({
    required List<String> growingSpaces,
    required String waterAvailability,
    required String climateZone,
    required String experienceLevel,
    required String timeCommitment,
  }) {
    final scored = <MapEntry<CatalogCrop, int>>[];

    for (final crop in allCatalogCrops) {
      int score = 0;

      // Location compatibility
      if (growingSpaces.isNotEmpty) {
        final locationMatch = growingSpaces.any((space) =>
            crop.compatibleLocations.isEmpty ||
            crop.compatibleLocations.any(
                (loc) => loc.toLowerCase().contains(space.toLowerCase()) ||
                    space.toLowerCase().contains(loc.toLowerCase())));
        if (locationMatch) score += 3;
        else score -= 2; // penalise mismatches
      }

      // Water availability
      if (waterAvailability.isNotEmpty) {
        final waterMatch = crop.waterNeeds.isEmpty ||
            crop.waterNeeds.any((w) =>
                w.toLowerCase().contains(waterAvailability.toLowerCase()) ||
                waterAvailability.toLowerCase().contains(w.toLowerCase()));
        if (waterMatch) score += 2;
      }

      // Climate
      if (climateZone.isNotEmpty && climateZone != 'Not Sure') {
        final climateMatch = crop.compatibleClimates.isEmpty ||
            crop.compatibleClimates.any((c) =>
                c.toLowerCase() == climateZone.toLowerCase());
        if (climateMatch) score += 2;
      }

      // Experience level
      if (experienceLevel.isNotEmpty) {
        final expMatch = crop.suitableExperience.isEmpty ||
            crop.suitableExperience.any((e) =>
                e.toLowerCase().contains(experienceLevel.toLowerCase()) ||
                experienceLevel.toLowerCase().contains(e.toLowerCase()));
        if (expMatch) score += 2;
      }

      // Time commitment
      final minMinutes = _timeToMinutes(timeCommitment);
      if (minMinutes >= crop.minMinutesPerDay) score += 1;

      scored.add(MapEntry(crop, score));
    }

    // Sort by score descending, return crops with non-negative score
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored
        .where((e) => e.value >= 0)
        .map((e) => e.key)
        .toList();
  }

  /// Returns recommended crops for the Add Crop screen, filtering
  /// out crops already being grown by the user.
  List<CatalogCrop> getFilteredCatalog({
    required List<String> growingSpaces,
    required String waterAvailability,
    required String climateZone,
    required String experienceLevel,
    required String timeCommitment,
    List<String> alreadyGrowing = const [],
  }) {
    final recommended = getRecommendations(
      growingSpaces: growingSpaces,
      waterAvailability: waterAvailability,
      climateZone: climateZone,
      experienceLevel: experienceLevel,
      timeCommitment: timeCommitment,
    );
    // Filter out crops already in the user's active plans
    return recommended
        .where((c) => !alreadyGrowing
            .map((n) => n.toLowerCase())
            .contains(c.name.toLowerCase()))
        .toList();
  }

  int _timeToMinutes(String timeCommitment) {
    if (timeCommitment.contains('15')) return 15;
    if (timeCommitment.contains('30')) return 30;
    if (timeCommitment.contains('1 hour')) return 60;
    if (timeCommitment.contains('2+')) return 120;
    if (timeCommitment.toLowerCase().contains('weekend')) return 60;
    return 15;
  }
}
