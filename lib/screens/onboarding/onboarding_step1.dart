import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../data/app_state.dart';
import 'onboarding_widgets.dart';
import 'onboarding_step2.dart';

class OnboardingStep1 extends StatefulWidget {
  const OnboardingStep1({super.key});

  @override
  State<OnboardingStep1> createState() => _OnboardingStep1State();
}

class _OnboardingStep1State extends State<OnboardingStep1> {
  String _selected = '';

  final List<Map<String, String>> _options = [
    {'emoji': '⚡', 'title': '15 min/day', 'subtitle': 'Quick check-ins'},
    {'emoji': '🌤️', 'title': '30 min/day', 'subtitle': 'Light maintenance'},
    {'emoji': '☀️', 'title': '1 hour/day', 'subtitle': 'Active care'},
    {'emoji': '🔆', 'title': '2+ hours/day', 'subtitle': 'Deep involvement'},
    {'emoji': '📅', 'title': 'Weekends only', 'subtitle': 'Weekend warrior'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: OnboardingProgressBar(currentStep: 1, totalSteps: 4)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepBadge(label: 'Step 1 of 4', icon: Icons.access_time),
                  const SizedBox(height: 16),
                  Text(
                    'How much time can you invest?',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Select one. We'll match you with suitable crops.",
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
                      context.read<AppState>().onboarding.timeCommitment = _selected;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingStep2()),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
