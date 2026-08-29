import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/service_provider.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/provider_repository.dart';

class AdminProvidersScreen extends ConsumerStatefulWidget {
  const AdminProvidersScreen({super.key});

  @override
  ConsumerState<AdminProvidersScreen> createState() => _AdminProvidersScreenState();
}

class _AdminProvidersScreenState extends ConsumerState<AdminProvidersScreen> {
  String _filter = 'pending'; // pending, verified, all

  void _vetProvider(ServiceProvider provider, String action) async {
    final repo = ref.read(providerRepositoryProvider);
    final updated = provider.copyWith(
      verificationStatus: action == 'approve' ? 'verified' : 'unverified',
    );
    await repo.updateProviderProfile(updated);
    
    // Invalidate state to refresh screen
    ref.invalidate(providersListProvider);
    ref.invalidate(currentProviderProfileProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'approve' 
                ? '${provider.businessName} is now a Verified Pro!' 
                : '${provider.businessName} verification application declined.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final providersAsync = ref.watch(providersListProvider);

    return ResponsiveLayoutShell(
      selectedIndex: 1, // Admin Providers Tab Index
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Service Professional Vetting'),
        ),
        body: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Pending Audits'),
                    selected: _filter == 'pending',
                    onSelected: (val) {
                      if (val) setState(() => _filter = 'pending');
                    },
                  ),
                  AppSpacing.width8,
                  ChoiceChip(
                    label: const Text('Verified Pros'),
                    selected: _filter == 'verified',
                    onSelected: (val) {
                      if (val) setState(() => _filter = 'verified');
                    },
                  ),
                  AppSpacing.width8,
                  ChoiceChip(
                    label: const Text('All Pros'),
                    selected: _filter == 'all',
                    onSelected: (val) {
                      if (val) setState(() => _filter = 'all');
                    },
                  ),
                ],
              ),
              AppSpacing.height24,

              // Provider vetting list
              Expanded(
                child: providersAsync.when(
                  data: (providers) {
                    // Apply filters
                    final filtered = providers.where((p) {
                      if (_filter == 'pending') return p.verificationStatus == 'under_review';
                      if (_filter == 'verified') return p.verificationStatus == 'verified';
                      return true;
                    }).toList();

                    if (filtered.isEmpty) {
                      return EmptyState(
                        icon: _filter == 'pending' ? Icons.check_circle_outline : Icons.supervised_user_circle_outlined,
                        title: _filter == 'pending' ? 'All caught up!' : 'No professionals found',
                        description: _filter == 'pending' 
                            ? 'There are currently no professional profiles awaiting credentials vetting audits.' 
                            : 'Try toggling other filters.',
                      );
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => AppSpacing.height16,
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        return Card(
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppDimensions.borderMedium,
                            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Business Details Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.businessName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            p.profession,
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildStatusChip(p.verificationStatus),
                                  ],
                                ),
                                AppSpacing.height12,

                                // Details Grid
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondaryLight),
                                    const SizedBox(width: 6),
                                    Text(p.phone, style: const TextStyle(fontSize: 12)),
                                    AppSpacing.width16,
                                    const Icon(Icons.map_outlined, size: 14, color: AppColors.textSecondaryLight),
                                    const SizedBox(width: 6),
                                    Text(p.serviceArea, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                AppSpacing.height8,

                                if (p.bio.isNotEmpty) ...[
                                  Text(
                                    p.bio,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AppSpacing.height16,
                                ],

                                // Simulated Credentials check lists (if pending)
                                if (p.verificationStatus == 'under_review') ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9),
                                      borderRadius: AppDimensions.borderSmall,
                                    ),
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Submitted Documents Check:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle, size: 12, color: AppColors.successLight),
                                            SizedBox(width: 6),
                                            Text('Aadhaar ID Card matches name & photo', style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle, size: 12, color: AppColors.successLight),
                                            SizedBox(width: 6),
                                            Text('Trade / Municipal License registered', style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle, size: 12, color: AppColors.successLight),
                                            SizedBox(width: 6),
                                            Text('ITI/Skill Diploma verified authentic', style: TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppSpacing.height16,
                                ],

                                // Verification CTAs
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (p.verificationStatus != 'unverified')
                                      OutlinedButton(
                                        onPressed: () => _vetProvider(p, 'reject'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.errorLight,
                                          side: const BorderSide(color: AppColors.errorLight),
                                        ),
                                        child: const Text('Reject Profile'),
                                      ),
                                    if (p.verificationStatus != 'verified') ...[
                                      AppSpacing.width12,
                                      ElevatedButton(
                                        onPressed: () => _vetProvider(p, 'approve'),
                                        child: const Text('Approve Credentials'),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Error loading providers', description: e.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg = Colors.grey;
    String label = 'Unverified';

    if (status == 'verified') {
      bg = const Color(0xFF10B981);
      label = 'Verified';
    } else if (status == 'under_review') {
      bg = const Color(0xFF0284C7);
      label = 'Pending Review';
    } else {
      bg = const Color(0xFFEF4444);
      label = 'Unverified';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }
}
