import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'aarav.nair@meetly.in');
  final _passwordController = TextEditingController(text: 'password123');
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleDemoLogin(UserRole role) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await ref.read(authStateProvider.notifier).loginAsDemo(role);

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

  void _handleFormSubmit() {
    if (_formKey.currentState!.validate()) {
      _handleDemoLogin(UserRole.customer);
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
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Opacity(
              opacity: isDark ? 0.15 : 0.25,
              child: CustomPaint(
                size: const Size(100, 100),
                painter: DotGridPainter(color: primaryColor),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Container(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 440 : 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),

                      // Brand Icon Badge
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Brand Title & Subtitle
                      Text(
                        'Meetly',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Welcome back! ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const Text(
                            '👋',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to continue to your account',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 28),

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
                              // Email Input Field
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
                              const SizedBox(height: 16),

                              // Password Input Field
                              _buildInputField(
                                controller: _passwordController,
                                label: 'Password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                isDark: isDark,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Enter your password';
                                  if (v.length < 6) return 'At least 6 characters';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),

                              // Remember Me & Forgot Password Row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          onChanged: (val) {
                                            setState(() {
                                              _rememberMe = val ?? true;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Remember me',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Password reset link sent to your email.'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Main Sign In Action Button
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
                                  onPressed: _handleFormSubmit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Divider "or continue with"
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'or continue with',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Social Buttons
                              _buildSocialButton(
                                label: 'Continue with Google',
                                icon: CustomPaint(
                                  size: const Size(18, 18),
                                  painter: GoogleLogoPainter(),
                                ),
                                isDark: isDark,
                                onTap: () => _handleDemoLogin(UserRole.customer),
                              ),
                              const SizedBox(height: 12),
                              _buildSocialButton(
                                label: 'Continue with Microsoft',
                                icon: _buildMicrosoftIcon(),
                                isDark: isDark,
                                onTap: () => _handleDemoLogin(UserRole.customer),
                              ),
                              const SizedBox(height: 22),

                              // Register Switcher Text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account? ",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => context.go('/register'),
                                    child: const Text(
                                      'Register',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
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
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : const Color(0xFF1E293B),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF9F8FD),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: isDark ? const Color(0xFF8C7CFF) : const Color(0xFF6C5CE7),
        ),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF6C5CE7),
            width: 1.8,
          ),
        ),
      ),
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
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF334155),
              ),
            ),
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

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double center = w / 2;
    final double radius = w / 2;
    final double strokeWidth = w * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Blue right arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius - strokeWidth / 2),
      -0.5,
      2.2,
      false,
      paint,
    );

    // Green bottom arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius - strokeWidth / 2),
      1.7,
      1.3,
      false,
      paint,
    );

    // Yellow left arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius - strokeWidth / 2),
      3.0,
      1.0,
      false,
      paint,
    );

    // Red top arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center, center), radius: radius - strokeWidth / 2),
      4.0,
      1.8,
      false,
      paint,
    );

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(center, center - strokeWidth / 2, radius - strokeWidth / 4, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DotGridPainter extends CustomPainter {
  final Color color;
  DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const double spacing = 12.0;
    const double dotRadius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
