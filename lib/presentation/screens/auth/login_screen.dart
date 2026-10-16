import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/glass_container.dart';
import 'forgot_password_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/chat');
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nexora AI Logo & Title - Solid, clean, no gradients
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            color: colors.onPrimary,
                            size: 28,
                          ),
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          'Nexora AI',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Autonomous Multi-Agent Intelligence Client',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 32),

                      // Login Card - Solid card, no blurry glass/neon
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        backgroundColor: colors.card,
                        borderColor: colors.border,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),

                              AppTextField(
                                controller: _emailController,
                                labelText: 'Email Address',
                                hintText: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: colors.textMuted,
                                  size: 20,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!value.contains('@') || !value.contains('.')) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              AppTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: '••••••••',
                                obscureText: _obscurePassword,
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: colors.textMuted,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: colors.textMuted,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                                onSubmitted: (_) => _submit(),
                              ),

                              const SizedBox(height: 8),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => const ForgotPasswordDialog(),
                                    );
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: colors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              AppButton(
                                text: 'Sign In',
                                isLoading: isLoading,
                                onPressed: _submit,
                                width: double.infinity,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      // Switch to Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(color: colors.textSecondary, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: Text(
                              'Create one',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
