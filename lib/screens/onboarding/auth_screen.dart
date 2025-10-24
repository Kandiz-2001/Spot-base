import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../home/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    bool success;
    if (_isLogin) {
      success = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await authProvider.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Authentication failed',
        isError: true,
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Google sign in failed',
        isError: true,
      );
    }
  }

  Future<void> _signInWithApple() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signInWithApple();

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Apple sign in failed',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 50,
                      color: Colors.white,
                    ),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 300.ms),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  _isLogin
                      ? 'Sign in to continue discovering'
                      : 'Join the decentralized discovery platform',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 40),

                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                )
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 16),

                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: true,
                  validator: _isLogin ? null : Validators.validatePassword,
                )
                    .animate()
                    .fadeIn(delay: 500.ms)
                    .slideX(begin: -0.2, end: 0),

                if (!_isLogin) ...[
                  const SizedBox(height: 16),

                  // Confirm password field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: true,
                    validator: (value) => Validators.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                ],

                const SizedBox(height: 24),

                // Submit button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return GradientButton(
                      text: _isLogin ? 'Sign In' : 'Sign Up',
                      onPressed: _submit,
                      isLoading: authProvider.isLoading,
                      width: double.infinity,
                      height: 56,
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 700.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 24),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 800.ms),

                const SizedBox(height: 24),

                // Social login buttons
                CustomButton(
                  text: 'Continue with Google',
                  onPressed: _signInWithGoogle,
                  type: ButtonType.outlined,
                  icon: Icons.g_mobiledata,
                )
                    .animate()
                    .fadeIn(delay: 900.ms)
                    .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 12),

                CustomButton(
                  text: 'Continue with Apple',
                  onPressed: _signInWithApple,
                  type: ButtonType.outlined,
                  icon: Icons.apple,
                )
                    .animate()
                    .fadeIn(delay: 1000.ms)
                    .slideX(begin: -0.2, end: 0),

                const SizedBox(height: 24),

                // Toggle auth mode
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? "Don't have an account? "
                          : 'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin ? 'Sign Up' : 'Sign In',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 1100.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}