import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../data/app_state.dart';
import 'onboarding_widgets.dart';
import 'onboarding_final.dart';

class OnboardingStep4 extends StatefulWidget {
  const OnboardingStep4({super.key});

  @override
  State<OnboardingStep4> createState() => _OnboardingStep4State();
}

class _OnboardingStep4State extends State<OnboardingStep4> {
  final Set<String> _selected = {};

  final List<Map<String, dynamic>> _options = [
    {
      'emoji': '🌱',
      'title': 'Hobby & Learning',
      'subtitle': 'Enjoy the process',
      'bg': AppColors.goalBlue,
      'border': AppColors.goalBlueBorder,
    },
    {
      'emoji': '🥗',
      'title': 'Fresh Food',
      'subtitle': 'Grow your own produce',
      'bg': AppColors.goalGreen,
      'border': AppColors.goalGreenBorder,
    },
    {
      'emoji': '💰',
      'title': 'Extra Income',
      'subtitle': 'Sell surplus harvest',
      'bg': AppColors.goalYellow,
      'border': AppColors.goalYellowBorder,
    },
    {
      'emoji': '🧘',
      'title': 'Wellness & Therapy',
      'subtitle': 'Mental wellbeing',
      'bg': AppColors.goalPurple,
      'border': AppColors.goalPurpleBorder,
    },
    {
      'emoji': '🌍',
      'title': 'Help Environment',
      'subtitle': 'Sustainability focus',
      'bg': AppColors.goalTeal,
      'border': AppColors.goalTealBorder,
    },
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
                  Expanded(child: OnboardingProgressBar(currentStep: 4, totalSteps: 4)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepBadge(label: 'Step 4 of 4', icon: Icons.flag_outlined),
                  const SizedBox(height: 16),
                  Text(
                    'What are your goals?',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select all that resonate with you. No wrong answers!',
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
                  final isSelected = _selected.contains(option['title']);
                  return MultiChoiceOption(
                    emoji: option['emoji'] as String,
                    title: option['title'] as String,
                    subtitle: option['subtitle'] as String,
                    isSelected: isSelected,
                    bgColor: option['bg'] as Color,
                    borderColor: option['border'] as Color,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(option['title']);
                        } else {
                          _selected.add(option['title'] as String);
                        }
                      });
                    },
                  );
                },
              ),
            ),

            ContinueButton(
              onPressed: _selected.isEmpty
                  ? null
                  : () {
                      context.read<AppState>().onboarding.goals = _selected.toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingFinal()),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
