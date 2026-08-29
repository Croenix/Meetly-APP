import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/repositories/auth_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Find local experts',
      description: 'Discover trusted professionals around you for any repair or service.',
      icon: Icons.person_search_outlined,
      gradientColors: [AppColors.primaryLight, AppColors.secondaryLight],
    ),
    OnboardingData(
      title: 'Connect with confidence',
      description: 'Compare ratings, detailed service items, and verified reviews before you book.',
      icon: Icons.reviews_outlined,
      gradientColors: [AppColors.secondaryLight, AppColors.accentLight],
    ),
    OnboardingData(
      title: 'Get things done',
      description: 'Book the right professional, chat instantly, and get your tasks resolved effortlessly.',
      icon: Icons.task_alt_outlined,
      gradientColors: [AppColors.accentLight, AppColors.primaryLight],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.setOnboardingCompleted(true);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App title
                  Text(
                    'Meetly',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  // Skip button (only shown if not on last page)
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text('Skip'),
                    )
                  else
                    const SizedBox(height: 38), // placeholder to balance layout
                ],
              ),
              
              // Slide Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Premium gradient vector card representing the feature
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: item.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            size: 110,
                            color: Colors.white,
                          ),
                        ),
                        
                        AppSpacing.height48,
                        
                        // Slide Title
                        Text(
                          item.title,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        AppSpacing.height16,
                        
                        // Slide Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            item.description,
                            style: textTheme.bodyLarge?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Action Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? AppColors.primaryLight
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                    ),
                  ),

                  // Action Button (Next / Get Started)
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: AppDimensions.borderCircular,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        ),
                        AppSpacing.width8,
                        Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check
                              : Icons.arrow_forward,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.height16,
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}
