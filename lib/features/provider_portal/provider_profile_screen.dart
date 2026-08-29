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
import '../../data/repositories/auth_repository.dart';
import '../../core/models/app_user.dart';
import 'package:go_router/go_router.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  ConsumerState<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _profileFormKey = GlobalKey<FormState>();

  // Profile Form Controllers
  final _businessNameController = TextEditingController();
  final _professionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _areaController = TextEditingController();
  final _responseTimeController = TextEditingController();

  // Simulated Verification files uploaded status
  bool _idUploaded = false;
  bool _licenseUploaded = false;
  bool _certUploaded = false;
  int _verifyStep = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      
      // Refresh current profile provider
      ref.invalidate(currentProviderProfileProvider);
      ref.invalidate(providerDetailsProvider(provider.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business profile updated successfully!')),
        );
      }
    }
  }

  void _submitVerificationDocs(ServiceProvider provider) async {
    final repo = ref.read(providerRepositoryProvider);
    await repo.submitVerification(provider.id, provider.businessName, provider.phone, provider.businessName);

    // Refresh states
    ref.invalidate(currentProviderProfileProvider);
    ref.invalidate(providerDetailsProvider(provider.id));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification documents submitted! Under Review.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    final providerProfileAsync = ref.watch(currentProviderProfileProvider);

    return ResponsiveLayoutShell(
      selectedIndex: 4, // Business Profile Index in layout shell
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

          // Set form controllers
          _initFormValues(provider);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Business Profile Settings'),
              bottom: TabBar(
                controller: _tabController,
                labelColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                indicatorColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                tabs: const [
                  Tab(text: 'Edit Profile'),
                  Tab(text: 'Hours'),
                  Tab(text: 'Verification'),
                ],
              ),
            ),
            body: ResponsiveContainer(
              usePadding: false,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Edit Profile details
                  _buildEditProfileTab(provider, isDark, textTheme),

                  // Tab 2: Availability Schedule Builder
                  _buildHoursTab(provider, isDark, textTheme),

                  // Tab 3: Verification portal stepper
                  _buildVerificationTab(provider, isDark, textTheme),
                ],
              ),
            ),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error loading profile: $e'))),
      ),
    );
  }

  Widget _buildEditProfileTab(ServiceProvider provider, bool isDark, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline status badge
            Row(
              children: [
                const Text('Verification Badge: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                if (provider.verificationStatus == 'verified')
                  const Chip(
                    label: Text('VERIFIED PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    backgroundColor: Color(0xFF10B981),
                    padding: EdgeInsets.zero,
                  )
                else if (provider.verificationStatus == 'under_review')
                  const Chip(
                    label: Text('UNDER REVIEW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    backgroundColor: Color(0xFF0284C7),
                    padding: EdgeInsets.zero,
                  )
                else
                  const Chip(
                    label: Text('UNVERIFIED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    backgroundColor: Color(0xFFEF4444),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            AppSpacing.height24,

            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(labelText: 'Business Name *', prefixIcon: Icon(Icons.business)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter business name' : null,
            ),
            AppSpacing.height16,

            TextFormField(
              controller: _professionController,
              decoration: const InputDecoration(labelText: 'Profession Title *', prefixIcon: Icon(Icons.badge_outlined)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter profession title' : null,
            ),
            AppSpacing.height16,

            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Contact Phone *', prefixIcon: Icon(Icons.phone_outlined)),
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter contact phone' : null,
            ),
            AppSpacing.height16,

            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(labelText: 'Service Area Locations *', prefixIcon: Icon(Icons.map_outlined)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter service area' : null,
            ),
            AppSpacing.height16,

            TextFormField(
              controller: _responseTimeController,
              decoration: const InputDecoration(labelText: 'Response Time (e.g. within 1 hour) *', prefixIcon: Icon(Icons.timer_outlined)),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter response speed' : null,
            ),
            AppSpacing.height16,

            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(labelText: 'Business Bio *', prefixIcon: Icon(Icons.notes_outlined)),
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter bio description' : null,
            ),
            AppSpacing.height32,

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveProfile(provider),
                child: const Text('Save Changes'),
              ),
            ),
            AppSpacing.height32,
            const Divider(),
            AppSpacing.height16,
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.5) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.exit_to_app_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  AppSpacing.width16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exit Workspace',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exit to the main customer application to request services, manage personal bookings, and view favorites.',
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.3,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.width12,
                  ElevatedButton(
                    onPressed: () {
                      ref.read(authStateProvider.notifier).setRole(UserRole.customer);
                      context.go('/home');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Exit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoursTab(ServiceProvider provider, bool isDark, TextTheme textTheme) {
    // Render list of weekdays Mon-Sun, showing switch and time selector
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return StatefulBuilder(
      builder: (builderContext, setHoursState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Operating Schedule',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              AppSpacing.height8,
              Text(
                'Configure the days and times you are active to receive service booking requests.',
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
              ),
              AppSpacing.height24,

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: days.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final day = days[index];
                  final sched = provider.workingHours[day] ?? {'available': false, 'start': '09:00 AM', 'end': '06:00 PM'};
                  final bool isAvail = sched['available'] == true;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Day Label & Switch
                        Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Switch(
                              value: isAvail,
                              onChanged: (val) {
                                setHoursState(() {
                                  provider.workingHours[day] = {
                                    'available': val,
                                    'start': sched['start'],
                                    'end': sched['end'],
                                  };
                                });
                              },
                            ),
                          ],
                        ),

                        // Time slots
                        if (isAvail)
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(hour: 9, minute: 0),
                                  );
                                  if (time != null && mounted) {
                                    setHoursState(() {
                                      provider.workingHours[day] = {
                                        'available': true,
                                        'start': time.format(context),
                                        'end': sched['end'],
                                      };
                                    });
                                  }
                                },
                                child: Text(sched['start']),
                              ),
                              const Text('-'),
                              TextButton(
                                onPressed: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: const TimeOfDay(hour: 18, minute: 0),
                                  );
                                  if (time != null && mounted) {
                                    setHoursState(() {
                                      provider.workingHours[day] = {
                                        'available': true,
                                        'start': sched['start'],
                                        'end': time.format(context),
                                      };
                                    });
                                  }
                                },
                                child: Text(sched['end']),
                              ),
                            ],
                          )
                        else
                          const Text('Closed', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
              AppSpacing.height32,

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final repo = ref.read(providerRepositoryProvider);
                    await repo.updateProviderProfile(provider);
                    
                    ref.invalidate(currentProviderProfileProvider);
                    ref.invalidate(providerDetailsProvider(provider.id));

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Operating schedule saved successfully!')),
                      );
                    }
                  },
                  child: const Text('Save Operating Hours'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerificationTab(ServiceProvider provider, bool isDark, TextTheme textTheme) {
    if (provider.verificationStatus == 'verified') {
      return const Center(
        child: EmptyState(
          icon: Icons.verified_user,
          title: 'Account Fully Verified! 🛡️',
          description: 'Your business profile is vetted and visible to customers with the green verified badge tag.',
        ),
      );
    }

    if (provider.verificationStatus == 'under_review') {
      return const Center(
        child: EmptyState(
          icon: Icons.hourglass_top_outlined,
          title: 'Verification In Progress ⏳',
          description: 'We have received your uploaded files and certificates. The admin team is currently reviewing your application. This usually takes 24 hours.',
        ),
      );
    }

    // Stepper to upload documents
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Simulated Professional Verification',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          AppSpacing.height8,
          Text(
            'Get the verified badge tag on your profile by uploading mock certificates and credentials to build customer trust.',
            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
          ),
          AppSpacing.height24,

          Stepper(
            physics: const NeverScrollableScrollPhysics(),
            currentStep: _verifyStep,
            onStepContinue: () {
              if (_verifyStep < 2) {
                setState(() {
                  _verifyStep += 1;
                });
              } else if (_verifyStep == 2) {
                // Submit docs
                if (_idUploaded && _licenseUploaded && _certUploaded) {
                  _submitVerificationDocs(provider);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please upload all 3 mock files first.')),
                  );
                }
              }
            },
            onStepCancel: () {
              if (_verifyStep > 0) {
                setState(() {
                  _verifyStep -= 1;
                });
              }
            },
            controlsBuilder: (context, controls) {
              return Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: controls.onStepContinue,
                      child: Text(_verifyStep == 2 ? 'Submit Application' : 'Next Step'),
                    ),
                    AppSpacing.width12,
                    if (_verifyStep > 0)
                      OutlinedButton(
                        onPressed: controls.onStepCancel,
                        child: const Text('Back'),
                      ),
                  ],
                ),
              );
            },
            steps: [
              // Step 1: ID Proof
              Step(
                isActive: _verifyStep >= 0,
                state: _verifyStep > 0 ? StepState.complete : StepState.editing,
                title: const Text('Upload Identity Proof (Aadhaar/PAN)', style: TextStyle(fontWeight: FontWeight.bold)),
                content: _buildUploadField(
                  title: 'Aadhaar Card / Driver License',
                  uploaded: _idUploaded,
                  onUpload: () {
                    setState(() {
                      _idUploaded = true;
                    });
                  },
                ),
              ),

              // Step 2: Trade License
              Step(
                isActive: _verifyStep >= 1,
                state: _verifyStep > 1 ? StepState.complete : _verifyStep == 1 ? StepState.editing : StepState.indexed,
                title: const Text('Upload Trade / Business License', style: TextStyle(fontWeight: FontWeight.bold)),
                content: _buildUploadField(
                  title: 'Municipal Trade Certificate / Local Body License',
                  uploaded: _licenseUploaded,
                  onUpload: () {
                    setState(() {
                      _licenseUploaded = true;
                    });
                  },
                ),
              ),

              // Step 3: Skill Certification
              Step(
                isActive: _verifyStep >= 2,
                state: _verifyStep == 2 ? StepState.editing : StepState.indexed,
                title: const Text('Upload Skill Certificates', style: TextStyle(fontWeight: FontWeight.bold)),
                content: _buildUploadField(
                  title: 'ITI Diploma / Technical Vocation Certificate',
                  uploaded: _certUploaded,
                  onUpload: () {
                    setState(() {
                      _certUploaded = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadField({required String title, required bool uploaded, required VoidCallback onUpload}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: AppDimensions.borderMedium,
        border: Border.all(color: Colors.grey.withAlpha(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(
                  uploaded ? '✓ File loaded' : 'Supports PDF, JPG, PNG',
                  style: TextStyle(fontSize: 11, color: uploaded ? AppColors.successLight : AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: uploaded ? AppColors.successLight : null,
              foregroundColor: uploaded ? Colors.white : null,
            ),
            child: Text(uploaded ? 'Uploaded' : 'Choose File'),
          ),
        ],
      ),
    );
  }
}
