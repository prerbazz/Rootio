// lib/screens/recommendation_selection_screen.dart
// Shown after onboarding — user picks which recommended crops to start.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import 'dashboard_screen.dart';

class RecommendationSelectionScreen extends StatefulWidget {
  const RecommendationSelectionScreen({super.key});

  @override
  State<RecommendationSelectionScreen> createState() =>
      _RecommendationSelectionScreenState();
}

class _RecommendationSelectionScreenState
    extends State<RecommendationSelectionScreen> {
  final Set<String> _selected = {};
  bool _isAdding = false;

  String _reasonFor(CatalogCrop crop, AppState state) {
    final p = state.profile;
    if (p == null) return crop.tags.take(2).join(' · ');
    final parts = <String>[];
    if (crop.compatibleLocations.isNotEmpty &&
        p.growingSpaces.any((s) => crop.compatibleLocations.any(
            (l) => l.toLowerCase().contains(s.toLowerCase()) ||
                s.toLowerCase().contains(l.toLowerCase())))) {
      parts.add('Suits ${p.growingSpaces.first.toLowerCase()} growing');
    }
    if (crop.minMinutesPerDay <= 15 &&
        p.timeCommitment.contains('15')) {
      parts.add('Fits 15 min/day routine');
    } else if (crop.minMinutesPerDay <= 30 &&
        p.timeCommitment.contains('30')) {
      parts.add('Fits 30 min/day routine');
    }
    if (crop.compatibleClimates.any(
        (c) => c.toLowerCase() == p.climateZone.toLowerCase())) {
      parts.add('Great for ${p.climateZone} climate');
    }
    if (parts.isEmpty) return crop.tags.take(2).join(' · ');
    return parts.take(2).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      final crops = state.getRecommendedCatalog().take(8).toList();
      final name = state.profile?.name ?? 'Farmer';

      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              color: AppColors.primary,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Text(
                        'Rootio',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hi $name! 👋',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'These crops match your setup perfectly.\nPick the ones you want to start growing.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // ── Subtitle bar ─────────────────────────────────────────────
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recommended for you',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (_selected.isNotEmpty)
                    Text(
                      '${_selected.length} selected',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ),

            // ── Crop list ────────────────────────────────────────────────
            Expanded(
              child: crops.isEmpty
                  ? Center(
                      child: Text(
                        'No crops found for your profile.\nYou can add crops manually from the dashboard.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      itemCount: crops.length,
                      itemBuilder: (context, index) {
                        final crop = crops[index];
                        final isSelected = _selected.contains(crop.name);
                        final reason = _reasonFor(crop, state);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (isSelected) {
                              _selected.remove(crop.name);
                            } else {
                              _selected.add(crop.name);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.selectedBg
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.selectedBorder
                                    : const Color(0xFFF0F0F0),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.1)
                                        : AppColors.progressBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(crop.emoji,
                                        style:
                                            const TextStyle(fontSize: 24)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        crop.name,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        reason,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          _MiniTag(crop.difficulty,
                                              crop.difficulty == 'Easy'
                                                  ? AppColors.tagEasy
                                                  : AppColors.tagMedium),
                                          const SizedBox(width: 6),
                                          _MiniTag(crop.duration,
                                              AppColors.textHint),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.cardBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 14)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // ── Bottom CTA ───────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    top: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _isAdding || _selected.isEmpty
                        ? null
                        : () => _startSelected(context, state, crops),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey.shade300,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isAdding
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(
                            _selected.isEmpty
                                ? 'Select crops to continue'
                                : 'Start Growing ${_selected.length} Crop${_selected.length > 1 ? 's' : ''}',
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _selected.isEmpty
                                    ? Colors.grey
                                    : Colors.white),
                          ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _isAdding
                        ? null
                        : () => _skipToDashboard(context, state),
                    child: Text(
                      'Skip for now, I\'ll add crops later',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _startSelected(BuildContext context, AppState state,
      List<CatalogCrop> crops) async {
    setState(() => _isAdding = true);
    final chosen =
        crops.where((c) => _selected.contains(c.name)).toList();
    for (final crop in chosen) {
      state.addCropFromCatalog(crop);
    }
    // small delay so Firestore writes are queued
    await Future.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _skipToDashboard(
      BuildContext context, AppState state) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color == AppColors.textHint ? AppColors.textHint : color)),
    );
  }
}
