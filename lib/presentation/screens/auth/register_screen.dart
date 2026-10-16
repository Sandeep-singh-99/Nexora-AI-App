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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              username: _usernameController.text.trim(),
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
                      // Header - Solid container, zero gradients
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.person_add_alt_1,
                            color: colors.onPrimary,
                            size: 28,
                          ),
                        ),
                      ).animate().scale(duration: 400.ms),
                      const SizedBox(height: 16),

                      Center(
                        child: Text(
                          'Join Nexora AI',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Create your agent workspace account',
                          style: TextStyle(color: colors.textSecondary, fontSize: 13),
                        ),
                      ),

                      const SizedBox(height: 28),

                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        backgroundColor: colors.card,
                        borderColor: colors.border,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                controller: _usernameController,
                                labelText: 'Username',
                                hintText: 'johndoe',
                                prefixIcon: Icon(Icons.person_outline, size: 20, color: colors.textMuted),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Enter a username';
                                  if (val.trim().length < 3) return 'At least 3 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              AppTextField(
                                controller: _emailController,
                                labelText: 'Email Address',
                                hintText: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icon(Icons.email_outlined, size: 20, color: colors.textMuted),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Enter your email';
                                  if (!val.contains('@')) return 'Invalid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              AppTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: '••••••••',
                                obscureText: _obscurePassword,
                                prefixIcon: Icon(Icons.lock_outline, size: 20, color: colors.textMuted),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    size: 20,
                                    color: colors.textMuted,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Enter a password';
                                  if (val.length < 6) return 'At least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              AppTextField(
                                controller: _confirmPasswordController,
                                labelText: 'Confirm Password',
                                hintText: '••••••••',
                                obscureText: _obscurePassword,
                                prefixIcon: Icon(Icons.lock_outline, size: 20, color: colors.textMuted),
                                validator: (val) {
                                  if (val != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                onSubmitted: (_) => _submit(),
                              ),

                              const SizedBox(height: 24),

                              AppButton(
                                text: 'Create Account',
                                isLoading: isLoading,
                                onPressed: _submit,
                                width: double.infinity,
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(color: colors.textSecondary, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              'Sign in',
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
