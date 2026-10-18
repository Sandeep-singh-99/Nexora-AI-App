import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/haptic_utils.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

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

  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _usernameHasFocus = false;
  bool _emailHasFocus = false;
  bool _passwordHasFocus = false;
  bool _confirmPasswordHasFocus = false;

  @override
  void initState() {
    super.initState();
    _usernameFocus.addListener(() => setState(() => _usernameHasFocus = _usernameFocus.hasFocus));
    _emailFocus.addListener(() => setState(() => _emailHasFocus = _emailFocus.hasFocus));
    _passwordFocus.addListener(() => setState(() => _passwordHasFocus = _passwordFocus.hasFocus));
    _confirmPasswordFocus.addListener(() => setState(() => _confirmPasswordHasFocus = _confirmPasswordFocus.hasFocus));

    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticUtils.mediumImpact();
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

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final hasMinLength = password.length >= 6;
    final passwordsMatch = password.isNotEmpty && password == confirmPassword;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/chat');
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: colors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Emblem & Title
                      Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: colors.border, width: 1.5),
                          ),
                          child: Icon(
                            Icons.person_add_alt_1_rounded,
                            color: colors.textPrimary,
                            size: 28,
                          ),
                        ),
                      ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),

                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          'Create your account',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 6),

                      Center(
                        child: Text(
                          'Join Nexora for autonomous multi-agent intelligence',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 28),

                      // Card Form
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: colors.border, width: 1),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Username Label
                              Text(
                                'USERNAME',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Username Input
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _usernameHasFocus
                                        ? colors.primary.withValues(alpha: 0.45)
                                        : colors.border,
                                    width: _usernameHasFocus ? 1.5 : 1.0,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _usernameController,
                                  focusNode: _usernameFocus,
                                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'alex_nexora',
                                    hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                                    prefixIcon: Icon(
                                      Icons.alternate_email_rounded,
                                      color: _usernameHasFocus ? colors.textPrimary : colors.textMuted,
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'Enter a username';
                                    if (val.trim().length < 3) return 'At least 3 characters';
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Email Label
                              Text(
                                'EMAIL ADDRESS',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Email Input
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _emailHasFocus
                                        ? colors.primary.withValues(alpha: 0.45)
                                        : colors.border,
                                    width: _emailHasFocus ? 1.5 : 1.0,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'name@example.com',
                                    hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                                    prefixIcon: Icon(
                                      Icons.mail_outline_rounded,
                                      color: _emailHasFocus ? colors.textPrimary : colors.textMuted,
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) return 'Enter your email';
                                    if (!val.contains('@') || !val.contains('.')) return 'Invalid email';
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Password Label
                              Text(
                                'PASSWORD',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Password Input
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _passwordHasFocus
                                        ? colors.primary.withValues(alpha: 0.45)
                                        : colors.border,
                                    width: _passwordHasFocus ? 1.5 : 1.0,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  obscureText: _obscurePassword,
                                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Minimum 6 characters',
                                    hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: _passwordHasFocus ? colors.textPrimary : colors.textMuted,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: colors.textMuted,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        HapticUtils.selectionClick();
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return 'Enter a password';
                                    if (val.length < 6) return 'At least 6 characters';
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Confirm Password Label
                              Text(
                                'CONFIRM PASSWORD',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Confirm Password Input
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _confirmPasswordHasFocus
                                        ? colors.primary.withValues(alpha: 0.45)
                                        : colors.border,
                                    width: _confirmPasswordHasFocus ? 1.5 : 1.0,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  focusNode: _confirmPasswordFocus,
                                  obscureText: _obscureConfirmPassword,
                                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Repeat password',
                                    hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
                                    prefixIcon: Icon(
                                      Icons.lock_reset_rounded,
                                      color: _confirmPasswordHasFocus ? colors.textPrimary : colors.textMuted,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: colors.textMuted,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        HapticUtils.selectionClick();
                                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                      },
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  ),
                                  validator: (val) {
                                    if (val != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) => _submit(),
                                ),
                              ),

                              // Dynamic password strength & matching feedback
                              if (password.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      hasMinLength ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      size: 14,
                                      color: hasMinLength ? colors.success : colors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '6+ characters',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: hasMinLength ? colors.success : colors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    if (confirmPassword.isNotEmpty) ...[
                                      Icon(
                                        passwordsMatch ? Icons.check_circle_rounded : Icons.cancel_outlined,
                                        size: 14,
                                        color: passwordsMatch ? colors.success : colors.error,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        passwordsMatch ? 'Passwords match' : 'No match',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: passwordsMatch ? colors.success : colors.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],

                              const SizedBox(height: 24),

                              // Submit Button
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    disabledBackgroundColor: colors.border,
                                    disabledForegroundColor: colors.textMuted,
                                  ),
                                  child: isLoading
                                      ? SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor: AlwaysStoppedAnimation<Color>(colors.onPrimary),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Create Account',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: colors.onPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.arrow_forward_rounded, size: 18, color: colors.onPrimary),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0),

                      const SizedBox(height: 24),

                      // Sign in toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              HapticUtils.lightImpact();
                              context.go('/login');
                            },
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
                      ).animate().fadeIn(delay: 250.ms),

                      const SizedBox(height: 16),

                      // Terms & Policy
                      Center(
                        child: Text(
                          'By continuing, you agree to Nexora Terms & Privacy Policy.',
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
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
