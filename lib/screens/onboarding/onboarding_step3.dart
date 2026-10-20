import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../data/app_state.dart';
import 'onboarding_widgets.dart';
import 'onboarding_step4.dart';

class OnboardingStep3 extends StatefulWidget {
  const OnboardingStep3({super.key});

  @override
  State<OnboardingStep3> createState() => _OnboardingStep3State();
}

class _OnboardingStep3State extends State<OnboardingStep3> {
  String _selected = '';

  final List<Map<String, String>> _options = [
    {'emoji': '🚿', 'title': 'Tap Water', 'subtitle': 'Easy access, daily use'},
    {'emoji': '🪣', 'title': 'Stored Water', 'subtitle': 'Tanks or containers'},
    {'emoji': '🌧️', 'title': 'Rainwater', 'subtitle': 'Seasonal collection'},
    {'emoji': '💧', 'title': 'Limited Access', 'subtitle': 'Need water-efficient plans'},
  ];

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
                  const SizedBox(width: 12),
                  Expanded(child: OnboardingProgressBar(currentStep: 3, totalSteps: 4)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepBadge(label: 'Step 3 of 4', icon: Icons.water_drop_outlined),
                  const SizedBox(height: 16),
                  Text(
                    'Water availability?',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'This helps us recommend crops that match your setup.',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final option = _options[index];
                  return SingleChoiceOption(
                    emoji: option['emoji']!,
                    title: option['title']!,
                    subtitle: option['subtitle']!,
                    isSelected: _selected == option['title'],
                    onTap: () => setState(() => _selected = option['title']!),
                  );
                },
              ),
            ),

            ContinueButton(
              onPressed: _selected.isEmpty
                  ? null
                  : () {
                      context.read<AppState>().onboarding.waterAvailability = _selected;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingStep4()),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
