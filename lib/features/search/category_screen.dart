import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/service_provider.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/provider_card.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/provider_repository.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryScreen({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  // Filter States
  double _maxDistance = 10.0;
  double _minRating = 0.0;
  double _maxPrice = 10000.0;
  bool _onlyVerified = false;
  String _sortBy = 'recommended'; // recommended, nearest, top_rated, lowest_price

  void _resetFilters() {
    setState(() {
      _maxDistance = 10.0;
      _minRating = 0.0;
      _maxPrice = 10000.0;
      _onlyVerified = false;
    });
  }

  List<ServiceProvider> _applyFiltersAndSort(List<ServiceProvider> originalList) {
    // 1. Filter
    var filtered = originalList.where((p) {
      if (p.distance > _maxDistance) return false;
      if (p.rating < _minRating) return false;
      if (p.startingPrice > _maxPrice) return false;
      if (_onlyVerified && !p.verified) return false;
      return true;
    }).toList();

    // 2. Sort
    switch (_sortBy) {
      case 'nearest':
        filtered.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case 'top_rated':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'lowest_price':
        filtered.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
        break;
      case 'recommended':
      default:
        // Sort by verified first, then by rating
        filtered.sort((a, b) {
          if (a.verified && !b.verified) return -1;
          if (!a.verified && b.verified) return 1;
          return b.rating.compareTo(a.rating);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(categoryProvidersProvider(widget.categoryId));
    final isDesktop = AppDimensions.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return ResponsiveLayoutShell(
      selectedIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
          title: Text('${widget.categoryId}s near you'),
        ),
        body: ResponsiveContainer(
          usePadding: false,
          child: providersAsync.when(
            data: (providers) {
              final processedList = _applyFiltersAndSort(providers);

              if (isDesktop) {
                // Desktop View: Split Sidebar Filters & Main Results Grid
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar Filters Panel (Left)
                    Container(
                      width: 280,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        border: Border(
                          right: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Filters', style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: _resetFilters,
                                child: const Text('Reset'),
                              ),
                            ],
                          ),
                          const Divider(),
                          AppSpacing.height16,
                          _buildFilterWidgets(isDark, textTheme),
                        ],
                      ),
                    ),
                    
                    // Results Grid Panel (Right)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildResultsHeader(processedList.length, textTheme),
                            AppSpacing.height24,
                            Expanded(
                              child: processedList.isEmpty
                                  ? const EmptyState(
                                      icon: Icons.filter_list_off,
                                      title: 'No results match filters',
                                      description: 'Try adjusting your sliders or unticking the verified-only checkbox.',
                                    )
                                  : GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 420,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent: 220,
                                      ),
                                      itemCount: processedList.length,
                                      itemBuilder: (context, index) {
                                        return ProviderCard(provider: processedList[index]);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Mobile View: Single column scrolling with action bar
              return Column(
                children: [
                  // Mobile Filter & Sort Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      border: Border(
                        bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Sort Dropdown
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              icon: const Icon(Icons.sort, size: 16),
                              items: const [
                                DropdownMenuItem(value: 'recommended', child: Text('Recommended')),
                                DropdownMenuItem(value: 'nearest', child: Text('Nearest')),
                                DropdownMenuItem(value: 'top_rated', child: Text('Top Rated')),
                                DropdownMenuItem(value: 'lowest_price', child: Text('Lowest Price')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _sortBy = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 32),
                        // Filter sheet trigger
                        TextButton.icon(
                          onPressed: () => _showMobileFilterSheet(context),
                          icon: const Icon(Icons.filter_list, size: 16),
                          label: const Text('Filters'),
                        ),
                      ],
                    ),
                  ),

                  // Header status
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing ${processedList.length} results',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
                      ),
                    ),
                  ),

                  // Results List
                  Expanded(
                    child: processedList.isEmpty
                        ? const EmptyState(
                            icon: Icons.filter_list_off,
                            title: 'No results match filters',
                            description: 'Try adjusting your filters to discover professionals.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: processedList.length,
                            separatorBuilder: (context, index) => AppSpacing.height16,
                            itemBuilder: (context, index) {
                              return ProviderCard(provider: processedList[index]);
                            },
                          ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => EmptyState(
              icon: Icons.error_outline,
              title: 'Error loading providers',
              description: e.toString(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(int count, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing $count results',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        
        // Desktop Sort
        Row(
          children: [
            const Text('Sort by:  ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _sortBy,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'recommended', child: Text('Recommended')),
                DropdownMenuItem(value: 'nearest', child: Text('Nearest')),
                DropdownMenuItem(value: 'top_rated', child: Text('Top Rated')),
                DropdownMenuItem(value: 'lowest_price', child: Text('Lowest Price')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _sortBy = val;
                  });
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterWidgets(bool isDark, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verified Filter
        SwitchListTile(
          title: const Text('Verified Pros Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          contentPadding: EdgeInsets.zero,
          value: _onlyVerified,
          onChanged: (val) {
            setState(() {
              _onlyVerified = val;
            });
          },
        ),
        AppSpacing.height16,

        // Distance Slider
        Text(
          'Max Distance: ${_maxDistance.toStringAsFixed(0)} km',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Slider(
          value: _maxDistance,
          min: 1.0,
          max: 20.0,
          divisions: 19,
          onChanged: (val) {
            setState(() {
              _maxDistance = val;
            });
          },
        ),
        AppSpacing.height16,

        // Rating selector
        const Text(
          'Minimum Rating',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        AppSpacing.height8,
        Wrap(
          spacing: 6,
          children: [0.0, 4.0, 4.5, 4.8].map((rating) {
            final isSelected = _minRating == rating;
            return ChoiceChip(
              label: Text(rating == 0.0 ? 'All' : '$rating ⭐'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _minRating = rating;
                  });
                }
              },
            );
          }).toList(),
        ),
        AppSpacing.height16,

        // Price slider
        Text(
          'Max Starting Price: ₹${_maxPrice.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Slider(
          value: _maxPrice,
          min: 100.0,
          max: 10000.0,
          divisions: 99,
          onChanged: (val) {
            setState(() {
              _maxPrice = val;
            });
          },
        ),
      ],
    );
  }

  void _showMobileFilterSheet(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Results',
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            _resetFilters();
                            setSheetState(() {});
                            setState(() {});
                          },
                          child: const Text('Reset All'),
                        ),
                      ],
                    ),
                    const Divider(),
                    AppSpacing.height16,

                    // Verified toggle
                    SwitchListTile(
                      title: const Text('Verified Pros Only', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      contentPadding: EdgeInsets.zero,
                      value: _onlyVerified,
                      onChanged: (val) {
                        setSheetState(() => _onlyVerified = val);
                        setState(() => _onlyVerified = val);
                      },
                    ),
                    AppSpacing.height16,

                    // Distance Slider
                    Text(
                      'Max Distance: ${_maxDistance.toStringAsFixed(0)} km',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Slider(
                      value: _maxDistance,
                      min: 1.0,
                      max: 20.0,
                      divisions: 19,
                      onChanged: (val) {
                        setSheetState(() => _maxDistance = val);
                        setState(() => _maxDistance = val);
                      },
                    ),
                    AppSpacing.height16,

                    // Rating Chips
                    const Text(
                      'Minimum Rating',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    AppSpacing.height8,
                    Wrap(
                      spacing: 6,
                      children: [0.0, 4.0, 4.5, 4.8].map((rating) {
                        final isSelected = _minRating == rating;
                        return ChoiceChip(
                          label: Text(rating == 0.0 ? 'All' : '$rating ⭐'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setSheetState(() => _minRating = rating);
                              setState(() => _minRating = rating);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    AppSpacing.height16,

                    // Price Slider
                    Text(
                      'Max Starting Price: ₹${_maxPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Slider(
                      value: _maxPrice,
                      min: 100.0,
                      max: 10000.0,
                      divisions: 99,
                      onChanged: (val) {
                        setSheetState(() => _maxPrice = val);
                        setState(() => _maxPrice = val);
                      },
                    ),
                    AppSpacing.height24,

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
