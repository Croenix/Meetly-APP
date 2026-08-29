import '../../core/models/service_provider.dart';

final List<ServiceProvider> mockProviders = [
  // 1. Electricians
  const ServiceProvider(
    id: 'p1',
    userId: 'up2', // Rajesh K.R.
    businessName: 'Rajesh Electrical Solutions',
    profession: 'Certified Industrial & Home Electrician',
    rating: 4.8,
    reviewCount: 142,
    distance: 1.2,
    startingPrice: 199.0,
    verified: true,
    bio: 'Providing safe, certified electrical installations, rewiring, and appliance repair services in Kochi for over 8 years. Specialized in short-circuits and home automation systems.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1558224492-db71317d63a4?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kochi city limits, Kakkanad, Edappally, and Tripunithura',
    responseTime: 'Within 30 mins',
    category: 'Electrician',
    phone: '+91 9895100002',
    location: 'Kochi',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p2',
    userId: 'up6', // Anil Kumar
    businessName: 'Anil Electrical Works',
    profession: 'Residential Wiring & Repair Contractor',
    rating: 4.6,
    reviewCount: 78,
    distance: 2.8,
    startingPrice: 249.0,
    verified: true,
    bio: 'Affordable and reliable home electrical services including fans, lights, switchboards, inverter backup installation, and fault finding. Trustworthy and punctual service.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Tue': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Wed': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Thu': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Fri': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Sat': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kottayam, Kumarakom, and Ettumanoor area',
    responseTime: 'Within 1 hour',
    category: 'Electrician',
    phone: '+91 9895100006',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p3',
    userId: 'up11', // Manoj Kumar
    businessName: 'Apex Electricals Changanassery',
    profession: 'Commercial & Domestic Electrical Engineer',
    rating: 4.5,
    reviewCount: 39,
    distance: 4.1,
    startingPrice: 199.0,
    verified: false,
    bio: 'Specialist in panel board installations, 3-phase wiring, smart switches, and routine electrical maintenance for homes, retail stores, and small offices.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '15:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Changanassery, Karukachal, and Thiruvalla outskirts',
    responseTime: 'Within 2 hours',
    category: 'Electrician',
    phone: '+91 9895100011',
    location: 'Changanassery',
    verificationStatus: 'under_review',
  ),

  // 2. Plumbers
  const ServiceProvider(
    id: 'p4',
    userId: 'up3', // Suresh Kumar
    businessName: 'Suresh Leak Detection & Plumbing',
    profession: 'Master Plumber & Pipe Fitting Expert',
    rating: 4.7,
    reviewCount: 96,
    distance: 1.9,
    startingPrice: 249.0,
    verified: true,
    bio: 'Over 10 years of experience resolving low water pressure, pipe leaks, bathroom fittings, motor installation, and drainage blocks. Fast, high-quality, and clean execution.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Tue': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Wed': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Thu': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Fri': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Sat': {'available': true, 'start': '08:00', 'end': '17:00'},
      'Sun': {'available': true, 'start': '09:00', 'end': '14:00'}
    },
    serviceArea: 'Kochi, Kadavanthra, Kaloor, Thevara, and Ernakulam West',
    responseTime: 'Within 20 mins',
    category: 'Plumber',
    phone: '+91 9895100003',
    location: 'Kochi',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p5',
    userId: 'up8', // Shaji N.O.
    businessName: 'Shaji Plumbing Kottayam',
    profession: 'Bathroom Renovation & Plumbing Specialist',
    rating: 4.4,
    reviewCount: 52,
    distance: 3.5,
    startingPrice: 200.0,
    verified: true,
    bio: 'Professional plumbing repair, hot/cold mixer fittings, water tank cleaning, pump installations, and general toilet repairs. Quality materials used, reasonable labor charges.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1542013936693-8848e574047a?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kottayam Town, Chingavanam, and Ettumanoor',
    responseTime: 'Within 1 hour',
    category: 'Plumber',
    phone: '+91 9895100008',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p6',
    userId: 'up16', // Ramesh Nair
    businessName: 'Vembanad Plumbing Services',
    profession: 'General Drainage & Water Supply Plumbing',
    rating: 4.5,
    reviewCount: 30,
    distance: 2.1,
    startingPrice: 199.0,
    verified: false,
    bio: 'Professional leak sealing, faucet replacements, sanitaryware installations, kitchen sink repairs, and overhead tank setups in Alappuzha region.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1581244277943-fe4a9c777189?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Tue': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Wed': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Thu': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Fri': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Sat': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Alappuzha town, Kalavoor, and Ambalappuzha',
    responseTime: 'Within 1.5 hours',
    category: 'Plumber',
    phone: '+91 9895100016',
    location: 'Alappuzha',
    verificationStatus: 'not_submitted',
  ),

  // 3. AC Repair Specialists
  const ServiceProvider(
    id: 'p7',
    userId: 'up1', // Arun Thomas
    businessName: 'Arun AC & Home Appliance Care',
    profession: 'HVAC Specialist & Certified Technician',
    rating: 4.9,
    reviewCount: 124,
    distance: 2.4,
    startingPrice: 399.0,
    verified: true,
    bio: 'Expert diagnostics, servicing, and installation for split and window air conditioners. Deep cleaning, gas refills, and cooling coil replacements. Guaranteed quality workmanship.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1585338111116-20be4406180b?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1527689368864-3a821dbccc34?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '20:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '20:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '20:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '20:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '20:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Sun': {'available': true, 'start': '10:00', 'end': '16:00'}
    },
    serviceArea: 'Kottayam, Changanassery, Thiruvalla, and Chengannur',
    responseTime: 'Within 45 mins',
    category: 'AC Repair',
    phone: '+91 9895100001',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p8',
    userId: 'up13', // Tony Mathew
    businessName: 'Tony AC Mechanicals Kochi',
    profession: 'Inverter AC Service Specialist',
    rating: 4.8,
    reviewCount: 92,
    distance: 3.1,
    startingPrice: 349.0,
    verified: true,
    bio: 'Professional maintenance and repair of major AC brands (Daikin, Voltas, LG, Samsung, Lloyd). 100% customer satisfaction, gas charging, jet pump washing, and sensor repairs.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kochi, Palarivattom, Kakkanad, Aluva, and Kalamassery',
    responseTime: 'Within 1 hour',
    category: 'AC Repair',
    phone: '+91 9895100013',
    location: 'Kochi',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p9',
    userId: 'up25', // Mathew Varghese
    businessName: 'Mathew Aircon Services',
    profession: 'Central Air & Split AC Installer',
    rating: 4.6,
    reviewCount: 45,
    distance: 2.5,
    startingPrice: 399.0,
    verified: true,
    bio: 'Commercial duct cleaning, VRF system service, and split AC repair and installation. Serving homes and offices in Thiruvalla and Pathanamthitta region.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Thiruvalla, Kozhencherry, and Chengannur',
    responseTime: 'Within 2 hours',
    category: 'AC Repair',
    phone: '+91 9895100025',
    location: 'Thiruvalla',
    verificationStatus: 'verified',
  ),

  // 4. Cleaning Services
  const ServiceProvider(
    id: 'p10',
    userId: 'up4', // Mary Skaria
    businessName: 'Marys Deep Cleaning Services',
    profession: 'Professional Sanitization & Deep Cleaner',
    rating: 4.9,
    reviewCount: 112,
    distance: 1.5,
    startingPrice: 799.0,
    verified: true,
    bio: 'Eco-friendly and detailed home deep cleaning, kitchen sanitizing, bathroom scrub down, sofa shampooing, and window glass polishing. Fully trained team with modern vacuum equipment.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:00', 'end': '18:00'},
      'Tue': {'available': true, 'start': '08:00', 'end': '18:00'},
      'Wed': {'available': true, 'start': '08:00', 'end': '18:00'},
      'Thu': {'available': true, 'start': '08:00', 'end': '18:00'},
      'Fri': {'available': true, 'start': '08:00', 'end': '18:00'},
      'Sat': {'available': true, 'start': '08:00', 'end': '18:00'},
      'Sun': {'available': true, 'start': '09:00', 'end': '16:00'}
    },
    serviceArea: 'Kochi city, Fort Kochi, Kakkanad, Vyttila, and Marine Drive',
    responseTime: 'Within 1 hour',
    category: 'Cleaning',
    phone: '+91 9895100004',
    location: 'Kochi',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p11',
    userId: 'up7', // Latha Haridas
    businessName: 'Lathas Eco Cleaners',
    profession: 'Residential & Kitchen Cleaning Specialist',
    rating: 4.7,
    reviewCount: 65,
    distance: 3.0,
    startingPrice: 499.0,
    verified: true,
    bio: 'All-natural chemical-free cleaning products. Specializing in kitchen chimney cleaning, refrigerator sanitizing, cupboard arrangement, and floor mopping in Kottayam.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '16:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kottayam Town, Kanjikuzhy, and Baker Junction',
    responseTime: 'Within 2 hours',
    category: 'Cleaning',
    phone: '+91 9895100007',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p12',
    userId: 'up20', // Simi George
    businessName: 'Simis Clean & Shine',
    profession: 'Eco Maid & Sofa Cleaning Expert',
    rating: 4.6,
    reviewCount: 38,
    distance: 5.4,
    startingPrice: 599.0,
    verified: false,
    bio: 'Professional wet vacuum carpet cleaning, fabric sofa washing, mattress cleaning, and post-construction building dust removal in Thiruvalla.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Tue': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Wed': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Thu': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Fri': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Thiruvalla, Kozhencherry, Mallappally, and Kozhanchery',
    responseTime: 'Within 3 hours',
    category: 'Cleaning',
    phone: '+91 9895100020',
    location: 'Thiruvalla',
    verificationStatus: 'under_review',
  ),

  // 5. Carpenters
  const ServiceProvider(
    id: 'p13',
    userId: 'up5', // Binoy Joseph
    businessName: 'Binoys Furniture & Carpentry',
    profession: 'Modular Woodwork & Carpenter',
    rating: 4.8,
    reviewCount: 88,
    distance: 3.4,
    startingPrice: 299.0,
    verified: true,
    bio: 'Custom modular kitchen building, wooden wardrobe assembly, door repair, latch/lock installations, and teakwood sofa restoration. Precision work with premium finish.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Alappuzha, Cherthala, Mannar, and Kuttanad regions',
    responseTime: 'Within 2 hours',
    category: 'Carpenter',
    phone: '+91 9895100005',
    location: 'Alappuzha',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p14',
    userId: 'up15', // Minu Chacko
    businessName: 'Minu Wood Craft Kottayam',
    profession: 'Furniture Repair & Restoration Expert',
    rating: 4.5,
    reviewCount: 34,
    distance: 1.7,
    startingPrice: 349.0,
    verified: true,
    bio: 'Quick home repair services for broken drawers, sticking wooden doors, window frame repairs, slide channels replacement, and minor polishing jobs.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Tue': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Wed': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Thu': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Fri': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Sat': {'available': true, 'start': '09:00', 'end': '14:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kottayam town, Manarcadu, and Vijayapuram',
    responseTime: 'Within 1.5 hours',
    category: 'Carpenter',
    phone: '+91 9895100015',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p15',
    userId: 'up21', // Biju Joseph
    businessName: 'Biju Hardwood Carpentry',
    profession: 'Staircase & Timber Work Specialist',
    rating: 4.7,
    reviewCount: 56,
    distance: 2.2,
    startingPrice: 290.0,
    verified: true,
    bio: 'Solid hardwood dining table customization, stair handrail installation, partition panelling, and wooden ceiling work. Traditional craftsmanship with modern tools.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1533090161767-e6ffed986c88?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Tue': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Wed': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Thu': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Fri': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Sat': {'available': true, 'start': '08:30', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Changanassery, Payippad, and Perunna areas',
    responseTime: 'Within 2 hours',
    category: 'Carpenter',
    phone: '+91 9895100021',
    location: 'Changanassery',
    verificationStatus: 'verified',
  ),

  // 6. Painters
  const ServiceProvider(
    id: 'p16',
    userId: 'up17', // Geetha Jacob
    businessName: 'Jacob & Co Home Painting',
    profession: 'Interior & Exterior Wall Painter',
    rating: 4.8,
    reviewCount: 74,
    distance: 3.7,
    startingPrice: 1499.0,
    verified: true,
    bio: 'Professional wall texture, premium plastic emulsion painting, exterior weatherproofing, wall putty application, and wood/metal paint services. Clean, dust-free painting.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Tue': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Wed': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Thu': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Fri': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Sat': {'available': true, 'start': '08:30', 'end': '17:30'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kottayam, Puthuppally, Ettumanoor, and Changanassery',
    responseTime: 'Within 2 hours',
    category: 'Painter',
    phone: '+91 9895100017',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p17',
    userId: 'up22', // Lekha Pillai
    businessName: 'Lekhas Wall Decors Kochi',
    profession: 'Designer Wall Texture & Painting Contractor',
    rating: 4.6,
    reviewCount: 41,
    distance: 4.2,
    startingPrice: 1999.0,
    verified: true,
    bio: 'Creative stencil designs, kids bedroom decor themes, waterproof wall coatings, and wallpaper installations. Trained professional team with modern airless spray equipment.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kochi, Kakkanad, Aluva, Kalamassery, and Vyttila',
    responseTime: 'Within 3 hours',
    category: 'Painter',
    phone: '+91 9895100022',
    location: 'Kochi',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p18',
    userId: 'up29', // Vinod K.S.
    businessName: 'Vinod Painting Works Changanassery',
    profession: 'Exterior Weatherproof Painting Specialist',
    rating: 4.4,
    reviewCount: 22,
    distance: 3.1,
    startingPrice: 1200.0,
    verified: false,
    bio: 'Cost-effective white-washing, metal fence enamel painting, primer coating, and pressure-washing exterior walls before repainting.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:30', 'end': '17:00'},
      'Tue': {'available': true, 'start': '08:30', 'end': '17:00'},
      'Wed': {'available': true, 'start': '08:30', 'end': '17:00'},
      'Thu': {'available': true, 'start': '08:30', 'end': '17:00'},
      'Fri': {'available': true, 'start': '08:30', 'end': '17:00'},
      'Sat': {'available': true, 'start': '08:30', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Changanassery town and surrounding villages',
    responseTime: 'Within 4 hours',
    category: 'Painter',
    phone: '+91 9895100029',
    location: 'Changanassery',
    verificationStatus: 'not_submitted',
  ),

  // 7. Computer Repair Techs
  const ServiceProvider(
    id: 'p19',
    userId: 'up19', // Subhash Chandran
    businessName: 'Subhash IT Tech & PC Services',
    profession: 'Hardware Engineer & Laptop Repair Specialist',
    rating: 4.9,
    reviewCount: 110,
    distance: 1.4,
    startingPrice: 299.0,
    verified: true,
    bio: 'Professional laptop repair, hardware upgrades (SSD/RAM), screen replacement, OS reinstallations, keyboard replacements, and printer troubleshooting. Fast, home-visit IT support.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1597872200919-0127a446cb38?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Thiruvalla, Chengannur, Kozhencherry, and Mallappally',
    responseTime: 'Within 30 mins',
    category: 'Computer Repair',
    phone: '+91 9895100019',
    location: 'Thiruvalla',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p20',
    userId: 'up9', // Joby Sebastian
    businessName: 'Joby Computer & CCTV Care',
    profession: 'IT Administrator & CCTV Installer',
    rating: 4.7,
    reviewCount: 63,
    distance: 2.6,
    startingPrice: 349.0,
    verified: true,
    bio: 'On-site home and office computer repair, Wi-Fi router configurations, network troubleshooting, and IP/CCTV security camera setup. Quality work with replacement warranty.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1551703599-6b3e8379aa8c?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kottayam Town, Manarcadu, Kanjikuzhy, and Chingavanam',
    responseTime: 'Within 1 hour',
    category: 'Computer Repair',
    phone: '+91 9895100009',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),

  // 8. Tutors
  const ServiceProvider(
    id: 'p21',
    userId: 'up10', // Priya Rajan
    businessName: 'Priya Rajan Mathematics Classes',
    profession: 'High School & Board Exam Math Tutor',
    rating: 4.9,
    reviewCount: 94,
    distance: 0.8,
    startingPrice: 400.0,
    verified: true,
    bio: 'Individualized home & online tuition for CBSE, ICSE, and Kerala State Syllabus students (Class 8 to 12). Strong focus on base concepts, exam prep, and regular tests.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1577896851231-70ef18881754?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '16:00', 'end': '20:30'},
      'Tue': {'available': true, 'start': '16:00', 'end': '20:30'},
      'Wed': {'available': true, 'start': '16:00', 'end': '20:30'},
      'Thu': {'available': true, 'start': '16:00', 'end': '20:30'},
      'Fri': {'available': true, 'start': '16:00', 'end': '20:30'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kochi, Kadavanthra, Panampilly Nagar, and Ravipuram',
    responseTime: 'Within 1 hour',
    category: 'Tutor',
    phone: '+91 9895100010',
    location: 'Kochi',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p22',
    userId: 'up24', // Preetha Haridas
    businessName: 'Preethas Language Academy',
    profession: 'English Speaking & IELTS Trainer',
    rating: 4.8,
    reviewCount: 57,
    distance: 2.7,
    startingPrice: 500.0,
    verified: true,
    bio: 'Speaking, writing, and reading preparation modules for IELTS/OET. Conversational Spoken English classes for professionals and college students in Alappuzha.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1546410531-bb4caa6b424d?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Tue': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Wed': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Thu': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Fri': {'available': true, 'start': '08:00', 'end': '19:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '16:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Alappuzha town and Kalavoor area',
    responseTime: 'Within 2 hours',
    category: 'Tutor',
    phone: '+91 9895100024',
    location: 'Alappuzha',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p23',
    userId: 'up30', // Deepa Nair
    businessName: 'Deepas Science Hub Kottayam',
    profession: 'Physics & Chemistry Home Teacher',
    rating: 4.7,
    reviewCount: 31,
    distance: 1.5,
    startingPrice: 350.0,
    verified: true,
    bio: 'Focused home tuition for Secondary School science subjects. Interactive explanations, simplified formulas, and visual experiments.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1577896851231-70ef18881754?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '16:30', 'end': '20:00'},
      'Tue': {'available': true, 'start': '16:30', 'end': '20:00'},
      'Wed': {'available': true, 'start': '16:30', 'end': '20:00'},
      'Thu': {'available': true, 'start': '16:30', 'end': '20:00'},
      'Fri': {'available': true, 'start': '16:30', 'end': '20:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '16:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kottayam town, Kanjikuzhy, and Puthuppally',
    responseTime: 'Within 1 hour',
    category: 'Tutor',
    phone: '+91 9895100030',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),

  // 9. Mechanics
  const ServiceProvider(
    id: 'p24',
    userId: 'up14', // Sajith K.P.
    businessName: 'Sajith Automobile Workshop',
    profession: 'Multi-brand Car Mechanic & Electrician',
    rating: 4.8,
    reviewCount: 89,
    distance: 3.3,
    startingPrice: 499.0,
    verified: true,
    bio: 'Professional door-step car breakdown services, engine diagnostics, oil changes, brake pads replacement, battery jumpstarts, and electrical wiring repairs for Hatchbacks, Sedans, and SUVs.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1617406181409-c7194ad3366a?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:30', 'end': '19:30'},
      'Tue': {'available': true, 'start': '08:30', 'end': '19:30'},
      'Wed': {'available': true, 'start': '08:30', 'end': '19:30'},
      'Thu': {'available': true, 'start': '08:30', 'end': '19:30'},
      'Fri': {'available': true, 'start': '08:30', 'end': '19:30'},
      'Sat': {'available': true, 'start': '08:30', 'end': '18:00'},
      'Sun': {'available': true, 'start': '09:00', 'end': '15:00'}
    },
    serviceArea: 'Kochi city, Edappally, Kalamassery, Kakkanad, and Kalamasseri',
    responseTime: 'Within 25 mins',
    category: 'Mechanic',
    phone: '+91 9895100014',
    location: 'Kochi',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p25',
    userId: 'up18', // Vipin Das
    businessName: 'Vipins Two-Wheeler Service',
    profession: 'Motorcycle & Scooter Repair Expert',
    rating: 4.6,
    reviewCount: 67,
    distance: 2.1,
    startingPrice: 299.0,
    verified: true,
    bio: 'Experienced servicing of all popular scooter and bike brands (Activa, Pulsar, Royal Enfield, Access). Brake adjustments, carburetor tuning, chain lubrication, and general wash.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Sat': {'available': true, 'start': '09:00', 'end': '17:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Changanassery, Madappally, and Vazhoor area',
    responseTime: 'Within 45 mins',
    category: 'Mechanic',
    phone: '+91 9895100018',
    location: 'Changanassery',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p26',
    userId: 'up27', // Harish Kumar
    businessName: 'Harish Automobile Diagnostics',
    profession: 'Automotive Electrician & Engine Tuner',
    rating: 4.7,
    reviewCount: 42,
    distance: 1.8,
    startingPrice: 399.0,
    verified: true,
    bio: 'Mobile diagnostic scanner checks, ECU scanning, car air-conditioning repairs, battery replacements, and central lock issues in Kottayam.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:00', 'end': '16:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Kottayam Town and Ettumanoor area',
    responseTime: 'Within 1 hour',
    category: 'Mechanic',
    phone: '+91 9895100027',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),

  // 10. Beauty / Salon
  const ServiceProvider(
    id: 'p27',
    userId: 'up12', // Sunitha Devadas
    businessName: 'Sunithas Bridal & Makeover Studio',
    profession: 'Professional Bridal Make-up Artist & Stylist',
    rating: 4.9,
    reviewCount: 153,
    distance: 1.6,
    startingPrice: 999.0,
    verified: true,
    bio: 'HD Bridal makeup, wedding hair styling, saree draping, facial grooming, clean-ups, waxing, pedicure/manicure, and skin whitening treatments. Premium international beauty brands used.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Tue': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Wed': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Thu': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Fri': {'available': true, 'start': '09:00', 'end': '18:30'},
      'Sat': {'available': true, 'start': '09:00', 'end': '19:00'},
      'Sun': {'available': true, 'start': '09:00', 'end': '15:00'}
    },
    serviceArea: 'Kochi city limits, Ernakulam, and Aluva (Home service available for events)',
    responseTime: 'Within 30 mins',
    category: 'Beauty',
    phone: '+91 9895100012',
    location: 'Kochi',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p28',
    userId: 'up23', // Jaison Abraham
    businessName: 'Jaisons Grooming & Hair Care',
    profession: 'Men\'s Hair Stylist & Groomer',
    rating: 4.7,
    reviewCount: 82,
    distance: 2.3,
    startingPrice: 199.0,
    verified: true,
    bio: 'Professional haircut, hair spa, beard styling, facial detan, and oil head massage. Friendly service at comfort of your home or our studio in Kottayam.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '08:30', 'end': '20:00'},
      'Tue': {'available': true, 'start': '08:30', 'end': '20:00'},
      'Wed': {'available': true, 'start': '08:30', 'end': '20:00'},
      'Thu': {'available': true, 'start': '08:30', 'end': '20:00'},
      'Fri': {'available': true, 'start': '08:30', 'end': '20:00'},
      'Sat': {'available': true, 'start': '08:30', 'end': '20:00'},
      'Sun': {'available': true, 'start': '08:30', 'end': '17:00'}
    },
    serviceArea: 'Kottayam town, Baker Junction, and Kanjikuzhy',
    responseTime: 'Within 45 mins',
    category: 'Beauty',
    phone: '+91 9895100023',
    location: 'Kottayam',
    verificationStatus: 'verified',
  ),
  const ServiceProvider(
    id: 'p29',
    userId: 'up28', // Sherly Joseph
    businessName: 'Sherlys Home Salon Service',
    profession: 'At-home Beauty & Skin Therapist',
    rating: 4.6,
    reviewCount: 51,
    distance: 3.5,
    startingPrice: 399.0,
    verified: true,
    bio: 'Facials, hair coloring, threading, manicure, herbal hair treatment, and skin polishing. Exclusive home service for ladies and kids in Thiruvalla.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:30', 'end': '18:00'},
      'Tue': {'available': true, 'start': '09:30', 'end': '18:00'},
      'Wed': {'available': true, 'start': '09:30', 'end': '18:00'},
      'Thu': {'available': true, 'start': '09:30', 'end': '18:00'},
      'Fri': {'available': true, 'start': '09:30', 'end': '18:00'},
      'Sat': {'available': true, 'start': '09:30', 'end': '18:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Thiruvalla city, Manjadi, and Kozhencherry limits',
    responseTime: 'Within 1 hour',
    category: 'Beauty',
    phone: '+91 9895100028',
    location: 'Thiruvalla',
    verificationStatus: 'verified',
  ),

  // 30th Provider: Extra Plumber/AC Repair in Kochi
  const ServiceProvider(
    id: 'p30',
    userId: 'up26', // Dhanya R.
    businessName: 'Dhanyas AC Repairs & Vent Care',
    profession: 'Appliance Diagnostics & AC Cleaner',
    rating: 4.4,
    reviewCount: 19,
    distance: 4.5,
    startingPrice: 299.0,
    verified: false,
    bio: 'Domestic refrigerator repairs, air conditioner washing, chimney cleaning, and microwave repairs in Alappuzha region.',
    portfolioImages: [
      'https://images.unsplash.com/photo-1621905252507-b354bc25edac?w=600&auto=format&fit=crop'
    ],
    workingHours: {
      'Mon': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Tue': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Wed': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Thu': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Fri': {'available': true, 'start': '09:00', 'end': '17:30'},
      'Sat': {'available': true, 'start': '09:00', 'end': '15:00'},
      'Sun': {'available': false, 'start': '00:00', 'end': '00:00'}
    },
    serviceArea: 'Alappuzha town and nearby beaches',
    responseTime: 'Within 2.5 hours',
    category: 'AC Repair',
    phone: '+91 9895100026',
    location: 'Alappuzha',
    verificationStatus: 'under_review',
  )
];
