import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Screens implemented in Phase 1
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';

// Screens implemented in Phase 2
import '../features/home/home_screen.dart';
import '../features/search/search_screen.dart';
import '../features/search/category_screen.dart';
import '../features/providers/provider_profile_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/profile/profile_screen.dart';

// Screens implemented in Phase 3
import '../features/bookings/booking_create_screen.dart';
import '../features/bookings/booking_details_screen.dart';
import '../features/bookings/bookings_history_screen.dart';

// Screens implemented in Phase 4
import '../features/chat/conversations_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/notifications/notifications_screen.dart';

// Screens implemented in Phase 5
import '../features/provider_portal/provider_dashboard_screen.dart';
import '../features/provider_portal/provider_services_screen.dart';
import '../features/provider_portal/provider_profile_screen.dart' as provider_portal;

// Screens implemented in Phase 6
import '../features/admin_portal/admin_dashboard_screen.dart';
import '../features/admin_portal/admin_providers_screen.dart';
import '../features/admin_portal/admin_bookings_screen.dart';
import '../features/admin_portal/admin_categories_screen.dart';
import '../features/admin_portal/admin_reviews_screen.dart';
import '../features/admin_portal/admin_restricted_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    
    // Customer Screens
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/category/:id',
      builder: (context, state) {
        final categoryId = state.pathParameters['id'] ?? '';
        return CategoryScreen(categoryId: categoryId);
      },
    ),
    // Provider Screens
    GoRoute(
      path: '/provider/dashboard',
      builder: (context, state) => const ProviderDashboardScreen(),
    ),
    GoRoute(
      path: '/provider/services',
      builder: (context, state) => const ProviderServicesScreen(),
    ),
    GoRoute(
      path: '/provider/availability',
      builder: (context, state) => const provider_portal.ProviderProfileScreen(),
    ),
    GoRoute(
      path: '/provider/bookings',
      builder: (context, state) => const BookingsHistoryScreen(),
    ),
    GoRoute(
      path: '/provider/profile',
      builder: (context, state) => const provider_portal.ProviderProfileScreen(),
    ),
    GoRoute(
      path: '/provider/:id',
      builder: (context, state) {
        final providerId = state.pathParameters['id'] ?? '';
        return ProviderProfileScreen(providerId: providerId);
      },
    ),
    GoRoute(
      path: '/booking/create',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return BookingCreateScreen(bookingArgs: args);
      },
    ),
    GoRoute(
      path: '/booking/:id',
      builder: (context, state) {
        final bookingId = state.pathParameters['id'] ?? '';
        return BookingDetailsScreen(bookingId: bookingId);
      },
    ),
    GoRoute(
      path: '/bookings',
      builder: (context, state) => const BookingsHistoryScreen(),
    ),
    GoRoute(
      path: '/messages',
      builder: (context, state) => const ConversationsScreen(),
    ),
    GoRoute(
      path: '/messages/:id',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        return ChatScreen(chatArgs: args);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    // Admin Screens
    GoRoute(
      path: '/admin-restricted',
      builder: (context, state) => const AdminRestrictedScreen(),
    ),
    GoRoute(
      path: '/admin',
      redirect: (context, state) {
        if (!kIsWeb) {
          return '/admin-restricted';
        }
        return null;
      },
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/providers',
      redirect: (context, state) {
        if (!kIsWeb) {
          return '/admin-restricted';
        }
        return null;
      },
      builder: (context, state) => const AdminProvidersScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      redirect: (context, state) {
        if (!kIsWeb) {
          return '/admin-restricted';
        }
        return null;
      },
      builder: (context, state) => const PlaceholderScreen(title: 'Manage Users'),
    ),
    GoRoute(
      path: '/admin/bookings',
      redirect: (context, state) {
        if (!kIsWeb) {
          return '/admin-restricted';
        }
        return null;
      },
      builder: (context, state) => const AdminBookingsScreen(),
    ),
    GoRoute(
      path: '/admin/categories',
      redirect: (context, state) {
        if (!kIsWeb) {
          return '/admin-restricted';
        }
        return null;
      },
      builder: (context, state) => const AdminCategoriesScreen(),
    ),
    GoRoute(
      path: '/admin/reviews',
      redirect: (context, state) {
        if (!kIsWeb) {
          return '/admin-restricted';
        }
        return null;
      },
      builder: (context, state) => const AdminReviewsScreen(),
    ),
  ],
);

// Unified Placeholder Screen for clean navigation tests
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  context.go('/login');
                }
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
