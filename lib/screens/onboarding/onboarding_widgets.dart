import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

// ─── Progress Bar ────────────────────────────────────────────────────────────

class OnboardingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final filled = index < currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: filled ? AppColors.primary : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Step Badge ──────────────────────────────────────────────────────────────

class StepBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const StepBadge({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF7EE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB2DFDB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single Choice Option (radio style) ──────────────────────────────────────

class SingleChoiceOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const SingleChoiceOption({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.selectedBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.selectedBorder : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
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
    );
  }
}

// ─── Multi Choice Option (checkbox style) ────────────────────────────────────

class MultiChoiceOption extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? badge;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? bgColor;
  final Color? borderColor;

  const MultiChoiceOption({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.isSelected,
    required this.onTap,
    this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeBg = bgColor ?? AppColors.selectedBg;
    final Color activeBorder = borderColor ?? AppColors.selectedBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? activeBorder : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row (with optional badge inline)
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Subtitle below title
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
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
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Continue / CTA Button ───────────────────────────────────────────────────

class ContinueButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const ContinueButton({
    super.key,
    this.label = 'Continue',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
