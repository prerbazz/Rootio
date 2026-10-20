import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/app_state.dart';
import 'dashboard_screen.dart';
import 'onboarding/onboarding_step1.dart';

class ReturningUserScreen extends StatelessWidget {
  const ReturningUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.history, color: AppColors.primary, size: 60),
              const SizedBox(height: 24),
              Text(
                'Welcome Back!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We found your previous farming data. Would you like to continue where you left off, or start a new farming session?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Continue Previous Farming', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  final state = context.read<AppState>();
                  await state.resetApp(); // Archives old session and clears local
                  if (context.mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingStep1()));
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Start New Farming Session', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
