import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import 'all_plans_screen.dart';
import 'crop_detail_screen.dart';
import 'add_crop_screen.dart';
import 'settings/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final name = state.onboarding.name.isNotEmpty
            ? state.onboarding.name
            : 'Farmer';
        final hour = DateTime.now().hour;
        final greeting = hour < 12
            ? 'Good morning'
            : hour < 17
                ? 'Good afternoon'
                : 'Good evening';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── Green Header ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.primary,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : 'F',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greeting,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text('🌿',
                                        style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Refresh insights
                          IconButton(
                            icon: const Icon(Icons.refresh_outlined,
                                color: Colors.white),
                            tooltip: 'Refresh Insights',
                            onPressed: () => state.refreshInsights(),
                          ),
                          // Settings (now functional)
                          IconButton(
                            icon: const Icon(Icons.settings_outlined,
                                color: Colors.white),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Streak row — real data from Firestore
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your farming streak',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.75),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Text('🔥',
                                        style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${state.streakDays} days',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'This week',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.75),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${state.weeklyTasksDone} tasks done',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Today's Insights ────────────────────────────
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Today's Insights",
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => state.refreshInsights(),
                                  child: const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: AppColors.textHint),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...state.todayInsights.map((insight) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Text(insight['icon']!,
                                          style:
                                              const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          insight['text']!,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Growing Plans header ─────────────────────────
                      Row(
                        children: [
                          Text(
                            'Your Growing Plans',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AllPlansScreen()),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.grid_view,
                                    size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'View All',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Plan cards
                      if (state.activePlans.isEmpty)
                        _EmptyPlansPrompt(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddCropScreen()),
                          ),
                        )
                      else
                        ...state.activePlans.map((plan) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: _PlanListCard(
                                plan: plan,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CropDetailScreen(planId: plan.id),
                                  ),
                                ),
                              ),
                            )),

                      const SizedBox(height: 16),

                      // Start New Crop button
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddCropScreen()),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Start a New Crop',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Weekly Activity — real Firestore data ────────
                      Text(
                        'Weekly Activity',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _WeeklyActivityChart(
                          values: state.weeklyActivityValues),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Empty Plans Prompt ───────────────────────────────────────────────────────

class _EmptyPlansPrompt extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyPlansPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.selectedBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.selectedBorder.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            const Text('🌱', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              'No crops yet! Tap to start growing.',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Plan List Card ───────────────────────────────────────────────────────────

class _PlanListCard extends StatelessWidget {
  final CropPlan plan;
  final VoidCallback onTap;

  const _PlanListCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = (plan.overallProgress * 100).round();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(plan.emoji,
                    style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _Tag(
                              plan.difficulty,
                              plan.difficulty == 'Easy'
                                  ? AppColors.tagEasy
                                  : AppColors.tagMedium),
                          const SizedBox(width: 6),
                          _LocationTag(plan.location),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.trending_up,
                    color: AppColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Week ${plan.currentWeek}: ${plan.currentWeekTitle}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: plan.overallProgress,
                      backgroundColor: AppColors.progressBg,
                      valueColor: const AlwaysStoppedAnimation(
                          AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$pct%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _getNextTask(plan),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getNextTask(CropPlan plan) {
    for (final week in plan.weeks) {
      for (final task in week.tasks) {
        if (!task.isCompleted) return 'Next: ${task.title}';
      }
    }
    return 'All tasks complete!';
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w500, color: color),
      ),
    );
  }
}

class _LocationTag extends StatelessWidget {
  final String location;
  const _LocationTag(this.location);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
              color: Colors.red, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          location,
          style:
              GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ─── Section Card wrapper ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: child,
    );
  }
}

// ─── Weekly Activity Chart — driven by real Firestore data ───────────────────

class _WeeklyActivityChart extends StatelessWidget {
  final List<double> values; // 7 values, 0.0–1.0

  const _WeeklyActivityChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1; // Monday = 0

    final displayValues = values.length == 7
        ? values
        : List.filled(7, 0.0);

    return Container(
      height: 136,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(days.length, (i) {
          final isToday = i == today;
          final height = displayValues[i] * 64;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOut,
                  height: height > 0 ? height : 4,
                  width: 20,
                  decoration: BoxDecoration(
                    color: height > 0
                        ? (isToday
                            ? AppColors.primary
                            : AppColors.primaryLight.withOpacity(0.6))
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  days[i],
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight:
                        isToday ? FontWeight.w700 : FontWeight.w400,
                    color: isToday
                        ? AppColors.primary
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
