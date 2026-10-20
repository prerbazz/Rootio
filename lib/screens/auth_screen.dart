import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/firebase_service.dart';
import '../data/app_state.dart';
import 'onboarding/onboarding_step1.dart';
// ignore: unused_import
import 'dashboard_screen.dart';
import 'returning_user_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePass = true;
  String _error = '';

  final FirebaseService _firebase = FirebaseService();

  Future<void> _handleAuth() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      if (_isLogin) {
        await _firebase.signInWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      } else {
        await _firebase.registerWithEmail(_emailCtrl.text.trim(), _passCtrl.text);
      }
      await _checkNextStep();
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('invalid-credential')) {
        errorMessage = 'Incorrect email or password. If you signed in with Google previously, please use "Continue with Google".';
      } else if (errorMessage.contains('email-already-in-use')) {
        errorMessage = 'An account with this email already exists. Try signing in instead.';
      } else if (errorMessage.contains('weak-password')) {
        errorMessage = 'Your password is too weak. Please use a stronger password.';
      }
      setState(() => _error = errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final cred = await _firebase.signInWithGoogle();
      if (cred != null) {
        await _checkNextStep();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkNextStep() async {
    final state = context.read<AppState>();
    await state.signInAndLoad(); 
    
    if (!mounted) return;

    if (state.profile == null) {
      // New user
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingStep1()));
    } else {
      // Returning user
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReturningUserScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FAF0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.eco, color: AppColors.primary, size: 60),
              const SizedBox(height: 16),
              Text(
                'Welcome to Rootio',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Sign in to continue your farming journey' : 'Create an account to start farming',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 40),
              if (_error.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(_error, style: GoogleFonts.inter(color: Colors.red, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: AppColors.textHint),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_isLogin ? 'Sign In' : 'Create Account', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Need an account? Register' : 'Already have an account? Sign In',
                  style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: GoogleFonts.inter(color: AppColors.textHint, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: Image.network('https://img.icons8.com/color/48/000000/google-logo.png', height: 24),
                label: Text('Continue with Google', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
