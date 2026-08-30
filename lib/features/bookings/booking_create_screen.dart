import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/models/booking.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/responsive_layout_shell.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../core/services/location_service.dart';

class BookingCreateScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingArgs;

  const BookingCreateScreen({
    super.key,
    required this.bookingArgs,
  });

  @override
  ConsumerState<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends ConsumerState<BookingCreateScreen> {
  int _currentStep = 0;
  
  // Input fields state
  final _requirementController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';
  
  bool _isSuccess = false;
  bool _isFetchingGps = false;
  late String _createdBookingId;

  final List<String> _timeSlots = [
    '08:00 AM',
    '10:00 AM',
    '12:00 PM',
    '02:00 PM',
    '04:00 PM',
    '06:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    // Default location and phone to current user profile values if possible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (user != null) {
        setState(() {
          _locationController.text = '${user.location} - ';
          _phoneController.text = user.phone;
        });
      }
    });
  }

  @override
  void dispose() {
    _requirementController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitBooking(String currentUserId, String customerName) async {
    final providerId = widget.bookingArgs['providerId'] as String;
    final providerName = widget.bookingArgs['providerName'] as String;
    final serviceId = widget.bookingArgs['serviceId'] as String;
    final serviceName = widget.bookingArgs['serviceName'] as String;
    final price = widget.bookingArgs['price'] as double;
    final profession = providerName.contains('Arun') ? 'AC Specialist' : 'Vetted Professional';

    final uuid = const Uuid().v4();
    final formattedDate = DateFormat('dd MMM yyyy').format(_selectedDate);
    final formattedNow = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    final newBooking = Booking(
      id: uuid,
      customerId: currentUserId,
      customerName: customerName,
      customerPhone: _phoneController.text,
      providerId: providerId,
      providerName: providerName,
      providerProfession: profession,
      serviceId: serviceId,
      serviceName: serviceName,
      date: formattedDate,
      time: _selectedTime,
      location: _locationController.text.trim(),
      priceEstimate: price,
      description: _requirementController.text.trim(),
      status: BookingStatus.pending,
      statusTimeline: [
        {'status': 'pending', 'time': formattedNow},
      ],
    );

    // Save using repository
    await ref.read(bookingRepositoryProvider).createBooking(newBooking);
    
    // Invalidate the bookings list for refresh
    ref.invalidate(userBookingsProvider);

    setState(() {
      _createdBookingId = uuid;
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final authState = ref.watch(authStateProvider);

    final providerName = widget.bookingArgs['providerName'] as String;
    final serviceName = widget.bookingArgs['serviceName'] as String;
    final price = widget.bookingArgs['price'] as double;
    final priceType = widget.bookingArgs['priceType'] as String;

    return authState.when(
      data: (currentUser) {
        if (currentUser == null) return const SizedBox();

        if (_isSuccess) {
          return _buildSuccessScreen(providerName, textTheme);
        }

        return ResponsiveLayoutShell(
          selectedIndex: 1, // Bookings tab index
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Book Service'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: ResponsiveContainer(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.primaryLight,
                  ),
                ),
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 3) {
                      setState(() {
                        _currentStep += 1;
                      });
                    } else if (_currentStep == 3) {
                      // Submit the booking
                      _submitBooking(currentUser.id, currentUser.name);
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep -= 1;
                      });
                    } else {
                      context.pop();
                    }
                  },
                  controlsBuilder: (context, controls) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Row(
                        children: [
                          AppButton(
                            text: _currentStep == 3 ? 'Confirm & Book' : 'Continue',
                            onPressed: controls.onStepContinue,
                          ),
                          AppSpacing.width12,
                          AppOutlinedButton(
                            text: 'Back',
                            onPressed: controls.onStepCancel,
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [
                    // Step 1: Describe Requirement
                    Step(
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 ? StepState.complete : StepState.editing,
                      title: const Text('Describe your requirement', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Service: $serviceName by $providerName',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryLight),
                          ),
                          AppSpacing.height12,
                          AppTextField(
                            controller: _requirementController,
                            label: 'Details of the job',
                            hintText: 'Describe details of what you need (e.g. size, issues, specific requests)',
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                    
                    // Step 2: Date & Time Schedule
                    Step(
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 ? StepState.complete : _currentStep == 1 ? StepState.editing : StepState.indexed,
                      title: const Text('Schedule Date & Time', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          AppSpacing.height8,
                          
                          // Date display chip & trigger
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDate = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                borderRadius: AppDimensions.borderMedium,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month, color: AppColors.primaryLight),
                                  AppSpacing.width12,
                                  Text(
                                    DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          AppSpacing.height16,
                          
                          const Text('Select Time Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          AppSpacing.height8,
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _timeSlots.map((slot) {
                              final isSelected = _selectedTime == slot;
                              return ChoiceChip(
                                label: Text(slot),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _selectedTime = slot;
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    
                    // Step 3: Location and Phone
                    Step(
                      isActive: _currentStep >= 2,
                      state: _currentStep > 2 ? StepState.complete : _currentStep == 2 ? StepState.editing : StepState.indexed,
                      title: const Text('Add Location & Contact', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Column(
                        children: [
                          AppTextField(
                            controller: _locationController,
                            label: 'Full Service Address',
                            hintText: 'Enter street, house name, area, and city',
                            prefixIcon: Icons.location_on_outlined,
                            suffixIcon: IconButton(
                              tooltip: 'Auto-detect GPS Location & Pincode',
                              icon: _isFetchingGps
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : Icon(
                                      Icons.my_location,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              onPressed: _isFetchingGps
                                  ? null
                                  : () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      setState(() {
                                        _isFetchingGps = true;
                                      });
                                      final locService = ref.read(locationServiceProvider);
                                      final result = await locService.fetchCurrentLocation();
                                      if (mounted) {
                                        setState(() {
                                          _isFetchingGps = false;
                                          _locationController.text = result.formattedAddress;
                                        });
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text('Address set to: ${result.formattedAddress}'),
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                            ),
                          ),
                          AppSpacing.height16,
                          AppTextField(
                            controller: _phoneController,
                            label: 'Contact Phone Number',
                            hintText: 'Enter your 10-digit mobile number',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                          ),
                        ],
                      ),
                    ),
                    
                    // Step 4: Summary Review
                    Step(
                      isActive: _currentStep >= 3,
                      state: _currentStep == 3 ? StepState.editing : StepState.indexed,
                      title: const Text('Review and Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Card(
                        color: isDark ? AppColors.backgroundDark : AppColors.primaryLight.withAlpha(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderMedium,
                          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.primaryLight.withAlpha(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSummaryItem('Service', serviceName, textTheme),
                              _buildSummaryItem('Professional', providerName, textTheme),
                              _buildSummaryItem('Schedule', '${DateFormat('dd MMM yyyy').format(_selectedDate)} at $_selectedTime', textTheme),
                              _buildSummaryItem('Address', _locationController.text, textTheme),
                              _buildSummaryItem('Contact', _phoneController.text, textTheme),
                              if (_requirementController.text.isNotEmpty)
                                _buildSummaryItem('Details', _requirementController.text, textTheme),
                              const Divider(),
                              AppSpacing.height12,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Est. Price (${priceType == 'hourly' ? 'Hourly rate' : 'Fixed rate'})',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '₹${price.toStringAsFixed(0)}',
                                    style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryLight,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildSummaryItem(String label, String value, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight, letterSpacing: 0.5),
          ),
          AppSpacing.height4,
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(String providerName, TextTheme textTheme) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Success Rings
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              AppSpacing.height32,
              
              Text(
                'Request Sent! 🎉',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              AppSpacing.height12,
              Text(
                'Your booking request has been sent to $providerName. You will be notified once they accept the slot.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight, height: 1.4),
                textAlign: TextAlign.center,
              ),
              AppSpacing.height48,
              
              // CTA Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/booking/$_createdBookingId');
                  },
                  child: const Text('View Booking Status'),
                ),
              ),
              AppSpacing.height12,
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  child: const Text('Back Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
