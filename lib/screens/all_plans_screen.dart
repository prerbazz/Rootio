import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/app_state.dart';
import '../models/models.dart';
import 'crop_detail_screen.dart';
import 'add_crop_screen.dart';

class AllPlansScreen extends StatefulWidget {
  const AllPlansScreen({super.key});

  @override
  State<AllPlansScreen> createState() => _AllPlansScreenState();
}

class _AllPlansScreenState extends State<AllPlansScreen> {
  bool _isGrid = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.primary,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All Plans',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${state.activePlans.length} active, ${state.completedPlans.length} completed',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Toggle grid/list
                      IconButton(
                        icon: Icon(
                          _isGrid ? Icons.grid_view : Icons.view_list,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() => _isGrid = !_isGrid),
                      ),
                      IconButton(
                        icon: const Icon(Icons.format_list_bulleted, color: Colors.white),
                        onPressed: () => setState(() => _isGrid = false),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Active Plans
                    Text(
                      'Active Plans',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_isGrid)
                      _buildGrid(context, state)
                    else
                      _buildList(context, state),

                    // Completed Plans
                    if (state.completedPlans.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        'Completed Plans',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.completedPlans.map((plan) => _CompletedCard(plan: plan)),
                    ],

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, AppState state) {
    final active = state.activePlans;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: active.length + 1, // +1 for Add New
      itemBuilder: (context, index) {
        if (index == active.length) {
          return _AddNewCard(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCropScreen()),
            ),
          );
        }
        final plan = active[index];
        return _GridPlanCard(
          plan: plan,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CropDetailScreen(planId: plan.id)),
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, AppState state) {
    final active = state.activePlans;
    return Column(
      children: [
        ...List.generate(active.length, (index) {
          final plan = active[index];
          return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  // Move up/down controls
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: index > 0
                            ? () => state.reorderPlans(index, index - 1)
                            : null,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: index > 0 ? AppColors.selectedBg : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.keyboard_arrow_up,
                            size: 18,
                            color: index > 0 ? AppColors.primary : Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: index < active.length - 1
                            ? () => state.reorderPlans(index, index + 1)
                            : null,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: index < active.length - 1 ? AppColors.selectedBg : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.keyboard_arrow_down,
                            size: 18,
                            color: index < active.length - 1 ? AppColors.primary : Colors.grey.shade300),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Dismissible(
                key: Key(plan.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                ),
                confirmDismiss: (_) => showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text('Remove crop?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    content: Text('This removes this crop from your active plans.',
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary))),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        child: Text('Remove', style: GoogleFonts.inter(color: Colors.white)),
                      ),
                    ],
                  ),
                ).then((v) => v ?? false),
                onDismissed: (_) => context.read<AppState>().removeCrop(plan.id, 'Removed via swipe', null),
                child: _ListPlanCard(
                  plan: plan,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CropDetailScreen(planId: plan.id)),
                  ),
                ),
              )),
                ],
              ),
            );
        }),
        _AddNewCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCropScreen()),
          ),
        ),
      ],
    );
  }
}

// ─── Grid Card ────────────────────────────────────────────────────────────────

class _GridPlanCard extends StatelessWidget {
  final CropPlan plan;
  final VoidCallback onTap;
  const _GridPlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = (plan.overallProgress * 100).round();
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Text(plan.emoji, style: const TextStyle(fontSize: 28)),
                const Spacer(),
                Text(
                  'Wk ${plan.currentWeek}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$pct% complete',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: plan.overallProgress,
                backgroundColor: AppColors.progressBg,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: plan.difficulty == 'Easy'
                    ? AppColors.tagEasy.withOpacity(0.12)
                    : AppColors.tagMedium.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                plan.difficulty,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: plan.difficulty == 'Easy' ? AppColors.tagEasy : AppColors.tagMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── List Card ────────────────────────────────────────────────────────────────

class _ListPlanCard extends StatelessWidget {
  final CropPlan plan;
  final VoidCallback onTap;
  const _ListPlanCard({required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = (plan.overallProgress * 100).round();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            Text(plan.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
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
                  Text(
                    'Week ${plan.currentWeek}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: plan.overallProgress,
                      backgroundColor: AppColors.progressBg,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      minHeight: 5,
                    ),
                  ),
                  Text(
                    '$pct% complete',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

// ─── Add New Card ─────────────────────────────────────────────────────────────

class _AddNewCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddNewCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.selectedBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primary, size: 28),
            const SizedBox(height: 6),
            Text(
              'Add New Plan',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Completed Card ───────────────────────────────────────────────────────────

class _CompletedCard extends StatelessWidget {
  final CropPlan plan;
  const _CompletedCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(plan.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              plan.name,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Completed',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
