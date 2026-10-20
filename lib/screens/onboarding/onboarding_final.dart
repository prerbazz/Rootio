import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../data/app_state.dart';
import 'onboarding_widgets.dart';
import '../loading_screen.dart';

class OnboardingFinal extends StatefulWidget {
  const OnboardingFinal({super.key});

  @override
  State<OnboardingFinal> createState() => _OnboardingFinalState();
}

class _OnboardingFinalState extends State<OnboardingFinal> {
  final _nameController = TextEditingController();
  String _experience = '';
  String _climate = 'Not Sure';

  final List<Map<String, String>> _experienceOptions = [
    {'emoji': '🌱', 'title': 'Complete Beginner'},
    {'emoji': '🌿', 'title': 'Some Experience'},
    {'emoji': '🌳', 'title': 'Experienced'},
  ];

  final List<String> _climateOptions = [
    'Tropical',
    'Subtropical',
    'Temperate',
    'Arid',
    'Mediterranean',
    'Not Sure',
  ];

  bool get _isValid => _nameController.text.trim().isNotEmpty && _experience.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepBadge(label: 'Final Step', icon: Icons.person_outline),
                  const SizedBox(height: 16),
                  Text(
                    'Tell us about yourself',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Help us personalize your farming journey.',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    Text(
                      'What should we call you?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Your name',
                        hintStyle: GoogleFonts.inter(color: AppColors.textHint),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Experience level
                    Text(
                      'Your experience level',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_experienceOptions.length, (index) {
                      final option = _experienceOptions[index];
                      final isSelected = _experience == option['title'];
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < _experienceOptions.length - 1 ? 10 : 0),
                        child: GestureDetector(
                          onTap: () => setState(() => _experience = option['title']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.selectedBg : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.selectedBorder : AppColors.cardBorder,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(option['emoji']!, style: const TextStyle(fontSize: 22)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option['title']!,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.circle, color: Colors.white, size: 10)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Climate dropdown
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Your climate zone (optional)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _climate,
                          isExpanded: true,
                          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
                          onChanged: (val) => setState(() => _climate = val!),
                          items: _climateOptions
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'This helps us recommend region-specific crops',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            ContinueButton(
              label: 'Generate My Plans',
              onPressed: _isValid
                  ? () {
                      final state = context.read<AppState>();
                      state.onboarding.name = _nameController.text.trim();
                      state.onboarding.experienceLevel = _experience;
                      state.onboarding.climateZone = _climate;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoadingScreen()),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
