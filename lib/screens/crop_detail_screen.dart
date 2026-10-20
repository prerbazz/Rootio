import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme.dart';
import 'crop_assistant_screen.dart';
import '../data/app_state.dart';
import '../models/models.dart';

class CropDetailScreen extends StatelessWidget {
  final String planId;
  const CropDetailScreen({super.key, required this.planId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        // Safe lookup — plan may have been deleted
        final planIndex =
            state.plans.indexWhere((p) => p.id == planId);
        if (planIndex == -1) {
          return Scaffold(
            appBar: AppBar(backgroundColor: AppColors.primary),
            body: const Center(child: Text('Plan not found')),
          );
        }
        final plan = state.plans[planIndex];
        final pct = (plan.overallProgress * 100).round();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── Green header ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.primary,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _WhiteTag(plan.difficulty),
                                    const SizedBox(width: 6),
                                    _WhiteTag(plan.location),
                                    const SizedBox(width: 6),
                                    _WhiteTag(
                                        '${plan.totalWeeks} weeks total'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => CropAssistantScreen(plan: plan))),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                                const SizedBox(width: 4),
                                Text('Ask AI', style: GoogleFonts.inter(
                                  fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Overall Progress',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color:
                                        Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$pct%',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: plan.overallProgress,
                                backgroundColor:
                                    Colors.white.withOpacity(0.25),
                                valueColor:
                                    const AlwaysStoppedAnimation(
                                        Colors.white),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${plan.completedTasks} of ${plan.totalTasks} tasks completed',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Quick Tips ────────────────────────────────────
                    if (plan.quickTips.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFDE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFFF9C4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('💡',
                                    style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  'Quick Tips',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF795548),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...plan.quickTips.map((tip) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ',
                                          style: TextStyle(
                                              color:
                                                  Color(0xFF795548))),
                                      Expanded(
                                        child: Text(
                                          tip,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color:
                                                const Color(0xFF795548),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Growing Timeline ──────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Growing Timeline',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(plan.weeks.length, (weekIdx) {
                      final week = plan.weeks[weekIdx];
                      return _WeekSection(
                        week: week,
                        planId: plan.id,
                        weekIndex: weekIdx,
                      );
                    }),

                    const SizedBox(height: 20),

                    // ── Photos ────────────────────────────────────────
                    if (plan.photos.isNotEmpty) ...[
                      Text(
                        'Photos',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: plan.photos.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final photo = plan.photos[index];
                            // Use network URL if available, else local file
                            return GestureDetector(
                              onLongPress: () => _showDeletePhotoDialog(context, plan.id, photo),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: photo.storageUrl != null
                                    ? Image.network(
                                        photo.storageUrl!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _photoPlaceholder(),
                                      )
                                    : File(photo.imagePath).existsSync()
                                        ? Image.file(
                                            File(photo.imagePath),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )
                                        : _photoPlaceholder(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Notes ─────────────────────────────────────────
                    if (plan.notes.isNotEmpty) ...[
                      Text(
                        'Notes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...plan.notes.map((note) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: const Color(0xFFF0F0F0)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note.content,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(note.createdAt),
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.textHint),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => _showDeleteNoteDialog(context, plan.id, note),
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 8),
                    ],

                    // ── Add Photo / Note buttons ──────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.camera_alt_outlined,
                            label: 'Add Photo',
                            onTap: () => _pickPhoto(context, plan.id),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.description_outlined,
                            label: 'Add Note',
                            onTap: () =>
                                _showNoteDialog(context, plan.id),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _ActionButton(
                      icon: Icons.remove_circle_outline,
                      label: 'Remove Crop',
                      color: Colors.redAccent,
                      onTap: () => _showRemoveCropDialog(context, plan.id),
                    ),
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

  Widget _photoPlaceholder() => Container(
        width: 80,
        height: 80,
        color: AppColors.progressBg,
        child: const Icon(Icons.image_outlined,
            color: AppColors.textHint, size: 28),
      );

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _pickPhoto(BuildContext context, String planId) async {
    try {
      final picker = ImagePicker();
      final xFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (xFile != null && context.mounted) {
        await context.read<AppState>().addPhoto(planId, xFile.path);
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick photo. Please check gallery permissions.',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showNoteDialog(BuildContext context, String planId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Add Note',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Write your observation...',
            hintStyle:
                GoogleFonts.inter(color: AppColors.textHint),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                await context
                    .read<AppState>()
                    .addNote(planId, controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save',
                style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteNoteDialog(BuildContext context, String planId, CropNote note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Note?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this note?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AppState>().removeNote(planId, note.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeletePhotoDialog(BuildContext context, String planId, CropPhoto photo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Photo?', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to delete this photo?', style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AppState>().removePhoto(planId, photo.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRemoveCropDialog(BuildContext context, String planId) {
    String selectedReason = 'Crop completed / harvested';
    final customReasonCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Remove Crop', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Why are you removing this crop?', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    ...['Crop completed / harvested', 'Crop died / failed', 'Discontinued / no longer growing it', 'Space/resources no longer available', 'Other']
                        .map((reason) => RadioListTile<String>(
                              title: Text(reason, style: GoogleFonts.inter(fontSize: 13)),
                              value: reason,
                              groupValue: selectedReason,
                              activeColor: AppColors.primary,
                              contentPadding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              onChanged: (val) => setState(() => selectedReason = val!),
                            )),
                    if (selectedReason == 'Other') ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: customReasonCtrl,
                        decoration: InputDecoration(
                          hintText: 'Please specify...',
                          hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    if (context.mounted) {
                      await context.read<AppState>().removeCrop(planId, selectedReason, customReasonCtrl.text);
                      if (context.mounted) Navigator.pop(context); // Go back to dashboard
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Remove', style: GoogleFonts.inter(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

// ─── Week Section ─────────────────────────────────────────────────────────────

class _WeekSection extends StatelessWidget {
  final CropWeek week;
  final String planId;
  final int weekIndex;

  const _WeekSection({
    required this.week,
    required this.planId,
    required this.weekIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = week.isCurrentStage;
    final isDone = week.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primary
            : isDone
                ? AppColors.selectedBg
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? AppColors.primary
              : isDone
                  ? AppColors.selectedBorder.withOpacity(0.4)
                  : const Color(0xFFF0F0F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Week ${week.weekNumber}: ${week.title}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isCurrent
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Current stage',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (isDone && !isCurrent)
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 20),
              ],
            ),
          ),
          ...List.generate(week.tasks.length, (taskIdx) {
            final task = week.tasks[taskIdx];
            return _TaskRow(
              task: task,
              isCurrent: isCurrent,
              onTap: () => context
                  .read<AppState>()
                  .toggleTask(planId, weekIndex, taskIdx),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Task Row ─────────────────────────────────────────────────────────────────

class _TaskRow extends StatelessWidget {
  final CropTask task;
  final bool isCurrent;
  final VoidCallback onTap;

  const _TaskRow(
      {required this.task,
      required this.isCurrent,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? (isCurrent ? Colors.white : AppColors.primary)
                    : Colors.transparent,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.isCompleted
                      ? (isCurrent ? Colors.white : AppColors.primary)
                      : isCurrent
                          ? Colors.white.withOpacity(0.5)
                          : AppColors.cardBorder,
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: isCurrent
                          ? AppColors.primary
                          : Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                task.title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: task.isCompleted
                      ? (isCurrent
                          ? Colors.white.withOpacity(0.6)
                          : AppColors.textHint)
                      : (isCurrent
                          ? Colors.white
                          : AppColors.textPrimary),
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: isCurrent
                      ? Colors.white.withOpacity(0.6)
                      : AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color?.withOpacity(0.3) ?? AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color ?? AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteTag extends StatelessWidget {
  final String label;
  const _WhiteTag(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
