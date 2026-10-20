import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import 'recommendation_selection_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnim;
  late Animation<double> _fadeAnim;

  int _completedSteps = 0;

  final List<String> _steps = [
    'Analyzing your inputs...',
    'Matching suitable crops...',
    'Building your plan...',
    'Saving to cloud...',
  ];

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _bounceAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _runSteps();
  }

  Future<void> _runSteps() async {
    final state = context.read<AppState>();

    // Step 1 — short visual delay
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _completedSteps = 1);

    // Step 2
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _completedSteps = 2);

    // Step 3 — complete onboarding: saves profile + initial plans to Firestore
    await state.completeOnboarding(state.onboarding);
    if (mounted) setState(() => _completedSteps = 3);

    // Step 4
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _completedSteps = 4);

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RecommendationSelectionScreen()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D6A2D), Color(0xFF3D8B3D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnim.value),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D8B3D),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 44),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'Creating Your Farm Plan',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will only take a moment...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ...List.generate(_steps.length, (i) {
                    final done = i < _completedSteps;
                    final active = i == _completedSteps;
                    return AnimatedOpacity(
                      opacity: done || active ? 1.0 : 0.3,
                      duration: const Duration(milliseconds: 400),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: done
                                    ? const Icon(Icons.check_circle_outline,
                                        color: Colors.white,
                                        size: 20,
                                        key: ValueKey('done'))
                                    : active
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            key: const ValueKey('loading'),
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white
                                                  .withOpacity(0.7),
                                            ),
                                          )
                                        : const SizedBox(
                                            width: 20,
                                            height: 20,
                                            key: ValueKey('pending'),
                                          ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _steps[i],
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
