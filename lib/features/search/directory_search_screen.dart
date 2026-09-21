import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/business_listing.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/location_service.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../home/home_screen.dart';
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

    final detectedPincode = userLoc?.pincode ?? extractPincodeFromAddress(textLoc);

    final directoryQuery = StoreDirectoryQuery(
      pincode: _selectedPincode,
      category: _selectedCategory,
      search: _searchQuery,
    );

    final directoryAsync = ref.watch(storeDirectoryProvider(directoryQuery));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF6C5CE7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Business Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(serverPincodesProvider);
              ref.invalidate(storeDirectoryProvider(directoryQuery));
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
                    // GPS / Detected Pincode Banner
                    if (detectedPincode != null && detectedPincode.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.gps_fixed_rounded, size: 16, color: primaryColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'GPS Location: ${userLoc?.locality ?? "Your Area"} (PIN $detectedPincode)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            if (_selectedPincode != detectedPincode)
                              TextButton(
                                onPressed: () {
                                  setState(() => _selectedPincode = detectedPincode);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Filter by My PIN', style: TextStyle(fontSize: 11)),
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
                        hintText: 'Search shop name, address, or category...',
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

              // Directory Items List from MongoDB Server
              Expanded(
                child: directoryAsync.when(
                  data: (listings) {
                    final filtered = listings.where((item) {
                      final matchesSearch = _searchQuery.isEmpty ||
                          item.name.toLowerCase().contains(_searchQuery) ||
                          item.address.toLowerCase().contains(_searchQuery) ||
                          item.pincode.contains(_searchQuery) ||
                          item.category.toLowerCase().contains(_searchQuery);

                      final matchesPin = _selectedPincode == 'All' || item.pincode.trim() == _selectedPincode.trim();
                      final matchesCat = _selectedCategory == 'All' || item.category.toLowerCase() == _selectedCategory.toLowerCase();

                      return matchesSearch && matchesPin && matchesCat;
                    }).toList();

                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.storefront_outlined,
                        title: _selectedPincode != 'All'
                            ? 'No Shops Found in PIN $_selectedPincode'
                            : 'No Shops Found for Selected Filters',
                        description: _selectedPincode != 'All'
                            ? 'No businesses are currently listed under PIN $_selectedPincode. Tap below to view all available businesses across Kerala.'
                            : 'Try selecting a different category or clearing search filters.',
                        actionText: _selectedPincode != 'All' ? 'View All Kerala Shops' : 'Reset Filters',
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

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StoreDetailScreen(store: item),
                              ),
                            );
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
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(item.category),
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
                                                item.name,
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
                                            if (item.isOpenNow) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'OPEN',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.address,
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
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Server Offline',
                    description: 'Loading local shop directory cache...',
                  ),
                ),
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
