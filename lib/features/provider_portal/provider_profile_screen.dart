import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/models/app_user.dart';
import '../../core/models/service_provider.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/provider_repository.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  ConsumerState<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();

  // Profile Form Controllers
  final _businessNameController = TextEditingController();
  final _professionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _areaController = TextEditingController();
  final _responseTimeController = TextEditingController();

  // Verification uploaded status
  bool _idUploaded = true;
  bool _licenseUploaded = true;
  bool _certUploaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _businessNameController.dispose();
    _professionController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _areaController.dispose();
    _responseTimeController.dispose();
    super.dispose();
  }

  void _initFormValues(ServiceProvider provider) {
    if (_businessNameController.text.isEmpty) {
      _businessNameController.text = provider.businessName;
      _professionController.text = provider.profession;
      _phoneController.text = provider.phone;
      _bioController.text = provider.bio;
      _areaController.text = provider.serviceArea;
      _responseTimeController.text = provider.responseTime;
    }
  }

  void _saveProfile(ServiceProvider provider) async {
    if (_profileFormKey.currentState?.validate() ?? false) {
      final updatedProvider = provider.copyWith(
        businessName: _businessNameController.text.trim(),
        profession: _professionController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        serviceArea: _areaController.text.trim(),
        responseTime: _responseTimeController.text.trim(),
      );

      final repo = ref.read(providerRepositoryProvider);
      await repo.updateProviderProfile(updatedProvider);

      ref.invalidate(currentProviderProfileProvider);
      ref.invalidate(providerDetailsProvider(provider.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business profile updated successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _submitVerificationDocs(ServiceProvider provider) async {
    final repo = ref.read(providerRepositoryProvider);
    await repo.submitVerification(
      provider.id,
      provider.businessName,
      provider.phone,
      provider.businessName,
    );

    ref.invalidate(currentProviderProfileProvider);
    ref.invalidate(providerDetailsProvider(provider.id));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification documents submitted! Under Review.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final providerProfileAsync = ref.watch(currentProviderProfileProvider);

    const primaryColor = Color(0xFF6C5CE7);

    return ResponsiveLayoutShell(
      selectedIndex: 4, // Business Profile Index
      child: providerProfileAsync.when(
        data: (provider) {
          if (provider == null) {
            return const Scaffold(
              body: EmptyState(
                icon: Icons.business_outlined,
                title: 'No business profile',
                description: 'We could not fetch your provider profile details.',
              ),
            );
          }

          _initFormValues(provider);

          return Scaffold(
            backgroundColor: isDark ? const Color(0xFF0F0E17) : const Color(0xFFF7F6FE),
            appBar: AppBar(
              title: const Text(
                'Business Settings',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            body: ResponsiveContainer(
              usePadding: false,
              child: Column(
                children: [
                  // Hero Header Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E1B4B), const Color(0xFF311042)]
                            : [const Color(0xFF6C5CE7), const Color(0xFF8C7CFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                AppAvatar(
                                  url: provider.portfolioImages.isNotEmpty
                                      ? provider.portfolioImages.first
                                      : null,
                                  name: provider.businessName,
                                  size: 68,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          provider.businessName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    provider.profession,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),

                                  // Verified Badge Pill
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.verified_rounded,
                                          size: 14,
                                          color: Color(0xFF10B981),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          provider.verificationStatus == 'verified'
                                              ? 'VERIFIED PRO'
                                              : 'UNDER REVIEW',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 14),

                        // Stats Highlights Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem('Rating', '★ ${provider.rating}', Colors.amber),
                            _buildStatDivider(),
                            _buildStatItem('Reviews', '${provider.reviewCount}', Colors.white),
                            _buildStatDivider(),
                            _buildStatItem('Starts', '₹${provider.startingPrice.toStringAsFixed(0)}', Colors.white),
                            _buildStatDivider(),
                            _buildStatItem('Response', provider.responseTime, Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar Selector
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : const Color(0xFFEAEAFA),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: primaryColor,
                      unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      indicatorColor: primaryColor,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                      tabs: const [
                        Tab(text: 'Profile'),
                        Tab(text: 'Hours'),
                        Tab(text: 'Documents'),
                        Tab(text: 'Workspace'),
                      ],
                    ),
                  ),

                  // Tab Contents
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProfileTab(provider, isDark, textTheme, primaryColor),
                        _buildHoursTab(provider, isDark, textTheme, primaryColor),
                        _buildVerificationTab(provider, isDark, textTheme, primaryColor),
                        _buildWorkspaceTab(provider, isDark, textTheme, primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white24,
    );
  }

  // TAB 1: Profile Form
  Widget _buildProfileTab(ServiceProvider provider, bool isDark, TextTheme textTheme, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderDark : const Color(0xFFEAEAFA),
          ),
        ),
        child: Form(
          key: _profileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Business Details',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildModernTextField(
                controller: _businessNameController,
                label: 'Business / Trade Name',
                icon: Icons.storefront_outlined,
                isDark: isDark,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter business name' : null,
              ),
              const SizedBox(height: 14),

              _buildModernTextField(
                controller: _professionController,
                label: 'Profession / Category',
                icon: Icons.work_outline,
                isDark: isDark,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter profession' : null,
              ),
              const SizedBox(height: 14),

              _buildModernTextField(
                controller: _phoneController,
                label: 'Mobile Contact Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isDark: isDark,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 14),

              _buildModernTextField(
                controller: _areaController,
                label: 'Service Area / Region',
                icon: Icons.location_on_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              _buildModernTextField(
                controller: _responseTimeController,
                label: 'Average Response Time',
                icon: Icons.speed_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              _buildModernTextField(
                controller: _bioController,
                label: 'About / Business Description',
                icon: Icons.description_outlined,
                maxLines: 3,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Save Button
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFF8C7CFF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _saveProfile(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Save Business Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 2: Working Hours
  Widget _buildHoursTab(ServiceProvider provider, bool isDark, TextTheme textTheme, Color primaryColor) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.borderDark : const Color(0xFFEAEAFA),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Weekly Working Hours',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure availability schedule for customer appointments.',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            ...days.map((day) {
              final info = provider.workingHours[day] as Map<String, dynamic>? ??
                  {'available': day != 'Sun', 'start': '09:00', 'end': '19:00'};
              final isAvail = info['available'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF9F8FD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 44,
                          child: Text(
                            day,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        Switch(
                          value: isAvail,
                          activeTrackColor: primaryColor,
                          onChanged: (val) {
                            setState(() {
                              provider.workingHours[day] = {
                                'available': val,
                                'start': info['start'],
                                'end': info['end'],
                              };
                            });
                          },
                        ),
                      ],
                    ),
                    Text(
                      isAvail ? '${info['start']} - ${info['end']}' : 'Closed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isAvail
                            ? (isDark ? Colors.white : const Color(0xFF1E293B))
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Working hours updated!'), behavior: SnackBarBehavior.floating),
                );
              },
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Save Working Hours', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 3: Documents & Verification
  Widget _buildVerificationTab(ServiceProvider provider, bool isDark, TextTheme textTheme, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFEAEAFA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Identity & Business Verification',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Verified badge increases customer bookings by up to 3x.',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            _buildDocumentCard(
              title: 'Government Identity Proof',
              subtitle: 'Aadhaar / Passport / Driving License',
              isUploaded: _idUploaded,
              isDark: isDark,
              primaryColor: primaryColor,
              onUpload: () => setState(() => _idUploaded = !_idUploaded),
            ),
            const SizedBox(height: 12),

            _buildDocumentCard(
              title: 'Business Registration / GST',
              subtitle: 'Trade License or MSME Certificate',
              isUploaded: _licenseUploaded,
              isDark: isDark,
              primaryColor: primaryColor,
              onUpload: () => setState(() => _licenseUploaded = !_licenseUploaded),
            ),
            const SizedBox(height: 12),

            _buildDocumentCard(
              title: 'Trade Skill Certification',
              subtitle: 'ITI / Diploma or Training Certification',
              isUploaded: _certUploaded,
              isDark: isDark,
              primaryColor: primaryColor,
              onUpload: () => setState(() => _certUploaded = !_certUploaded),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => _submitVerificationDocs(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Submit Verification Documents', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 4: Settings & Workspace Switcher (ONLY Customer vs Professional)
  Widget _buildWorkspaceTab(ServiceProvider provider, bool isDark, TextTheme textTheme, Color primaryColor) {
    final authUser = ref.watch(authStateProvider).value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? AppColors.borderDark : const Color(0xFFEAEAFA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Account & Workspace Switching',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Switch active mode between requesting services or offering professional services.',
              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildWorkspaceOptionCard(
                    title: 'Customer Workspace',
                    subtitle: 'Book local experts & services',
                    icon: Icons.person_outline_rounded,
                    isActive: authUser?.role == UserRole.customer,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    onTap: () async {
                      await ref.read(authStateProvider.notifier).loginAsDemo(UserRole.customer);
                      if (mounted) context.go('/home');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWorkspaceOptionCard(
                    title: 'Professional Portal',
                    subtitle: 'Manage jobs, quotes & profile',
                    icon: Icons.work_outline_rounded,
                    isActive: authUser?.role == UserRole.provider,
                    isDark: isDark,
                    primaryColor: primaryColor,
                    onTap: () async {
                      await ref.read(authStateProvider.notifier).loginAsDemo(UserRole.provider);
                      if (mounted) context.go('/provider/dashboard');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            const Divider(),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
                context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.errorLight),
              label: const Text('Logout Session', style: TextStyle(color: AppColors.errorLight, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.errorLight, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF1E293B)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF9F8FD),
        prefixIcon: Icon(icon, size: 20, color: isDark ? const Color(0xFF8C7CFF) : const Color(0xFF6C5CE7)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 1.8)),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required bool isDark,
    required Color primaryColor,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF9F8FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFEAEAFA)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
              ],
            ),
          ),
          InkWell(
            onTap: onUpload,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUploaded ? const Color(0xFF10B981).withValues(alpha: 0.15) : primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isUploaded ? const Color(0xFF10B981) : primaryColor),
              ),
              child: Row(
                children: [
                  Icon(isUploaded ? Icons.check_circle : Icons.upload_file, size: 14, color: isUploaded ? const Color(0xFF10B981) : primaryColor),
                  const SizedBox(width: 4),
                  Text(isUploaded ? 'Uploaded' : 'Upload', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isUploaded ? const Color(0xFF10B981) : primaryColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required bool isDark,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : (isDark ? const Color(0xFF1E1E2A) : const Color(0xFFF9F8FD)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? primaryColor : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            width: isActive ? 2.0 : 1.0,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569))),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.white.withValues(alpha: 0.8) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isActive) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Text('ACTIVE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryColor)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
