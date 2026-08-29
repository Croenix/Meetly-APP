import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/category_repository.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}
class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(categoryRepositoryProvider);
    await repo.addCategory(name);
    _categoryController.clear();
    
    // Refresh categories
    ref.invalidate(categoriesListProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category "$name" added successfully!')),
      );
    }
  }

  void _deleteCategory(String category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category?'),
          content: Text(
            'Are you sure you want to delete the category "$category"? All providers listed under this category will remain, but the category filter will be removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final repo = ref.read(categoryRepositoryProvider);
                await repo.deleteCategory(category);
                
                ref.invalidate(categoriesListProvider);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Category "$category" deleted.')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.errorLight),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final categoriesAsync = ref.watch(categoriesListProvider);

    return ResponsiveLayoutShell(
      selectedIndex: 3, // Admin Categories Tab Index
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Category Configurator'),
        ),
        body: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Category form header
              Text(
                'Add Service Category',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.height12,
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category name (e.g. Electrician, Plumbing)',
                        prefixIcon: Icon(Icons.add_circle_outline),
                      ),
                      onSubmitted: (_) => _addCategory(),
                    ),
                  ),
                  AppSpacing.width12,
                  ElevatedButton(
                    onPressed: _addCategory,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
              AppSpacing.height32,

              Text(
                'Active Service Categories',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.height12,

              // List of active categories
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const EmptyState(
                        icon: Icons.category_outlined,
                        title: 'No categories configured',
                        description: 'Please add a service category using the input field above.',
                      );
                    }

                    return ListView.separated(
                      itemCount: categories.length,
                      separatorBuilder: (context, index) => AppSpacing.height12,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        return Card(
                          elevation: 0.5,
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.category, color: AppColors.primaryLight, size: 18),
                            ),
                            title: Text(
                              cat,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.errorLight),
                              onPressed: () => _deleteCategory(cat),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Error loading categories', description: e.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
