import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/business_listing.dart';
import '../../core/services/sync_service.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';

final businessDirectoryProvider = FutureProvider.autoDispose<List<BusinessListing>>((ref) async {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.fetchBusinessDirectory();
});

class DirectorySearchScreen extends ConsumerStatefulWidget {
  const DirectorySearchScreen({super.key});

  @override
  ConsumerState<DirectorySearchScreen> createState() => _DirectorySearchScreenState();
}

class _DirectorySearchScreenState extends ConsumerState<DirectorySearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedPincode = 'All';
  String _selectedCategory = 'All';

  final List<String> _pincodes = [
    'All', '682001', '682002', '682011', '682016', '682020', '682030', '682035', '683101', '673001', '695001'
  ];

  final List<String> _categories = [
    'All', 'Electricians', 'Plumbers', 'Mechanics', 'Schools', 'Hospitals', 'Cleaners', 'Painters', 'Carpenters', 'Tutors'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final directoryAsync = ref.watch(businessDirectoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF6C5CE7);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Business Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.refresh(businessDirectoryProvider),
            tooltip: 'Refresh Local Cache',
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
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search business name, address, or pincode...',
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

                    // Pincode Filter Horizontal List
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
                              children: _pincodes.map((pin) {
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

              // Directory Items List
              Expanded(
                child: directoryAsync.when(
                  data: (listings) {
                    final filtered = listings.where((item) {
                      final matchesSearch = _searchQuery.isEmpty ||
                          item.name.toLowerCase().contains(_searchQuery) ||
                          item.address.toLowerCase().contains(_searchQuery) ||
                          item.pincode.contains(_searchQuery) ||
                          item.category.toLowerCase().contains(_searchQuery);

                      final matchesPin = _selectedPincode == 'All' || item.pincode == _selectedPincode;
                      final matchesCat = _selectedCategory == 'All' || item.category.toLowerCase() == _selectedCategory.toLowerCase();

                      return matchesSearch && matchesPin && matchesCat;
                    }).toList();

                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No Matching Businesses Found',
                        description: 'Try selecting a different pincode or category filter.',
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return Container(
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
                                      Text(
                                        '${item.category} • PIN ${item.pincode}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
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
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Offline Mode',
                    description: 'Loading local business directory cache...',
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
      default:
        return Icons.business_rounded;
    }
  }
}
