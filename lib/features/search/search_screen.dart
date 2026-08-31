import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/service_provider.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/provider_card.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/provider_repository.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _showMobileMap = false;
  ServiceProvider? _selectedMapProvider;

  // Filter values
  double _maxDistance = 15.0;
  bool _onlyVerified = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ServiceProvider> _filterResults(List<ServiceProvider> providers) {
    if (_query.isEmpty) {
      return providers.where((p) {
        if (_onlyVerified && !p.verified) return false;
        if (p.distance > _maxDistance) return false;
        return true;
      }).toList();
    }

    final lowerQuery = _query.toLowerCase();
    return providers.where((p) {
      final matchesSearch = p.businessName.toLowerCase().contains(lowerQuery) ||
          p.profession.toLowerCase().contains(lowerQuery) ||
          p.category.toLowerCase().contains(lowerQuery) ||
          p.bio.toLowerCase().contains(lowerQuery);

      if (!matchesSearch) return false;
      if (_onlyVerified && !p.verified) return false;
      if (p.distance > _maxDistance) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(providersListProvider);
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
          title: const Text('Find Services'),
        ),
        body: ResponsiveContainer(
          usePadding: false,
          child: Column(
            children: [
              // Search Input & Quick Filters Bar
              _buildSearchBar(isDark, textTheme),

              Expanded(
                child: providersAsync.when(
                  data: (providers) {
                    final results = _filterResults(providers);

                    if (isDesktop) {
                      // Desktop Split Layout: Cards list on Left, Interactive Vector Map on Right
                      return Row(
                        children: [
                          // Left results column
                          Expanded(
                            flex: 4,
                            child: _buildResultsList(results, textTheme, isDark),
                          ),
                          // Right Map column
                          Expanded(
                            flex: 5,
                            child: _buildMapSection(results, isDark, textTheme),
                          ),
                        ],
                      );
                    }

                    // Mobile Layout: Results List or Full-Screen Map based on toggle
                    return Stack(
                      children: [
                        // Results List View
                        _buildResultsList(results, textTheme, isDark),

                        // Overlay Map View if toggled
                        if (_showMobileMap)
                          Positioned.fill(
                            child: _buildMapSection(results, isDark, textTheme),
                          ),

                        // Floating Toggle Button
                        Positioned(
                          bottom: 24,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                setState(() {
                                  _showMobileMap = !_showMobileMap;
                                  _selectedMapProvider = null; // reset selection
                                });
                              },
                              icon: Icon(_showMobileMap ? Icons.list : Icons.map),
                              label: Text(_showMobileMap ? 'Show List' : 'Map View'),
                              backgroundColor: AppColors.primaryLight,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error loading search: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Column(
        children: [
          // Text Input Row
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _query = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search electrician, plumber, AC, computer, makeup...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _query = '';
                        });
                      },
                    )
                  : null,
            ),
          ),
          AppSpacing.height12,
          
          // Quick Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  avatar: const Icon(Icons.verified, size: 16),
                  label: const Text('Verified Pros'),
                  selected: _onlyVerified,
                  onSelected: (val) {
                    setState(() {
                      _onlyVerified = val;
                    });
                  },
                ),
                AppSpacing.width12,
                FilterChip(
                  avatar: const Icon(Icons.location_on, size: 16),
                  label: Text('Within ${_maxDistance.toStringAsFixed(0)} km'),
                  selected: _maxDistance < 15.0,
                  onSelected: (val) {
                    setState(() {
                      _maxDistance = val ? 5.0 : 15.0; // Quick toggle between 5km and 15km
                    });
                  },
                ),
                AppSpacing.width12,
                ActionChip(
                  avatar: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('Reset Filters'),
                  onPressed: () {
                    setState(() {
                      _onlyVerified = false;
                      _maxDistance = 15.0;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<ServiceProvider> results, TextTheme textTheme, bool isDark) {
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off_outlined,
        title: 'No professionals found',
        description: 'Try searching for other keywords (e.g. plumber, computer, Rajesh) or widen your distance filter.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (context, index) => AppSpacing.height16,
      itemBuilder: (context, index) {
        return ProviderCard(provider: results[index]);
      },
    );
  }

  Widget _buildMapSection(List<ServiceProvider> results, bool isDark, TextTheme textTheme) {
    // We create a visual mock map background using custom containers and vectors
    return Stack(
      children: [
        // Map Grid Background
        Container(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          child: CustomPaint(
            painter: MapPainter(isDark: isDark),
            child: Container(),
          ),
        ),

        // User Location Pin (Center)
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.my_location,
              color: AppColors.primaryLight,
              size: 20,
            ),
          ),
        ),

        // Provider Pins (Positioned based on index-based offset calculations)
        for (int i = 0; i < results.length; i++)
          _buildMapPin(results[i], i, results.length),

        // Map Float Info Tag (Top-left instructions)
        Positioned(
          top: 16,
          left: 16,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Live Map Discovery Mode',
                style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),

        // Selected Provider Details Overlay Card (Bottom)
        if (_selectedMapProvider != null)
          Positioned(
            bottom: AppDimensions.isDesktop(context) ? 24 : 88,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderMedium,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AppAvatar(
                      url: _selectedMapProvider!.portfolioImages.first,
                      name: _selectedMapProvider!.businessName,
                      size: 50,
                    ),
                    AppSpacing.width16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedMapProvider!.businessName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _selectedMapProvider!.profession,
                            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: AppColors.warningLight),
                              const SizedBox(width: 4),
                              Text('${_selectedMapProvider!.rating}'),
                              const SizedBox(width: 8),
                              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
                              const SizedBox(width: 4),
                              Text('${_selectedMapProvider!.distance} km'),
                            ],
                          )
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/provider/${_selectedMapProvider!.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      child: const Text('Details'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapPin(ServiceProvider provider, int index, int total) {
    // Generate deterministic relative coordinates around center based on provider ID / index
    final double radius = 80.0 + (index * 15.0);
    final double angle = (index * 2.39996) * 3.14159265; // Golden angle spiral
    final double dx = radius * 1.5 * MathHelper.cos(angle);
    final double dy = radius * MathHelper.sin(angle);

    final isSelected = _selectedMapProvider?.id == provider.id;

    return Center(
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedMapProvider = provider;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: isSelected
                    ? AppColors.secondaryLight
                    : (provider.verified ? AppColors.primaryLight : Colors.blueGrey),
                size: isSelected ? 42 : 34,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  provider.businessName.split(' ').first,
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Math Helpers for Dart trig without adding math library
class MathHelper {
  static double sin(double radians) {
    // Simple Taylor series approximation for sin
    double term = radians;
    double sum = radians;
    double r2 = radians * radians;
    for (int i = 1; i <= 4; i++) {
      term = -term * r2 / ((2 * i) * (2 * i + 1));
      sum += term;
    }
    return sum;
  }

  static double cos(double radians) {
    // Simple Taylor series approximation for cos
    double term = 1.0;
    double sum = 1.0;
    double r2 = radians * radians;
    for (int i = 1; i <= 4; i++) {
      term = -term * r2 / ((2 * i - 1) * (2 * i));
      sum += term;
    }
    return sum;
  }
}

// Custom Painter to draw stylized roads, green areas, and parks for mock map
class MapPainter extends CustomPainter {
  final bool isDark;

  MapPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final parkPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFD9F99D) // dark slate / light green
      ..style = PaintingStyle.fill;

    final waterPaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFFBAE6FD) // deep dark / light blue water
      ..style = PaintingStyle.fill;

    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final minorRoadPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Draw Parks
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 0.35, size.height * 0.25), parkPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.75), 80, parkPaint);

    // Draw Rivers/Lakes
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(size.width * 0.3, size.height * 0.85, size.width * 0.5, size.height * 0.6, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, waterPaint);

    // Draw main roads grid
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.55), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, 0), Offset(size.width * 0.45, size.height), roadPaint);

    // Minor roads
    canvas.drawLine(Offset(0, size.height * 0.2), Offset(size.width, size.height * 0.18), minorRoadPaint);
    canvas.drawLine(Offset(size.width * 0.2, 0), Offset(size.width * 0.25, size.height), minorRoadPaint);
    canvas.drawLine(Offset(size.width * 0.8, 0), Offset(size.width * 0.78, size.height), minorRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
