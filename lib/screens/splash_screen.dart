import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../data/app_state.dart';
import 'onboarding/onboarding_step1.dart';
import 'dashboard_screen.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;


  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _animController.forward();

    Future.delayed(const Duration(milliseconds: 1200), _boot);
  }

  Future<void> _boot() async {
    final state = context.read<AppState>();
    
    // Attempt auto-login if Firebase session exists
    await state.init();
    
    if (mounted) {
      if (state.isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AuthScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0FAF0),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // ── Logo ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.eco,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rootio',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Illustration ─────────────────────────────────────────
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4EDDA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Text('🌱',
                          style: TextStyle(fontSize: 72)),
                      Positioned(
                        top: 10,
                        right: 20,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF5A623),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Start Your Farming Journey',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    "From balcony gardens to backyard farms, we'll guide you every step of the way",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      _FeatureCard(
                          icon: Icons.auto_awesome, label: 'Smart Plans'),
                      const SizedBox(width: 10),
                      _FeatureCard(
                          icon: Icons.trending_up, label: 'Track Growth'),
                      const SizedBox(width: 10),
                      _FeatureCard(
                          icon: Icons.favorite_border,
                          label: 'Learn Daily'),
                    ],
                  ),
                ),

                const Spacer(),



                // ── Get Started ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const OnboardingStep1()),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.inter(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'No experience needed • Free to start',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8F5E9)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
