import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../data/app_state.dart';
import '../splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final profile = state.profile;
        final name = profile?.name ?? state.onboarding.name;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // ── Header ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.primary,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    right: 16,
                    bottom: 20,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings & Profile',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Edit your farming preferences',
                              style: GoogleFonts.inter(
                                fontSize: 12,
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

              // ── Profile avatar ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.primary,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.selectedBg,
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : 'F',
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name.isNotEmpty ? name : 'Farmer',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            profile?.experienceLevel ?? '',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Settings sections ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Personal ──
                    _SectionHeader('Personal'),
                    _EditableTile(
                      icon: Icons.person_outline,
                      title: 'Your Name',
                      value: profile?.name ?? '',
                      onSave: (val) => _save(
                          context, state, () => state.updateProfile(name: val)),
                    ),

                    // ── Farming Setup ──
                    _SectionHeader('Farming Setup'),
                    _SingleChoiceTile(
                      icon: Icons.access_time_outlined,
                      title: 'Daily Time Available',
                      value: profile?.timeCommitment ?? '',
                      options: const [
                        '15 min/day',
                        '30 min/day',
                        '1 hour/day',
                        '2+ hours/day',
                        'Weekends only',
                      ],
                      onSave: (val) => _save(context, state,
                          () => state.updateProfile(timeCommitment: val)),
                    ),
                    _MultiChoiceTile(
                      icon: Icons.home_outlined,
                      title: 'Growing Location',
                      values: profile?.growingSpaces ?? [],
                      options: const [
                        'Balcony',
                        'Terrace/Rooftop',
                        'Indoor Space',
                        'Backyard',
                        'Community Garden',
                      ],
                      onSave: (vals) => _save(context, state,
                          () => state.updateProfile(growingSpaces: vals)),
                    ),
                    _SingleChoiceTile(
                      icon: Icons.water_drop_outlined,
                      title: 'Water Availability',
                      value: profile?.waterAvailability ?? '',
                      options: const [
                        'Tap Water',
                        'Stored Water',
                        'Rainwater',
                        'Limited Access',
                      ],
                      onSave: (val) => _save(context, state,
                          () => state.updateProfile(waterAvailability: val)),
                    ),
                    _SingleChoiceTile(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Experience Level',
                      value: profile?.experienceLevel ?? '',
                      options: const [
                        'Complete Beginner',
                        'Some Experience',
                        'Experienced',
                      ],
                      onSave: (val) => _save(context, state,
                          () => state.updateProfile(experienceLevel: val)),
                    ),
                    _SingleChoiceTile(
                      icon: Icons.location_on_outlined,
                      title: 'Climate Zone',
                      value: profile?.climateZone ?? 'Not Sure',
                      options: const [
                        'Tropical',
                        'Subtropical',
                        'Temperate',
                        'Arid',
                        'Mediterranean',
                        'Not Sure',
                      ],
                      onSave: (val) => _save(context, state,
                          () => state.updateProfile(climateZone: val)),
                    ),
                    _MultiChoiceTile(
                      icon: Icons.flag_outlined,
                      title: 'Farming Goals',
                      values: profile?.goals ?? [],
                      options: const [
                        'Hobby & Learning',
                        'Fresh Food',
                        'Extra Income',
                        'Wellness & Therapy',
                        'Help Environment',
                      ],
                      onSave: (vals) => _save(
                          context, state, () => state.updateProfile(goals: vals)),
                    ),

                    // ── Data ──
                    _SectionHeader('Data & Account'),
                    _ActionTile(
                      icon: Icons.delete_forever_outlined,
                      title: 'Reset App / Start New Farm',
                      subtitle: 'Archive current farming session and start a new one',
                      color: Colors.redAccent,
                      onTap: () => _confirmResetApp(context, state),
                    ),
                    _ActionTile(
                      icon: Icons.logout,
                      title: 'Sign Out',
                      subtitle: 'Sign out of your account',
                      color: Colors.grey.shade600,
                      onTap: () async {
                        await state.signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const SplashScreen()),
                            (route) => false,
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Version info
                    Center(
                      child: Text(
                        'Rootio v1.0.0 · Intelligent Farming Companion',
                        style: GoogleFonts.inter(
                            fontSize: 11, color: AppColors.textHint),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(BuildContext context, AppState state,
      Future<void> Function() action) async {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved!',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _confirmResetApp(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Start New Farming Session?',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          'This will archive your current farming session and return you to the onboarding screen to start a new farming session. Your account and history are not deleted.',
          style: GoogleFonts.inter(
              fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await state.resetApp();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Start New Session',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textHint,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Editable Text Tile ───────────────────────────────────────────────────────

class _EditableTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Future<void> Function(String) onSave;

  const _EditableTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      title: title,
      subtitle: value.isNotEmpty ? value : 'Tap to set',
      onTap: () => _showEditDialog(context),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: value);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $title',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.inter(fontSize: 15),
          decoration: InputDecoration(
            hintText: title,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final val = controller.text.trim();
              if (val.isNotEmpty) {
                Navigator.pop(ctx);
                await onSave(val);
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
}

// ─── Single Choice Tile ───────────────────────────────────────────────────────

class _SingleChoiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final List<String> options;
  final Future<void> Function(String) onSave;

  const _SingleChoiceTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      title: title,
      subtitle: value.isNotEmpty ? value : 'Tap to set',
      onTap: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    String selected = value;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...options.map((opt) => GestureDetector(
                    onTap: () => setModalState(() => selected = opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected == opt
                            ? AppColors.selectedBg
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected == opt
                              ? AppColors.primary
                              : AppColors.cardBorder,
                          width: selected == opt ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(opt,
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ),
                          if (selected == opt)
                            const Icon(Icons.check_circle,
                                color: AppColors.primary, size: 18),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    if (selected.isNotEmpty) await onSave(selected);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text('Save',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Multi Choice Tile ────────────────────────────────────────────────────────

class _MultiChoiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> values;
  final List<String> options;
  final Future<void> Function(List<String>) onSave;

  const _MultiChoiceTile({
    required this.icon,
    required this.title,
    required this.values,
    required this.options,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: icon,
      title: title,
      subtitle: values.isNotEmpty ? values.join(', ') : 'Tap to set',
      onTap: () => _showPicker(context),
    );
  }

  void _showPicker(BuildContext context) {
    final selected = Set<String>.from(values);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Select all that apply',
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final isSel = selected.contains(opt);
                return GestureDetector(
                  onTap: () => setModalState(() {
                    if (isSel) {
                      selected.remove(opt);
                    } else {
                      selected.add(opt);
                    }
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          isSel ? AppColors.selectedBg : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.cardBorder,
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(opt,
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500))),
                        if (isSel)
                          const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await onSave(selected.toList());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text('Save',
                      style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Action Tile (logout, reset) ──────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color)),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Generic Settings Tile ────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.selectedBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }
}
