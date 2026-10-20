import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme.dart';
import '../../data/app_state.dart';
import 'onboarding_widgets.dart';
import 'onboarding_step3.dart';

class OnboardingStep2 extends StatefulWidget {
  const OnboardingStep2({super.key});

  @override
  State<OnboardingStep2> createState() => _OnboardingStep2State();
}

class _OnboardingStep2State extends State<OnboardingStep2> {
  final Set<String> _selected = {};

  final List<Map<String, String>> _options = [
    {'emoji': '🪴', 'title': 'Balcony', 'badge': 'Small', 'subtitle': 'Small pots & planters'},
    {'emoji': '🏠', 'title': 'Terrace/Rooftop', 'badge': 'Medium', 'subtitle': 'Medium-sized area'},
    {'emoji': '🪟', 'title': 'Indoor Space', 'badge': 'Small', 'subtitle': 'Windowsill or room'},
    {'emoji': '🌳', 'title': 'Backyard', 'badge': 'Large', 'subtitle': 'Ground planting'},
    {'emoji': '🤝', 'title': 'Community Garden', 'badge': 'Variable', 'subtitle': 'Shared plot'},
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
                  Expanded(child: OnboardingProgressBar(currentStep: 2, totalSteps: 4)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StepBadge(label: 'Step 2 of 4', icon: Icons.home_outlined),
                  const SizedBox(height: 16),
                  Text(
                    'Where will you grow?',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You can manage multiple spaces at once.',
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
                    emoji: option['emoji']!,
                    title: option['title']!,
                    subtitle: '',
                    badge: option['badge'],
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(option['title']);
                        } else {
                          _selected.add(option['title']!);
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
                      context.read<AppState>().onboarding.growingSpaces = _selected.toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnboardingStep3()),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
