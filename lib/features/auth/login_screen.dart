import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  void _handleDemoLogin(UserRole role) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await ref.read(authStateProvider.notifier).loginAsDemo(role);

    if (mounted) {
      Navigator.pop(context); // Close loading indicator
      
      // Check auth result and redirect
      ref.read(authStateProvider).whenData((user) {
        if (user != null) {
          switch (user.role) {
            case UserRole.customer:
              context.go('/home');
              break;
            case UserRole.provider:
              context.go('/provider/dashboard');
              break;
            case UserRole.admin:
              if (kIsWeb) {
                context.go('/admin');
              } else {
                context.go('/admin-restricted');
              }
              break;
          }
        }
      });
    }
  }

  void _handleFormSubmit() {
    if (_formKey.currentState!.validate()) {
      // Simulate standard login as customer
      _handleDemoLogin(UserRole.customer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppDimensions.isDesktop(context) || AppDimensions.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildLoginForm() {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            AppSpacing.height4,
            Text(
              'Sign in to your Meetly account',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
            ),
            AppSpacing.height32,

            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            AppSpacing.height16,

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
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
            ),
            AppSpacing.height12,

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulated password reset email sent.')),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
            ),
            AppSpacing.height16,

            // Login Button
            ElevatedButton(
              onPressed: _handleFormSubmit,
              child: const Text('Sign In'),
            ),
            AppSpacing.height24,

            // Register Redirect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Register'),
                ),
              ],
            ),

            AppSpacing.height24,
            
            // Divider
            Row(
              children: [
                Expanded(child: Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'DEVELOPER QUICK ACCESS',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                          letterSpacing: 1.0,
                        ),
                  ),
                ),
                Expanded(child: Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
              ],
            ),
            AppSpacing.height16,

            // Demo Login Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.person_outline, size: 16),
                  label: const Text('Customer Demo'),
                  onPressed: () => _handleDemoLogin(UserRole.customer),
                ),
                ActionChip(
                  avatar: const Icon(Icons.business_center_outlined, size: 16),
                  label: const Text('Provider Demo'),
                  onPressed: () => _handleDemoLogin(UserRole.provider),
                ),
                if (kIsWeb)
                  ActionChip(
                    avatar: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                    label: const Text('Admin Demo'),
                    onPressed: () => _handleDemoLogin(UserRole.admin),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    if (isDesktop) {
      // Split Screen Layout for Web/Desktop
      return Scaffold(
        body: Row(
          children: [
            // Left Banner (Visuals & Brand Slogan)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryLight, AppColors.secondaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.hub_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      AppSpacing.height24,
                      Text(
                        'Meetly',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 56,
                            ),
                      ),
                      AppSpacing.height8,
                      Text(
                        'Connect. Collaborate. Grow.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      AppSpacing.height24,
                      Text(
                        'Discover local experts, compare verified reviews, and book services instantly on Kerala\'s modern booking platform.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Right Form Panel
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(64.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: buildLoginForm(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout (Standard single column)
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Branded small logo top
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primaryLight, AppColors.secondaryLight],
                        ),
                      ),
                      child: const Icon(
                        Icons.hub_outlined,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    AppSpacing.height12,
                    Text(
                      'Meetly',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ),
              AppSpacing.height32,
              
              // Login form container card
              Card(
                elevation: 0,
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderLarge,
                  side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: buildLoginForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
