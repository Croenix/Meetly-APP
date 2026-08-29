import '../../core/models/booking.dart';

final List<Booking> mockBookings = [
  // 1. Completed bookings
  Booking(
    id: 'b1',
    customerId: 'c1', // Aarav Nair
    customerName: 'Aarav Nair',
    customerPhone: '+91 9447123456',
    providerId: 'p1', // Rajesh Electrical
    providerName: 'Rajesh K.R.',
    providerProfession: 'Certified Industrial & Home Electrician',
    serviceId: 's1', // Ceiling Fan Installation
    serviceName: 'Ceiling Fan Installation & Wiring',
    date: '25 Aug 2026',
    time: '10:00 AM',
    location: 'Kochi - Kakkanad, Block 4A, Horizon Apts',
    priceEstimate: 249.0,
    description: 'Need to install a new Orient ceiling fan in the master bedroom. Bracket is already in place, only mounting and wiring needed.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '24 Aug 2026, 03:15 PM'},
      {'status': 'accepted', 'time': '24 Aug 2026, 03:45 PM'},
      {'status': 'confirmed', 'time': '24 Aug 2026, 04:00 PM'},
      {'status': 'onTheWay', 'time': '25 Aug 2026, 09:40 AM'},
      {'status': 'inProgress', 'time': '25 Aug 2026, 10:05 AM'},
      {'status': 'completed', 'time': '25 Aug 2026, 10:45 AM'},
    ],
  ),
  Booking(
    id: 'b2',
    customerId: 'c2', // Meera Joseph
    customerName: 'Meera Joseph',
    customerPhone: '+91 9447654321',
    providerId: 'p7', // Arun AC Care
    providerName: 'Arun Thomas',
    providerProfession: 'HVAC Specialist & Certified Technician',
    serviceId: 's13', // AC Deep Cleaning
    serviceName: 'Split AC Deep Foam Cleaning Service',
    date: '20 Aug 2026',
    time: '02:00 PM',
    location: 'Kottayam - Kanjikuzhy, Rose Villa',
    priceEstimate: 499.0,
    description: 'General cleaning of 1.5 Ton Daikin Split AC. Cooling is less, water is also dripping slightly from the indoor unit.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '19 Aug 2026, 09:00 AM'},
      {'status': 'accepted', 'time': '19 Aug 2026, 09:30 AM'},
      {'status': 'confirmed', 'time': '19 Aug 2026, 10:00 AM'},
      {'status': 'onTheWay', 'time': '20 Aug 2026, 01:45 PM'},
      {'status': 'inProgress', 'time': '20 Aug 2026, 02:10 PM'},
      {'status': 'completed', 'time': '20 Aug 2026, 03:05 PM'},
    ],
  ),
  Booking(
    id: 'b3',
    customerId: 'c3', // Rahul Krishnan
    customerName: 'Rahul Krishnan',
    customerPhone: '+91 9845123456',
    providerId: 'p4', // Suresh Plumbing
    providerName: 'Suresh Kumar',
    providerProfession: 'Master Plumber & Pipe Fitting Expert',
    serviceId: 's7', // Tap Leak Repair
    serviceName: 'Bathroom Tap Leak Repair & Sealing',
    date: '15 Aug 2026',
    time: '11:30 AM',
    location: 'Alappuzha - Kalavoor, Lakeview House',
    priceEstimate: 249.0,
    description: 'Kitchen washbasin tap is continuously dripping even when closed tightly. Need to replace the washer or spindle.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '14 Aug 2026, 04:30 PM'},
      {'status': 'accepted', 'time': '14 Aug 2026, 05:00 PM'},
      {'status': 'confirmed', 'time': '14 Aug 2026, 05:15 PM'},
      {'status': 'onTheWay', 'time': '15 Aug 2026, 11:15 AM'},
      {'status': 'inProgress', 'time': '15 Aug 2026, 11:35 AM'},
      {'status': 'completed', 'time': '12:15 PM'},
    ],
  ),
  Booking(
    id: 'b4',
    customerId: 'c4', // Riya Mathew
    customerName: 'Riya Mathew',
    customerPhone: '+91 9845654321',
    providerId: 'p10', // Marys Cleaning
    providerName: 'Mary Skaria',
    providerProfession: 'Professional Sanitization & Deep Cleaner',
    serviceId: 's21', // Kitchen Oil Removal
    serviceName: 'Modular Kitchen Oil & Grease Removal',
    date: '18 Aug 2026',
    time: '09:00 AM',
    location: 'Thiruvalla - Ramanchira, Green Valley Apt 3B',
    priceEstimate: 1199.0,
    description: 'Modular kitchen cupboards have sticky oil layer. Chimney filters need grease extraction. Overall deep scrub requested.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '17 Aug 2026, 11:00 AM'},
      {'status': 'accepted', 'time': '17 Aug 2026, 11:30 AM'},
      {'status': 'confirmed', 'time': '17 Aug 2026, 12:00 PM'},
      {'status': 'onTheWay', 'time': '18 Aug 2026, 08:45 AM'},
      {'status': 'inProgress', 'time': '18 Aug 2026, 09:05 AM'},
      {'status': 'completed', 'time': '18 Aug 2026, 12:15 PM'},
    ],
  ),
  Booking(
    id: 'b5',
    customerId: 'c5', // Adithya Pillai
    customerName: 'Adithya Pillai',
    customerPhone: '+91 9961123456',
    providerId: 'p13', // Binoy Carpentry
    providerName: 'Binoy Joseph',
    providerProfession: 'Modular Woodwork & Carpenter',
    serviceId: 's24', // Door Latch Installation
    serviceName: 'Wooden Door Latch & Lock Installation',
    date: '22 Aug 2026',
    time: '04:00 PM',
    location: 'Changanassery - Perunna, Hillview',
    priceEstimate: 349.0,
    description: 'Replacing an old padlock latch with a premium Godrej rim lock on the wooden main door. Lock purchased by customer.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '21 Aug 2026, 03:00 PM'},
      {'status': 'accepted', 'time': '21 Aug 2026, 03:20 PM'},
      {'status': 'confirmed', 'time': '21 Aug 2026, 04:00 PM'},
      {'status': 'onTheWay', 'time': '22 Aug 2026, 03:45 PM'},
      {'status': 'inProgress', 'time': '22 Aug 2026, 04:10 PM'},
      {'status': 'completed', 'time': '22 Aug 2026, 05:15 PM'},
    ],
  ),
  Booking(
    id: 'b6',
    customerId: 'c6', // Anjali Menon
    customerName: 'Anjali Menon',
    customerPhone: '+91 9961654321',
    providerId: 'p27', // Sunithas Bridal
    providerName: 'Sunitha Devadas',
    providerProfession: 'Professional Bridal Make-up Artist & Stylist',
    serviceId: 's44', // Glow Facial
    serviceName: 'Glow Facial & De-Tan Therapy',
    date: '24 Aug 2026',
    time: '11:00 AM',
    location: 'Kochi - Palarivattom, Skyline Apts',
    priceEstimate: 1199.0,
    description: 'Bridal glow facial and detan pack ahead of an event. Prefer home service.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '23 Aug 2026, 10:00 AM'},
      {'status': 'accepted', 'time': '23 Aug 2026, 10:15 AM'},
      {'status': 'confirmed', 'time': '23 Aug 2026, 11:00 AM'},
      {'status': 'onTheWay', 'time': '24 Aug 2026, 10:35 AM'},
      {'status': 'inProgress', 'time': '24 Aug 2026, 11:05 AM'},
      {'status': 'completed', 'time': '24 Aug 2026, 12:35 PM'},
    ],
  ),
  Booking(
    id: 'b7',
    customerId: 'c7', // Deepak Kurian
    customerName: 'Deepak Kurian',
    customerPhone: '+91 8089123456',
    providerId: 'p19', // Subhash IT Tech
    providerName: 'Subhash Chandran',
    providerProfession: 'Hardware Engineer & Laptop Repair Specialist',
    serviceId: 's32', // Laptop OS Reinstall
    serviceName: 'Laptop OS Reinstallation & Setup',
    date: '10 Aug 2026',
    time: '10:00 AM',
    location: 'Thiruvalla - Town, Kurian Villa',
    priceEstimate: 499.0,
    description: 'Dell Inspiron laptop is very slow and stuck in a boot loop. Need full format and Windows 11 installation with drivers.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '09 Aug 2026, 04:00 PM'},
      {'status': 'accepted', 'time': '09 Aug 2026, 04:30 PM'},
      {'status': 'confirmed', 'time': '09 Aug 2026, 05:00 PM'},
      {'status': 'onTheWay', 'time': '10 Aug 2026, 09:40 AM'},
      {'status': 'inProgress', 'time': '10 Aug 2026, 10:05 AM'},
      {'status': 'completed', 'time': '10 Aug 2026, 11:45 AM'},
    ],
  ),
  Booking(
    id: 'b8',
    customerId: 'c8', // Sandra George
    customerName: 'Sandra George',
    customerPhone: '+91 8089654321',
    providerId: 'p21', // Priya Mathematics Class
    providerName: 'Priya Rajan',
    providerProfession: 'High School & Board Exam Math Tutor',
    serviceId: 's36', // Mathematics class
    serviceName: 'Class 10 CBSE Math Syllabus (Home Tuition)',
    date: '12 Aug 2026',
    time: '04:30 PM',
    location: 'Kochi - Ravipuram, Metro heights 4B',
    priceEstimate: 800.0, // 2 hours * 400
    description: 'First demo session for CBSE Class 10 Trigonometry topics. Standard coaching.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '11 Aug 2026, 02:00 PM'},
      {'status': 'accepted', 'time': '11 Aug 2026, 02:30 PM'},
      {'status': 'confirmed', 'time': '11 Aug 2026, 03:00 PM'},
      {'status': 'onTheWay', 'time': '12 Aug 2026, 04:15 PM'},
      {'status': 'inProgress', 'time': '12 Aug 2026, 04:30 PM'},
      {'status': 'completed', 'time': '12 Aug 2026, 06:30 PM'},
    ],
  ),
  Booking(
    id: 'b9',
    customerId: 'c9', // Gautham S
    customerName: 'Gautham S.',
    customerPhone: '+91 7012123456',
    providerId: 'p24', // Sajith Mechanic
    providerName: 'Sajith K.P.',
    providerProfession: 'Multi-brand Car Mechanic & Electrician',
    serviceId: 's40', // Jumpstart
    serviceName: 'Car Battery Jumpstart & Diagnostic',
    date: '14 Aug 2026',
    time: '08:30 AM',
    location: 'Kochi - Kakkanad, Infopark Phase 1 parking',
    priceEstimate: 499.0,
    description: 'Car battery went dead because headlights were left on overnight. Need jumper cable jumpstart and charging check.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '14 Aug 2026, 08:05 AM'},
      {'status': 'accepted', 'time': '14 Aug 2026, 08:12 AM'},
      {'status': 'confirmed', 'time': '14 Aug 2026, 08:15 AM'},
      {'status': 'onTheWay', 'time': '14 Aug 2026, 08:25 AM'},
      {'status': 'inProgress', 'time': '14 Aug 2026, 08:32 AM'},
      {'status': 'completed', 'time': '14 Aug 2026, 08:55 AM'},
    ],
  ),
  Booking(
    id: 'b10',
    customerId: 'c10', // Shruti Varma
    customerName: 'Shruti Varma',
    customerPhone: '+91 7012654321',
    providerId: 'p28', // Jaisons grooming
    providerName: 'Jaison Abraham',
    providerProfession: 'Men\'s Hair Stylist & Groomer',
    serviceId: 's45', // haircut
    serviceName: 'Premium Men\'s Haircut & Beard Trim',
    date: '17 Aug 2026',
    time: '05:00 PM',
    location: 'Kottayam - Baker Hill Road, Varma Nivas',
    priceEstimate: 299.0,
    description: 'Haircut and clean beard trim at home for son.',
    status: BookingStatus.completed,
    statusTimeline: [
      {'status': 'pending', 'time': '16 Aug 2026, 03:00 PM'},
      {'status': 'accepted', 'time': '16 Aug 2026, 04:00 PM'},
      {'status': 'confirmed', 'time': '16 Aug 2026, 04:30 PM'},
      {'status': 'onTheWay', 'time': '17 Aug 2026, 04:45 PM'},
      {'status': 'inProgress', 'time': '17 Aug 2026, 05:05 PM'},
      {'status': 'completed', 'time': '17 Aug 2026, 05:55 PM'},
    ],
  ),

  // 2. Confirmed & Upcoming bookings (active)
  Booking(
    id: 'b11',
    customerId: 'c1', // Aarav Nair
    customerName: 'Aarav Nair',
    customerPhone: '+91 9447123456',
    providerId: 'p10', // Marys Cleaning
    providerName: 'Mary Skaria',
    providerProfession: 'Professional Sanitization & Deep Cleaner',
    serviceId: 's19', // Deep Sanitization 2 BHK
    serviceName: 'Full Home Deep Sanitization (2 BHK)',
    date: '31 Aug 2026',
    time: '09:00 AM',
    location: 'Kochi - Kakkanad, Block 4A, Horizon Apts',
    priceEstimate: 2999.0,
    description: 'Full house deep cleaning before moving in new furniture. Deep clean bathrooms, kitchen tiles, grease spots, and balcony floor.',
    status: BookingStatus.confirmed,
    statusTimeline: [
      {'status': 'pending', 'time': '28 Aug 2026, 02:00 PM'},
      {'status': 'accepted', 'time': '28 Aug 2026, 02:40 PM'},
      {'status': 'confirmed', 'time': '28 Aug 2026, 03:00 PM'},
    ],
  ),
  Booking(
    id: 'b12',
    customerId: 'c2', // Meera Joseph
    customerName: 'Meera Joseph',
    customerPhone: '+91 9447654321',
    providerId: 'p2', // Anil Electrical
    providerName: 'Anil Kumar',
    providerProfession: 'Residential Wiring & Repair Contractor',
    serviceId: 's5', // Tubelight fitting
    serviceName: 'LED Tubelight / Wall Bracket Fitting',
    date: '30 Aug 2026',
    time: '11:00 AM',
    location: 'Kottayam - Kanjikuzhy, Rose Villa',
    priceEstimate: 149.0,
    description: 'Install three new LED tubelights. Old fixtures are already removed. Need to drill and mount new holders.',
    status: BookingStatus.confirmed,
    statusTimeline: [
      {'status': 'pending', 'time': '29 Aug 2026, 09:30 AM'},
      {'status': 'accepted', 'time': '29 Aug 2026, 10:15 AM'},
      {'status': 'confirmed', 'time': '29 Aug 2026, 11:00 AM'},
    ],
  ),
  Booking(
    id: 'b13',
    customerId: 'c11', // Kiran Paul
    customerName: 'Kiran Paul',
    customerPhone: '+91 9495123456',
    providerId: 'p24', // Sajith Mechanic
    providerName: 'Sajith K.P.',
    providerProfession: 'Multi-brand Car Mechanic & Electrician',
    serviceId: 's39', // General servicing
    serviceName: 'Car General Servicing (Oil + Filters)',
    date: '31 Aug 2026',
    time: '10:00 AM',
    location: 'Kochi - Palarivattom, Silver Meadows',
    priceEstimate: 1999.0,
    description: 'Scheduled periodic service for Maruti Swift. Replace engine oil, oil filter, air filter, and top up coolant.',
    status: BookingStatus.confirmed,
    statusTimeline: [
      {'status': 'pending', 'time': '28 Aug 2026, 10:00 AM'},
      {'status': 'accepted', 'time': '28 Aug 2026, 10:30 AM'},
      {'status': 'confirmed', 'time': '28 Aug 2026, 11:00 AM'},
    ],
  ),

  // 3. Pending bookings
  Booking(
    id: 'b14',
    customerId: 'c12', // Neha Roy
    customerName: 'Neha Roy',
    customerPhone: '+91 9495654321',
    providerId: 'p7', // Arun AC Care
    providerName: 'Arun Thomas',
    providerProfession: 'HVAC Specialist & Certified Technician',
    serviceId: 's14', // AC gas refill
    serviceName: 'AC Gas Refill (R32/R410)',
    date: '02 Sep 2026',
    time: '04:00 PM',
    location: 'Kottayam - Collectorate area, Roy Villa',
    priceEstimate: 1800.0,
    description: 'Split AC is blowing room temperature air. Suspect gas leakage. Need leak testing and full gas recharging.',
    status: BookingStatus.pending,
    statusTimeline: [
      {'status': 'pending', 'time': '29 Aug 2026, 05:00 PM'},
    ],
  ),
  Booking(
    id: 'b15',
    customerId: 'c13', // Vivek Chandran
    customerName: 'Vivek Chandran',
    customerPhone: '+91 9744123456',
    providerId: 'p4', // Suresh Plumbing
    providerName: 'Suresh Kumar',
    providerProfession: 'Master Plumber & Pipe Fitting Expert',
    serviceId: 's8', // Flush tank replacement
    serviceName: 'Flush Tank Mechanism Replacement',
    date: '01 Sep 2026',
    time: '03:00 PM',
    location: 'Kochi - Marine Drive, Bayview Apts 8A',
    priceEstimate: 349.0,
    description: 'Flush tank button is broken and the water is running continuously. Need mechanism replaced.',
    status: BookingStatus.pending,
    statusTimeline: [
      {'status': 'pending', 'time': '29 Aug 2026, 04:30 PM'},
    ],
  ),
  Booking(
    id: 'b16',
    customerId: 'c14', // Devika Sunil
    customerName: 'Devika Sunil',
    customerPhone: '+91 9744654321',
    providerId: 'p27', // Sunithas Bridal
    providerName: 'Sunitha Devadas',
    providerProfession: 'Professional Bridal Make-up Artist & Stylist',
    serviceId: 's43', // Bridal Makeup Package
    serviceName: 'Premium HD Bridal Makeup Package',
    date: '10 Sep 2026',
    time: '08:00 AM',
    location: 'Thiruvalla - Temple Road, Sunil Bhavan',
    priceEstimate: 9999.0,
    description: 'HD Makeup for wedding engagement function. Requesting home visit for bride styling, saree draping, and setting.',
    status: BookingStatus.pending,
    statusTimeline: [
      {'status': 'pending', 'time': '29 Aug 2026, 01:00 PM'},
    ],
  ),

  // 4. In Progress booking
  Booking(
    id: 'b17',
    customerId: 'c15', // Nikhil Raj
    customerName: 'Nikhil Raj',
    customerPhone: '+91 9562123456',
    providerId: 'p19', // Subhash IT Tech
    providerName: 'Subhash Chandran',
    providerProfession: 'Hardware Engineer & Laptop Repair Specialist',
    serviceId: 's33', // SSD upgrade
    serviceName: 'Laptop SSD & RAM Performance Upgrade',
    date: '29 Aug 2026',
    time: '05:30 PM', // Current time is ~06:12 PM, so this is in progress
    location: 'Thiruvalla - Near KSRTC, Raj Niwas',
    priceEstimate: 299.0,
    description: 'Upgrading Asus laptop with a new Crucial 500GB SSD. Customer has already bought the SSD, need installation and cloning of OS.',
    status: BookingStatus.inProgress,
    statusTimeline: [
      {'status': 'pending', 'time': '29 Aug 2026, 11:00 AM'},
      {'status': 'accepted', 'time': '29 Aug 2026, 11:30 AM'},
      {'status': 'confirmed', 'time': '29 Aug 2026, 12:00 PM'},
      {'status': 'onTheWay', 'time': '29 Aug 2026, 05:10 PM'},
      {'status': 'inProgress', 'time': '29 Aug 2026, 05:35 PM'},
    ],
  ),

  // 5. On the Way booking
  Booking(
    id: 'b18',
    customerId: 'c16', // Divya Mary
    customerName: 'Divya Mary',
    customerPhone: '+91 9562654321',
    providerId: 'p1', // Rajesh Electrical
    providerName: 'Rajesh K.R.',
    providerProfession: 'Certified Industrial & Home Electrician',
    serviceId: 's2', // Switchboard Repair
    serviceName: 'Switchboard Repair & Troubleshooting',
    date: '29 Aug 2026',
    time: '06:00 PM', // Current time is ~06:12 PM, so provider is on the way
    location: 'Kottayam - Kumaranalloor, Mary Villa',
    priceEstimate: 199.0,
    description: 'Kitchen main switchboard sparks when refrigerator is plugged in. Need urgent diagnostic.',
    status: BookingStatus.onTheWay,
    statusTimeline: [
      {'status': 'pending', 'time': '29 Aug 2026, 04:30 PM'},
      {'status': 'accepted', 'time': '29 Aug 2026, 04:45 PM'},
      {'status': 'confirmed', 'time': '29 Aug 2026, 05:00 PM'},
      {'status': 'onTheWay', 'time': '29 Aug 2026, 05:55 PM'},
    ],
  ),

  // 6. Cancelled bookings
  Booking(
    id: 'b19',
    customerId: 'c17', // Akshay Kumar
    customerName: 'Akshay Kumar',
    customerPhone: '+91 9188123456',
    providerId: 'p25', // Vipin Two-Wheeler
    providerName: 'Vipin Das',
    providerProfession: 'Motorcycle & Scooter Repair Expert',
    serviceId: 's41', // Scooter service
    serviceName: 'Scooter Periodic Servicing (Activa/Access)',
    date: '24 Aug 2026',
    time: '09:00 AM',
    location: 'Changanassery - Kuttanad Road, Kumar Sadan',
    priceEstimate: 499.0,
    description: 'Scooter general servicing, engine oil change. Cancelled because of heavy rain/water logging.',
    status: BookingStatus.cancelled,
    statusTimeline: [
      {'status': 'pending', 'time': '23 Aug 2026, 02:00 PM'},
      {'status': 'accepted', 'time': '23 Aug 2026, 02:30 PM'},
      {'status': 'cancelled', 'time': '23 Aug 2026, 08:00 PM'},
    ],
  ),
  Booking(
    id: 'b20',
    customerId: 'c18', // Parvathy Hari
    customerName: 'Parvathy Hari',
    customerPhone: '+91 9188654321',
    providerId: 'p16', // Jacob painting
    providerName: 'Geetha Jacob',
    providerProfession: 'Interior & Exterior Wall Painter',
    serviceId: 's28', // Single Room Painting
    serviceName: 'Single Room Wall Painting (Acrylic)',
    date: '10 Aug 2026',
    time: '09:00 AM',
    location: 'Alappuzha - Beach road, Hari Nivas',
    priceEstimate: 2499.0,
    description: 'Single room painting. Cancelled by customer due to travel plans.',
    status: BookingStatus.cancelled,
    statusTimeline: [
      {'status': 'pending', 'time': '08 Aug 2026, 03:00 PM'},
      {'status': 'cancelled', 'time': '09 Aug 2026, 10:00 AM'},
    ],
  )
];
