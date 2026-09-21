import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/business_listing.dart';
import '../../core/models/service_provider.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/location_service.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../data/repositories/provider_repository.dart';
import 'store_detail_screen.dart';

class StoreDirectoryQuery {
  final String pincode;
  final String category;
  final String search;

  const StoreDirectoryQuery({
    this.pincode = 'All',
    this.category = 'All',
    this.search = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreDirectoryQuery &&
          runtimeType == other.runtimeType &&
          pincode == other.pincode &&
          category == other.category &&
          search == other.search;

  @override
  int get hashCode => Object.hash(pincode, category, search);
}

final serverPincodesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.fetchServerPincodes();
});

final storeDirectoryProvider = FutureProvider.family.autoDispose<List<BusinessListing>, StoreDirectoryQuery>((ref, query) async {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.fetchBusinessDirectory(
    pincode: query.pincode,
    category: query.category,
    search: query.search,
  );
});

enum UnifiedSearchResultType { store, provider }

class UnifiedSearchItem {
  final UnifiedSearchResultType type;
  final String id;
  final String title;
  final String category;
  final String pincode;
  final String locationText;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final BusinessListing? store;
  final ServiceProvider? provider;

  UnifiedSearchItem.fromStore(BusinessListing s)
      : type = UnifiedSearchResultType.store,
        id = s.id,
        title = s.name,
        category = s.category,
        pincode = s.pincode,
        locationText = '${s.city} • PIN ${s.pincode}',
        rating = s.rating,
        reviewCount = s.reviewCount,
        isOpen = s.isOpenNow,
        store = s,
        provider = null;

  UnifiedSearchItem.fromProvider(ServiceProvider p, {String? activePin})
      : type = UnifiedSearchResultType.provider,
        id = p.id,
        title = p.businessName.isNotEmpty ? p.businessName : p.profession,
        category = p.category,
        pincode = extractPincodeFromAddress(p.location) ??
            extractPincodeFromAddress(p.serviceArea) ??
            activePin ??
            '682001',
        locationText = '${p.location} • ₹${p.startingPrice.toInt()} starting',
        rating = p.rating,
        reviewCount = p.reviewCount,
        isOpen = true,
        store = null,
        provider = p;
}

class DirectorySearchScreen extends ConsumerStatefulWidget {
  final String? initialPincode;
  const DirectorySearchScreen({super.key, this.initialPincode});

  @override
  ConsumerState<DirectorySearchScreen> createState() => _DirectorySearchScreenState();
}

class _DirectorySearchScreenState extends ConsumerState<DirectorySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPincode = 'All';
  String _selectedCategory = 'All';
  bool _initializedUserPincode = false;

  final List<String> _categories = [
    'All',
    'Electricians',
    'Plumbers',
    'Mechanics',
    'Schools',
    'Hospitals',
    'Cleaners',
    'Painters',
    'Carpenters',
    'Tutors',
    'Stores',
    'Supermarkets',
    'Electronics',
    'Hardware',
    'Pharmacies'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPincode != null && widget.initialPincode!.trim().isNotEmpty) {
      _selectedPincode = widget.initialPincode!.trim();
      _initializedUserPincode = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndSetUserLocationPincode();
    });
  }

  void _checkAndSetUserLocationPincode() {
    if (_initializedUserPincode) return;
    
    final userLoc = ref.read(userLocationStateProvider);
    final textLoc = ref.read(selectedLocationProvider);

    String? pin = userLoc?.pincode;
    if (pin == null || pin.isEmpty) {
      pin = extractPincodeFromAddress(textLoc);
    }

    if (pin != null && pin.length == 6) {
      setState(() {
        _selectedPincode = pin!;
        _initializedUserPincode = true;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serverPinsAsync = ref.watch(serverPincodesProvider);
    final userLoc = ref.watch(userLocationStateProvider);
    final textLoc = ref.watch(selectedLocationProvider);

    final detectedPincode = userLoc?.pincode ?? extractPincodeFromAddress(textLoc) ?? '682001';

    final directoryQuery = StoreDirectoryQuery(
      pincode: 'All',
      category: 'All',
      search: '',
    );

    final directoryAsync = ref.watch(storeDirectoryProvider(directoryQuery));
    final providersAsync = ref.watch(providersListProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF6C5CE7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Directory & Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(serverPincodesProvider);
              ref.invalidate(storeDirectoryProvider(directoryQuery));
              ref.invalidate(providersListProvider);
            },
            tooltip: 'Refresh Server Directory',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          usePadding: false,
          child: Column(
            children: [
              // Search & Filter Header Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF8FAFC),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF2D2D3F) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Active Location Pincode Banner
                    if (detectedPincode.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 20, color: primaryColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Location: ${userLoc?.locality ?? (textLoc ?? "Selected Area")} (PIN $detectedPincode)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Results matching PIN $detectedPincode are automatically ranked at the top',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search services, pros, shops, or categories...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF14141F) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Dynamic Pincode Filter Horizontal List
                    Row(
                      children: [
                        Text(
                          'Pincode: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ChoiceChip(
                                  label: const Text('All'),
                                  selected: _selectedPincode == 'All',
                                  onSelected: (selected) {
                                    if (selected) setState(() => _selectedPincode = 'All');
                                  },
                                  selectedColor: primaryColor,
                                  labelStyle: TextStyle(
                                    color: _selectedPincode == 'All'
                                        ? Colors.white
                                        : (isDark ? Colors.white70 : Colors.black87),
                                    fontSize: 11,
                                    fontWeight: _selectedPincode == 'All' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(width: 6),
                                ...serverPinsAsync.when(
                                  data: (pins) {
                                    final displayPins = pins.contains(_selectedPincode) || _selectedPincode == 'All'
                                        ? pins
                                        : [_selectedPincode, ...pins];
                                    return displayPins.map((pin) {
                                      final isSelected = _selectedPincode == pin;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 6),
                                        child: ChoiceChip(
                                          label: Text(pin),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            if (selected) {
                                              setState(() => _selectedPincode = pin);
                                            }
                                          },
                                          selectedColor: primaryColor,
                                          labelStyle: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark ? Colors.white70 : Colors.black87),
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      );
                                    }).toList();
                                  },
                                  loading: () => [
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  ],
                                  error: (err, stack) => ['682001', '682002', '682030', '683101'].map((pin) {
                                    final isSelected = _selectedPincode == pin;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        label: Text(pin),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected) setState(() => _selectedPincode = pin);
                                        },
                                        selectedColor: primaryColor,
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                          fontSize: 11,
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Category Filter Horizontal List
                    Row(
                      children: [
                        Text(
                          'Category: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories.map((cat) {
                                final isSelected = _selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(cat),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedCategory = cat);
                                      }
                                    },
                                    selectedColor: primaryColor,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Unified Search Results List (Services + Shops with Pincode Ranking)
              Expanded(
                child: directoryAsync.when(
                  data: (stores) {
                    final List<ServiceProvider> providersList = providersAsync.value ?? [];

                    // Wrap into Unified Items
                    final List<UnifiedSearchItem> allItems = [
                      ...stores.map((s) => UnifiedSearchItem.fromStore(s)),
                      ...providersList.map((p) => UnifiedSearchItem.fromProvider(p, activePin: detectedPincode)),
                    ];

                    // Apply Search Query & Category Filters
                    final filtered = allItems.where((item) {
                      final matchesSearch = _searchQuery.isEmpty ||
                          item.title.toLowerCase().contains(_searchQuery) ||
                          item.category.toLowerCase().contains(_searchQuery) ||
                          item.locationText.toLowerCase().contains(_searchQuery) ||
                          item.pincode.contains(_searchQuery);

                      bool matchesCat = true;
                      if (_selectedCategory != 'All') {
                        final catLower = _selectedCategory.toLowerCase();
                        matchesCat = item.category.toLowerCase().contains(catLower) ||
                            (item.store?.secondaryCategories.any((c) => c.toLowerCase().contains(catLower)) ?? false);
                      }

                      bool matchesPinChoice = true;
                      if (_selectedPincode != 'All') {
                        matchesPinChoice = item.pincode.trim() == _selectedPincode.trim();
                      }

                      return matchesSearch && matchesCat && matchesPinChoice;
                    }).toList();

                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.search_off_rounded,
                        title: _selectedPincode != 'All'
                            ? 'No Services or Shops Found in PIN $_selectedPincode'
                            : 'No Search Results Found',
                        description: _selectedPincode != 'All'
                            ? 'No matches found in PIN $_selectedPincode. Tap below to search all available services and stores across Kerala.'
                            : 'Try searching with a different keyword or resetting category filters.',
                        actionText: _selectedPincode != 'All' ? 'View All Kerala Directory' : 'Reset Filters',
                        onActionPressed: () {
                          setState(() {
                            _selectedPincode = 'All';
                            _selectedCategory = 'All';
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      );
                    }

                    // --- PINCODE PRIORITIZATION RANKING ---
                    // Target PIN for top ranking section
                    final targetPin = (_selectedPincode != 'All') ? _selectedPincode : detectedPincode;

                    final List<UnifiedSearchItem> topPinResults = [];
                    final List<UnifiedSearchItem> otherResults = [];

                    for (final item in filtered) {
                      if (item.pincode.trim() == targetPin.trim()) {
                        topPinResults.add(item);
                      } else {
                        otherResults.add(item);
                      }
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // SECTION 1: TOP MATCHES IN ACTIVE LOCATION PINCODE
                        if (topPinResults.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '📍 TOP MATCHES IN YOUR AREA (PIN $targetPin)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${topPinResults.length} near you)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...topPinResults.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildUnifiedCard(context, item, isDark, primaryColor),
                              )),
                          const SizedBox(height: 16),
                        ],

                        // SECTION 2: OTHER MATCHES ACROSS KERALA
                        if (otherResults.isNotEmpty) ...[
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '🌐 OTHER SERVICES & BUSINESSES ACROSS KERALA',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${otherResults.length} other areas)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...otherResults.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildUnifiedCard(context, item, isDark, primaryColor),
                              )),
                        ],
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Server Offline',
                    description: 'Loading local shop & service directory cache...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedCard(
    BuildContext context,
    UnifiedSearchItem item,
    bool isDark,
    Color primaryColor,
  ) {
    final isProvider = item.type == UnifiedSearchResultType.provider;
    final tagBg = isProvider
        ? (isDark ? const Color(0xFF4C1D95) : const Color(0xFFDDD6FE))
        : (isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0));
    final tagText = isProvider
        ? (isDark ? const Color(0xFFDDD6FE) : const Color(0xFF5B21B6))
        : (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF064E3B));

    return InkWell(
      onTap: () {
        if (isProvider && item.provider != null) {
          context.push('/provider/${item.provider!.id}');
        } else if (item.store != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoreDetailScreen(store: item.store!),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2D2D3F) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isProvider ? Icons.engineering_rounded : _getCategoryIcon(item.category),
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                item.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Type Badge (Service Pro vs Store)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isProvider ? 'SERVICE PRO' : 'STORE',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: tagText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PIN ${item.pincode}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.locationText,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electricians':
      case 'electrician':
        return Icons.electrical_services_rounded;
      case 'plumbers':
      case 'plumber':
        return Icons.plumbing_rounded;
      case 'mechanics':
      case 'mechanic':
        return Icons.build_rounded;
      case 'schools':
      case 'school':
        return Icons.school_rounded;
      case 'hospitals':
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'cleaners':
      case 'cleaner':
        return Icons.cleaning_services_rounded;
      case 'tutors':
      case 'tutor':
        return Icons.menu_book_rounded;
      case 'stores':
      case 'supermarkets':
      case 'hardware':
      case 'electronics':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }
}
