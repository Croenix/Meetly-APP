import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/provider_card.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/provider_repository.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesListProvider);

    return ResponsiveLayoutShell(
      selectedIndex: 3, // Favorites tab index for customers
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Saved Professionals'),
        ),
        body: ResponsiveContainer(
          child: favoritesAsync.when(
            data: (favorites) {
              if (favorites.isEmpty) {
                return EmptyState(
                  icon: Icons.favorite_border,
                  title: 'No saved professionals yet',
                  description: 'Keep track of experts you trust. Tap the favorite heart icon on any profile or card to save them here.',
                  actionText: 'Explore Professionals',
                  onActionPressed: () {
                    context.go('/search');
                  },
                );
              }

              return ListView.separated(
                itemCount: favorites.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return ProviderCard(provider: favorites[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Error loading favorites',
              description: e.toString(),
            ),
          ),
        ),
      ),
    );
  }
}
