import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/service_provider.dart';
import '../../core/models/service_item.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/service_repository.dart';

class ProviderServicesScreen extends ConsumerStatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  ConsumerState<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends ConsumerState<ProviderServicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  String _priceType = 'fixed';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _showServiceDialog(ServiceProvider provider, {ServiceItem? existingService}) {
    if (existingService != null) {
      _nameController.text = existingService.name;
      _descController.text = existingService.description;
      _priceController.text = existingService.price.toStringAsFixed(0);
      _durationController.text = existingService.duration;
      _priceType = existingService.priceType;
    } else {
      _nameController.clear();
      _descController.clear();
      _priceController.clear();
      _durationController.text = '1 hr';
      _priceType = 'fixed';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existingService == null ? 'Add New Service' : 'Edit Service'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Service Name *'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter service name' : null,
                      ),
                      AppSpacing.height12,
                      
                      // Price and PriceType
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(labelText: 'Starting Price (₹) *'),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Enter price';
                                if (double.tryParse(v) == null) return 'Enter valid number';
                                return null;
                              },
                            ),
                          ),
                          AppSpacing.width12,
                          Expanded(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              initialValue: _priceType,
                              decoration: const InputDecoration(labelText: 'Rate Type'),
                              items: const [
                                DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                                DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    _priceType = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.height12,

                      // Duration
                      TextFormField(
                        controller: _durationController,
                        decoration: const InputDecoration(labelText: 'Estimated Duration *', hintText: 'e.g. 1 hr, 2 hrs'),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter duration' : null,
                      ),
                      AppSpacing.height12,

                      // Description
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      final parsedPrice = double.parse(_priceController.text);
                      final serviceRepo = ref.read(serviceRepositoryProvider);

                      if (existingService == null) {
                        // Add Service
                        final newService = ServiceItem(
                          id: const Uuid().v4(),
                          providerId: provider.id,
                          category: provider.category,
                          name: _nameController.text.trim(),
                          description: _descController.text.trim(),
                          price: parsedPrice,
                          priceType: _priceType,
                          duration: _durationController.text.trim(),
                        );
                        await serviceRepo.addService(newService);
                      } else {
                        // Update Service
                        final updatedService = existingService.copyWith(
                          name: _nameController.text.trim(),
                          description: _descController.text.trim(),
                          price: parsedPrice,
                          priceType: _priceType,
                          duration: _durationController.text.trim(),
                        );
                        await serviceRepo.updateService(updatedService);
                      }

                      // Invalidate providers
                      ref.invalidate(providerServicesProvider(provider.id));
                      
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              existingService == null
                                  ? 'Service added successfully'
                                  : 'Service updated successfully',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(existingService == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleDeleteService(String providerId, String serviceId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Service?'),
          content: const Text(
            'Are you sure you want to remove this service listing from your profile? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Close dialog
                
                final serviceRepo = ref.read(serviceRepositoryProvider);
                await serviceRepo.deleteService(serviceId);
                
                ref.invalidate(providerServicesProvider(providerId));
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Service removed successfully.')),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Load active provider details
    final providerProfileAsync = ref.watch(currentProviderProfileProvider);

    return ResponsiveLayoutShell(
      selectedIndex: 3, // My Services Tab Index
      child: providerProfileAsync.when(
        data: (provider) {
          if (provider == null) {
            return const Scaffold(
              body: EmptyState(
                icon: Icons.business_outlined,
                title: 'No business profile found',
                description: 'Please set up your professional dashboard profile first.',
              ),
            );
          }

          final servicesAsync = ref.watch(providerServicesProvider(provider.id));

          return Scaffold(
            appBar: AppBar(
              title: const Text('My Services'),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showServiceDialog(provider),
              icon: const Icon(Icons.add),
              label: const Text('Add Service'),
              backgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
            ),
            body: ResponsiveContainer(
              child: servicesAsync.when(
                data: (services) {
                  if (services.isEmpty) {
                    return EmptyState(
                      icon: Icons.handyman_outlined,
                      title: 'No services listed yet',
                      description: 'Grow your business on Meetly. Click the floating button below to list your first services and pricing.',
                      actionText: 'List a Service',
                      onActionPressed: () => _showServiceDialog(provider),
                    );
                  }

                  return ListView.separated(
                    itemCount: services.length,
                    separatorBuilder: (context, index) => AppSpacing.height16,
                    itemBuilder: (context, index) {
                      final s = services[index];
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
                              // Name, Price & Type
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      s.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${s.price.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        s.priceType == 'hourly' ? '/ hr' : 'fixed',
                                        style: TextStyle(
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              AppSpacing.height8,

                              // Description
                              if (s.description.isNotEmpty) ...[
                                Text(
                                  s.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                                AppSpacing.height12,
                              ],

                              // Stats & actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: AppColors.textSecondaryLight),
                                      const SizedBox(width: 4),
                                      Text(s.duration, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primaryLight),
                                        onPressed: () => _showServiceDialog(provider, existingService: s),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.errorLight),
                                        onPressed: () => _handleDeleteService(provider.id, s.id),
                                      ),
                                    ],
                                  ),
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
                  error: (e, _) => Center(child: Text('Error loading services: $e')),
                ),
              ),
            );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, _) => Scaffold(body: Center(child: Text('Error loading profile: $e'))),
      ),
    );
  }
}
