import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.sidebarBackground,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -100,
                      left: -100,
                      child: Container(
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset('assets/logos/logo.png', height: 32, width: 32),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  'INVENTORY GUARD',
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 60),
                            Text(
                              'Begin your journey\nto perfect management.',
                              style: GoogleFonts.outfit(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Join thousands of businesses scaling with our\nnext-gen inventory ecosystem.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                color: Colors.white60,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 48),
                            _buildFeatureItem(Icons.auto_awesome_rounded, 'AI-Powered Stock Predictions'),
                            _buildFeatureItem(Icons.security_rounded, 'Military-Grade Audit Logs'),
                            _buildFeatureItem(Icons.sync_rounded, 'Real-time Global Sync'),
                            const SizedBox(height: 60),
                            Text(
                              '© saifeldeen 2026. All rights reserved.',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white24, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isDesktop) ...[
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Image.asset('assets/logos/logo.png', height: 32, width: 32),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          'Create account',
                          style: GoogleFonts.outfit(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Join our community and manage your assets.',
                          style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 15),
                        ),
                        const SizedBox(height: 40),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'John Doe',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email address',
                          hint: 'name@company.com',
                          icon: Icons.alternate_email_rounded,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_open_rounded,
                          isPassword: true,
                        ),
                        const SizedBox(height: 40),
                        BlocConsumer<AuthCubit, AuthState>(
                          listener: (context, state) {
                            if (state is Authenticated) {
                              Navigator.pop(context);
                            }
                            if (state is AuthError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is AuthLoading ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthCubit>().signUp(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    _nameController.text.trim(),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              child: state is AuthLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text('Create Account', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Already have an account?', style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary)),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Sign in instead',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.accent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: GoogleFonts.plusJakartaSans(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (v) => v!.isEmpty ? 'This field is required' : (isPassword && v.length < 6 ? 'Min 6 characters' : null),
        ),
      ],
    );
  }
}
