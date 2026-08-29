import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedLocation = 'Kochi';
  UserRole _selectedRole = UserRole.customer;
  bool _obscurePassword = true;

  final List<String> _locations = ['Kochi', 'Kottayam', 'Alappuzha', 'Thiruvalla', 'Changanassery'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ref.read(authStateProvider.notifier).register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _phoneController.text.trim(),
            _selectedLocation,
            _selectedRole,
          );

      if (mounted) {
        Navigator.pop(context); // Close loading indicator

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
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppDimensions.isDesktop(context) || AppDimensions.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildRegisterForm() {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Create account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            AppSpacing.height4,
            Text(
              'Join Meetly to connect and grow',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
            ),
            AppSpacing.height24,

            // Full Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            AppSpacing.height16,

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

            // Phone Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your 10-digit number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            AppSpacing.height16,

            // Location Selector Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location / City',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              items: _locations.map((loc) {
                return DropdownMenuItem<String>(
                  value: loc,
                  child: Text(loc),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedLocation = val;
                  });
                }
              },
            ),
            AppSpacing.height16,

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a password',
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
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            AppSpacing.height24,

            // Role selection Segmented/Radios
            Text(
              'Join as:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppSpacing.height8,
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.person_outline, size: 16),
                    label: const Text('Customer'),
                    selected: _selectedRole == UserRole.customer,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedRole = UserRole.customer;
                        });
                      }
                    },
                  ),
                ),
                AppSpacing.width12,
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.business_center_outlined, size: 16),
                    label: const Text('Professional'),
                    selected: _selectedRole == UserRole.provider,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedRole = UserRole.provider;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            AppSpacing.height24,

            // Register Button
            ElevatedButton(
              onPressed: _handleRegister,
              child: const Text('Create Account'),
            ),
            AppSpacing.height24,

            // Redirect back to Login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Left Banner
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondaryLight, AppColors.accentLight],
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
                        'Join Meetly',
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
                        'Sign up today to explore thousands of vetted professionals, hire local experts for your needs, or list your business to find new customers.',
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
                    child: buildRegisterForm(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout
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
                          colors: [AppColors.secondaryLight, AppColors.accentLight],
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
              AppSpacing.height24,

              Card(
                elevation: 0,
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderLarge,
                  side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: buildRegisterForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
