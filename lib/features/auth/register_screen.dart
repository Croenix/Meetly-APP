import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/services/location_service.dart';
import 'login_screen.dart';

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
  final _confirmPasswordController = TextEditingController();

  String _selectedLocation = 'Kochi';
  UserRole _selectedRole = UserRole.customer;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeTerms = true;
  bool _isFetchingGps = false;

  final List<String> _locations = ['Kochi', 'Kottayam', 'Alappuzha', 'Thiruvalla', 'Changanassery'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms of Service & Privacy Policy.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ref.read(authStateProvider.notifier).register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : '+91 9895100001',
            _selectedLocation,
            _selectedRole,
          );

      if (mounted) {
        Navigator.pop(context);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = AppDimensions.isDesktop(context) || AppDimensions.isTablet(context);

    const primaryColor = Color(0xFF6C5CE7);
    const secondaryColor = Color(0xFF8C7CFF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0E17) : const Color(0xFFF7F6FE),
      body: Stack(
        children: [
          // Background Decorative Gradients & Dots
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Opacity(
              opacity: isDark ? 0.15 : 0.25,
              child: CustomPaint(
                size: const Size(100, 100),
                painter: DotGridPainter(color: primaryColor),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Header Row with Back Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        onPressed: () => context.go('/login'),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Container(
                        constraints: BoxConstraints(maxWidth: isDesktop ? 440 : 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Brand Icon Badge
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [primaryColor, secondaryColor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.hub_rounded,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),

                            Text(
                              'Meetly',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Create your account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Join Meetly and get started',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Elevated Form Card
                            Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : primaryColor.withValues(alpha: 0.07),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : primaryColor.withValues(alpha: 0.08),
                                  width: 1.5,
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Full name
                                    _buildInputField(
                                      controller: _nameController,
                                      label: 'Full name',
                                      icon: Icons.person_outline_rounded,
                                      isDark: isDark,
                                      validator: (v) => v == null || v.trim().isEmpty ? 'Enter your full name' : null,
                                    ),
                                    const SizedBox(height: 14),

                                    // Email address
                                    _buildInputField(
                                      controller: _emailController,
                                      label: 'Email address',
                                      icon: Icons.mail_outline_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      isDark: isDark,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) return 'Enter your email';
                                        if (!v.contains('@')) return 'Enter a valid email';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),

                                    // Location Selector with GPS
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            key: ValueKey(_selectedLocation),
                                            initialValue: _selectedLocation,
                                            isExpanded: true,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                                            ),
                                            decoration: InputDecoration(
                                              labelText: 'Location / City',
                                              labelStyle: TextStyle(
                                                fontSize: 13,
                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                              ),
                                              filled: true,
                                              fillColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF9F8FD),
                                              prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: primaryColor),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(16),
                                                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(16),
                                                borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA)),
                                              ),
                                            ),
                                            items: (_locations.contains(_selectedLocation) ? _locations : [_selectedLocation, ..._locations])
                                                .map((loc) => DropdownMenuItem(value: loc, child: Text(loc, overflow: TextOverflow.ellipsis)))
                                                .toList(),
                                            onChanged: (val) {
                                              if (val != null) setState(() => _selectedLocation = val);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: _isFetchingGps
                                              ? null
                                              : () async {
                                                  final messenger = ScaffoldMessenger.of(context);
                                                  setState(() => _isFetchingGps = true);
                                                  final locService = ref.read(locationServiceProvider);
                                                  final res = await locService.fetchCurrentLocation();
                                                  if (mounted) {
                                                    setState(() {
                                                      _isFetchingGps = false;
                                                      _selectedLocation = res.formattedAddress;
                                                    });
                                                    messenger.showSnackBar(
                                                      SnackBar(content: Text('GPS: ${res.formattedAddress}'), behavior: SnackBarBehavior.floating),
                                                    );
                                                  }
                                                },
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: primaryColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                                            ),
                                            child: Center(
                                              child: _isFetchingGps
                                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor))
                                                  : const Icon(Icons.my_location, color: primaryColor, size: 20),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // Password Field
                                    _buildInputField(
                                      controller: _passwordController,
                                      label: 'Password',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscurePassword,
                                      isDark: isDark,
                                      onChanged: (v) => setState(() {}),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: const Color(0xFF94A3B8)),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'Enter a password';
                                        if (v.length < 6) return 'At least 6 characters';
                                        return null;
                                      },
                                    ),

                                    // Password Strength Indicator
                                    _buildPasswordStrengthBar(_passwordController.text, primaryColor),
                                    const SizedBox(height: 14),

                                    // Confirm Password Field
                                    _buildInputField(
                                      controller: _confirmPasswordController,
                                      label: 'Confirm password',
                                      icon: Icons.lock_outline_rounded,
                                      obscureText: _obscureConfirmPassword,
                                      isDark: isDark,
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20, color: const Color(0xFF94A3B8)),
                                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'Confirm your password';
                                        if (v != _passwordController.text) return 'Passwords do not match';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 14),

                                    // Join Role Selection
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ChoiceChip(
                                            avatar: const Icon(Icons.person_outline, size: 16),
                                            label: const Text('Customer'),
                                            selected: _selectedRole == UserRole.customer,
                                            selectedColor: primaryColor.withValues(alpha: 0.15),
                                            labelStyle: TextStyle(color: _selectedRole == UserRole.customer ? primaryColor : null, fontWeight: FontWeight.bold, fontSize: 12),
                                            onSelected: (sel) {
                                              if (sel) setState(() => _selectedRole = UserRole.customer);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ChoiceChip(
                                            avatar: const Icon(Icons.work_outline, size: 16),
                                            label: const Text('Professional'),
                                            selected: _selectedRole == UserRole.provider,
                                            selectedColor: primaryColor.withValues(alpha: 0.15),
                                            labelStyle: TextStyle(color: _selectedRole == UserRole.provider ? primaryColor : null, fontWeight: FontWeight.bold, fontSize: 12),
                                            onSelected: (sel) {
                                              if (sel) setState(() => _selectedRole = UserRole.provider);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // Terms & Conditions Checkbox
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: Checkbox(
                                            value: _agreeTerms,
                                            activeColor: primaryColor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            onChanged: (val) => setState(() => _agreeTerms = val ?? true),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text.rich(
                                            TextSpan(
                                              text: 'I agree to the ',
                                              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                                              children: const [
                                                TextSpan(text: 'Terms of Service', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                                TextSpan(text: ' and '),
                                                TextSpan(text: 'Privacy Policy', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Main Create Account Button
                                    Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: const LinearGradient(
                                          colors: [primaryColor, secondaryColor],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: primaryColor.withValues(alpha: 0.35),
                                            blurRadius: 16,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: _handleRegister,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                            SizedBox(width: 8),
                                            Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Divider "or continue with"
                                    Row(
                                      children: [
                                        Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text('or continue with', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                                        ),
                                        Expanded(child: Divider(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Social Buttons
                                    _buildSocialButton(
                                      label: 'Continue with Google',
                                      icon: CustomPaint(size: const Size(18, 18), painter: GoogleLogoPainter()),
                                      isDark: isDark,
                                      onTap: _handleRegister,
                                    ),
                                    const SizedBox(height: 10),
                                    _buildSocialButton(
                                      label: 'Continue with Microsoft',
                                      icon: _buildMicrosoftIcon(),
                                      isDark: isDark,
                                      onTap: _handleRegister,
                                    ),
                                    const SizedBox(height: 20),

                                    // Already have account switcher
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Already have an account? ', style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                                        InkWell(
                                          onTap: () => context.go('/login'),
                                          child: const Text('Sign in', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryColor)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF9F8FD),
        prefixIcon: Icon(icon, size: 20, color: isDark ? const Color(0xFF8C7CFF) : const Color(0xFF6C5CE7)),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 1.8)),
      ),
    );
  }

  Widget _buildPasswordStrengthBar(String password, Color primaryColor) {
    if (password.isEmpty) return const SizedBox(height: 4);

    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 8 && RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (password.length >= 10 && RegExp(r'[0-9!@#\$%^&*]').hasMatch(password)) strength++;

    Color color;
    String text;
    if (strength <= 1) {
      color = const Color(0xFFF59E0B);
      text = 'Weak';
    } else if (strength == 2) {
      color = primaryColor;
      text = 'Medium';
    } else {
      color = const Color(0xFF10B981);
      text = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: strength >= 1 ? color : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: strength >= 2 ? color : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: strength >= 3 ? color : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          ],
        ),
        const SizedBox(height: 4),
        Text('Password strength: $text', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF334155))),
          ],
        ),
      ),
    );
  }

  Widget _buildMicrosoftIcon() {
    return SizedBox(
      width: 16,
      height: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 7, height: 7, color: const Color(0xFFF25022)),
              const SizedBox(width: 2),
              Container(width: 7, height: 7, color: const Color(0xFF7FBA00)),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 7, height: 7, color: const Color(0xFF00A4EF)),
              const SizedBox(width: 2),
              Container(width: 7, height: 7, color: const Color(0xFFFFB900)),
            ],
          ),
        ],
      ),
    );
  }
}
