import '../../core/models/service_item.dart';

final List<ServiceItem> mockServices = [
  // Rajesh Electrical (p1)
  const ServiceItem(
    id: 's1',
    providerId: 'p1',
    name: 'Ceiling Fan Installation & Wiring',
    description: 'Mounting and connection of ceiling fans, including speed regulator setting.',
    price: 249.0,
    priceType: 'fixed',
    duration: '30-45 mins',
    category: 'Electrician',
  ),
  const ServiceItem(
    id: 's2',
    providerId: 'p1',
    name: 'Switchboard Repair & Troubleshooting',
    description: 'Replacing burnt switches, loose plugs, or repairing faulty indicator connections.',
    price: 199.0,
    priceType: 'fixed',
    duration: '30 mins',
    category: 'Electrician',
  ),
  const ServiceItem(
    id: 's3',
    providerId: 'p1',
    name: 'Full Apartment Safety Inspection',
    description: 'Complete testing of MCBs, earthing quality, load limits, and checking for wiring leakages.',
    price: 599.0,
    priceType: 'fixed',
    duration: '1-2 hours',
    category: 'Electrician',
  ),

  // Anil Electrical (p2)
  const ServiceItem(
    id: 's4',
    providerId: 'p2',
    name: 'Home Inverter & Battery Installation',
    description: 'Setting up home backup inverters with battery coupling and select-room backup wiring.',
    price: 799.0,
    priceType: 'fixed',
    duration: '1-2 hours',
    category: 'Electrician',
  ),
  const ServiceItem(
    id: 's5',
    providerId: 'p2',
    name: 'LED Tubelight / Wall Bracket Fitting',
    description: 'Installing wall holder, tube fittings, and routing cables.',
    price: 149.0,
    priceType: 'fixed',
    duration: '20 mins',
    category: 'Electrician',
  ),

  // Apex Electricals (p3)
  const ServiceItem(
    id: 's6',
    providerId: 'p3',
    name: 'Commercial Panel Board Repair',
    description: 'Industrial and retail shop distribution panel servicing and fuses replacement.',
    price: 999.0,
    priceType: 'fixed',
    duration: '2-3 hours',
    category: 'Electrician',
  ),

  // Suresh Plumbing (p4)
  const ServiceItem(
    id: 's7',
    providerId: 'p4',
    name: 'Bathroom Tap Leak Repair & Sealing',
    description: 'Fixing dripping faucets, replacement of worn washers, and silicone sealing joints.',
    price: 249.0,
    priceType: 'fixed',
    duration: '30 mins',
    category: 'Plumber',
  ),
  const ServiceItem(
    id: 's8',
    providerId: 'p4',
    name: 'Flush Tank Mechanism Replacement',
    description: 'Installing new syphon/ball-valve kits to resolve continuous toilet flushes.',
    price: 349.0,
    priceType: 'fixed',
    duration: '45 mins',
    category: 'Plumber',
  ),
  const ServiceItem(
    id: 's9',
    providerId: 'p4',
    name: 'Kitchen Sink Drain Clog Removal',
    description: 'Clearing grease and food residue blockages from under-sink waste pipes.',
    price: 299.0,
    priceType: 'fixed',
    duration: '30-60 mins',
    category: 'Plumber',
  ),

  // Shaji Plumbing (p5)
  const ServiceItem(
    id: 's10',
    providerId: 'p5',
    name: 'Water Motor Pump Installation',
    description: 'Installing 0.5HP/1HP domestic water booster pumps with automatic float-switch sensors.',
    price: 899.0,
    priceType: 'fixed',
    duration: '2 hours',
    category: 'Plumber',
  ),
  const ServiceItem(
    id: 's11',
    providerId: 'p5',
    name: 'Shower Head & Mixer fitting',
    description: 'Fitting hot/cold wall mixer controls and overhead shower arms.',
    price: 399.0,
    priceType: 'fixed',
    duration: '45 mins',
    category: 'Plumber',
  ),

  // Vembanad Plumbing (p6)
  const ServiceItem(
    id: 's12',
    providerId: 'p6',
    name: 'Sanitaryware Installation (Washbasin)',
    description: 'Fitting wall-hung or pedestal washbasins, including waste pipe routing.',
    price: 599.0,
    priceType: 'fixed',
    duration: '1-1.5 hours',
    category: 'Plumber',
  ),

  // Arun AC Care (p7)
  const ServiceItem(
    id: 's13',
    providerId: 'p7',
    name: 'Split AC Deep Foam Cleaning Service',
    description: 'Pressure jet pump washing of indoor cooling coils, outdoor condenser, and drain tray flush.',
    price: 499.0,
    priceType: 'fixed',
    duration: '1 hour',
    category: 'AC Repair',
  ),
  const ServiceItem(
    id: 's14',
    providerId: 'p7',
    name: 'AC Gas Refill (R32/R410)',
    description: 'Top-up or complete refilling of refrigerant gas including leak testing.',
    price: 1800.0,
    priceType: 'fixed',
    duration: '1-1.5 hours',
    category: 'AC Repair',
  ),
  const ServiceItem(
    id: 's15',
    providerId: 'p7',
    name: 'New Split AC Installation',
    description: 'Outdoor unit bracket mounting, copper pipe insulation wrapping, wall core-hole drilling, and setup.',
    price: 1499.0,
    priceType: 'fixed',
    duration: '2-3 hours',
    category: 'AC Repair',
  ),

  // Tony AC (p8)
  const ServiceItem(
    id: 's16',
    providerId: 'p8',
    name: 'AC Compressor Relay & Board Repair',
    description: 'Replacing burnt capacitor, overload protector, or repairing indoor unit PCB issues.',
    price: 799.0,
    priceType: 'fixed',
    duration: '1-2 hours',
    category: 'AC Repair',
  ),
  const ServiceItem(
    id: 's17',
    providerId: 'p8',
    name: 'AC Dismantling / Uninstalling',
    description: 'Reclaim gas, remove indoor/outdoor units, and seal wall holes.',
    price: 499.0,
    priceType: 'fixed',
    duration: '45 mins',
    category: 'AC Repair',
  ),

  // Mathew Aircon (p9)
  const ServiceItem(
    id: 's18',
    providerId: 'p9',
    name: 'Duct Cleaning & Commercial Service',
    description: 'Servicing central duct vents, cassette ACs, or multi-split VRV structures.',
    price: 399.0,
    priceType: 'hourly',
    duration: 'Varies',
    category: 'AC Repair',
  ),

  // Marys Deep Cleaning (p10)
  const ServiceItem(
    id: 's19',
    providerId: 'p10',
    name: 'Full Home Deep Sanitization (2 BHK)',
    description: 'Sanding floors, vacuuming, window scrubbing, bathroom descaling, kitchen cleaning, and disinfectant spray.',
    price: 2999.0,
    priceType: 'fixed',
    duration: '5-6 hours',
    category: 'Cleaning',
  ),
  const ServiceItem(
    id: 's20',
    providerId: 'p10',
    name: 'Sofa Deep Shampoo Cleaning (5-Seater)',
    description: 'Dry vacuuming, chemical spot spray, fabric scrubbing, and wet extraction washing.',
    price: 999.0,
    priceType: 'fixed',
    duration: '2 hours',
    category: 'Cleaning',
  ),
  const ServiceItem(
    id: 's21',
    providerId: 'p10',
    name: 'Modular Kitchen Oil & Grease Removal',
    description: 'Degreasing tiles, chimney cabinet wiping, cleaning stainless baskets, and sink scrub.',
    price: 1199.0,
    priceType: 'fixed',
    duration: '3 hours',
    category: 'Cleaning',
  ),

  // Lathas Eco Clean (p11)
  const ServiceItem(
    id: 's22',
    providerId: 'p11',
    name: 'Eco Bathroom Scrub & Disinfection',
    description: 'Deep tile scrubbing, scaling removal from fixtures, and sanitizing toilets with natural agents.',
    price: 499.0,
    priceType: 'fixed',
    duration: '1.5 hours',
    category: 'Cleaning',
  ),

  // Simis Clean (p12)
  const ServiceItem(
    id: 's23',
    providerId: 'p12',
    name: 'Carpet & Rug Wash',
    description: 'Jet washing and shampoo sanitization of large living room rugs.',
    price: 599.0,
    priceType: 'fixed',
    duration: '2 hours',
    category: 'Cleaning',
  ),

  // Binoys Furniture (p13)
  const ServiceItem(
    id: 's24',
    providerId: 'p13',
    name: 'Wooden Door Latch & Lock Installation',
    description: 'Drilling and fitting cylinder handles, security chains, or digital locks on main doors.',
    price: 349.0,
    priceType: 'fixed',
    duration: '1 hour',
    category: 'Carpenter',
  ),
  const ServiceItem(
    id: 's25',
    providerId: 'p13',
    name: 'Modular Wardrobe Assembly',
    description: 'Flatpack furniture assembly (IKEA/Pepperfry style) with alignment checking.',
    price: 899.0,
    priceType: 'fixed',
    duration: '2-3 hours',
    category: 'Carpenter',
  ),

  // Minu Wood Craft (p14)
  const ServiceItem(
    id: 's26',
    providerId: 'p14',
    name: 'Sticking Wood Door & Window Trimming',
    description: 'Sanding/planing swollen wooden doors that drag on the floor during monsoon.',
    price: 299.0,
    priceType: 'fixed',
    duration: '45 mins',
    category: 'Carpenter',
  ),

  // Biju Hardwood (p15)
  const ServiceItem(
    id: 's27',
    providerId: 'p15',
    name: 'Wooden Sofa Refurbishing & Polishing',
    description: 'Stripping old varnish, sandpaper leveling, and double coat PU clear lacquer application.',
    price: 1999.0,
    priceType: 'fixed',
    duration: '1 day',
    category: 'Carpenter',
  ),

  // Jacob & Co Painting (p16)
  const ServiceItem(
    id: 's28',
    providerId: 'p16',
    name: 'Single Room Wall Painting (Acrylic)',
    description: 'Two coats of premium emulsion paint. Includes wall repair, primer coating, and floor covering.',
    price: 2499.0,
    priceType: 'fixed',
    duration: '1 day',
    category: 'Painter',
  ),
  const ServiceItem(
    id: 's29',
    providerId: 'p16',
    name: 'Teak/Wood Varnish & Melamine Polish',
    description: 'Sanding wood furniture or main doors and painting wood protective polish.',
    price: 1499.0,
    priceType: 'fixed',
    duration: '4-6 hours',
    category: 'Painter',
  ),

  // Lekhas Wall Decors (p17)
  const ServiceItem(
    id: 's30',
    providerId: 'p17',
    name: 'Royal Texture Accent Wall Design',
    description: 'Creating designer textures (metallic, stucco, safari, or stencil art) on a focal wall.',
    price: 3499.0,
    priceType: 'fixed',
    duration: '6 hours',
    category: 'Painter',
  ),

  // Vinod Painting (p18)
  const ServiceItem(
    id: 's31',
    providerId: 'p18',
    name: 'Metal Gate & Grill Enamel Paint',
    description: 'Scraping rust, applying yellow oxide primer, and double gloss coating.',
    price: 1199.0,
    priceType: 'fixed',
    duration: '4 hours',
    category: 'Painter',
  ),

  // Subhash IT Tech (p19)
  const ServiceItem(
    id: 's32',
    providerId: 'p19',
    name: 'Laptop OS Reinstallation & Setup',
    description: 'Format, installation of Windows 10/11 or Linux, standard drivers, antivirus, and basic programs.',
    price: 499.0,
    priceType: 'fixed',
    duration: '1-2 hours',
    category: 'Computer Repair',
  ),
  const ServiceItem(
    id: 's33',
    providerId: 'p19',
    name: 'Laptop SSD & RAM Performance Upgrade',
    description: 'Opening case, installing NVMe/SATA SSDs, cloning existing drive to speed up boot times.',
    price: 299.0,
    priceType: 'fixed',
    duration: '45 mins',
    category: 'Computer Repair',
  ),

  // Joby Computer Care (p20)
  const ServiceItem(
    id: 's34',
    providerId: 'p20',
    name: 'Home Wi-Fi Router & Range Extender Setup',
    description: 'Configuring fiber modem, setting SSID passwords, setting up access points for full house coverage.',
    price: 349.0,
    priceType: 'fixed',
    duration: '45 mins',
    category: 'Computer Repair',
  ),
  const ServiceItem(
    id: 's35',
    providerId: 'p20',
    name: '4-Camera CCTV Setup & Wiring',
    description: 'Fitting dome/bullet IP cameras, running coaxial cable, configuring DVR/NVR box, mobile view linking.',
    price: 2499.0,
    priceType: 'fixed',
    duration: '4-5 hours',
    category: 'Computer Repair',
  ),

  // Priya Rajan Classes (p21)
  const ServiceItem(
    id: 's36',
    providerId: 'p21',
    name: 'Class 10 CBSE Math Syllabus (Home Tuition)',
    description: 'Regular 2-hour home teaching sessions for Class 10 Board exam Mathematics.',
    price: 400.0,
    priceType: 'hourly',
    duration: '2 hours',
    category: 'Tutor',
  ),

  // Preethas Academy (p22)
  const ServiceItem(
    id: 's37',
    providerId: 'p22',
    name: 'IELTS Academic Writing & Speaking Prep',
    description: '1-on-1 intensive module covering writing tasks 1/2, speaking cue-card rehearsals, and feedback.',
    price: 500.0,
    priceType: 'hourly',
    duration: '1 hour',
    category: 'Tutor',
  ),

  // Deepas Science Hub (p23)
  const ServiceItem(
    id: 's38',
    providerId: 'p23',
    name: 'Physics/Chemistry Class 9 Tuition',
    description: 'Home teaching for High School science, including formula notebooks and sample question sets.',
    price: 350.0,
    priceType: 'hourly',
    duration: '1.5 hours',
    category: 'Tutor',
  ),

  // Sajith Automobile (p24)
  const ServiceItem(
    id: 's39',
    providerId: 'p24',
    name: 'Car General Servicing (Oil + Filters)',
    description: 'Replacement of engine oil, air filter, oil filter cleaning, fluid levels check, and general washing.',
    price: 1999.0,
    priceType: 'fixed',
    duration: '3 hours',
    category: 'Mechanic',
  ),
  const ServiceItem(
    id: 's40',
    providerId: 'p24',
    name: 'Car Battery Jumpstart & Diagnostic',
    description: 'Emergency home visit with jumper cables, battery health load testing, and alternator output validation.',
    price: 499.0,
    priceType: 'fixed',
    duration: '20 mins',
    category: 'Mechanic',
  ),

  // Vipins Two-Wheeler (p25)
  const ServiceItem(
    id: 's41',
    providerId: 'p25',
    name: 'Scooter Periodic Servicing (Activa/Access)',
    description: 'Engine oil replacement, spark plug cleaning, drum brake adjustment, cable oiling, and body washing.',
    price: 499.0,
    priceType: 'fixed',
    duration: '2 hours',
    category: 'Mechanic',
  ),

  // Harish Automobile (p26)
  const ServiceItem(
    id: 's42',
    providerId: 'p26',
    name: 'OBD Engine Light Scanner Check',
    description: 'Diagnostic ECU scan to read fault codes, clearing lights, and identifying component failure points.',
    price: 599.0,
    priceType: 'fixed',
    duration: '30 mins',
    category: 'Mechanic',
  ),

  // Sunithas Bridal (p27)
  const ServiceItem(
    id: 's43',
    providerId: 'p27',
    name: 'Premium HD Bridal Makeup Package',
    description: 'Includes water-resistant HD foundation, luxury hair design, drapery, eyelashes, and glow setting.',
    price: 9999.0,
    priceType: 'fixed',
    duration: '3 hours',
    category: 'Beauty',
  ),
  const ServiceItem(
    id: 's44',
    providerId: 'p27',
    name: 'Glow Facial & De-Tan Therapy',
    description: 'Gold scrub, herbal steam, face pack massage, and skin brightening detan pack.',
    price: 1199.0,
    priceType: 'fixed',
    duration: '1.5 hours',
    category: 'Beauty',
  ),

  // Jaisons Grooming (p28)
  const ServiceItem(
    id: 's45',
    providerId: 'p28',
    name: 'Premium Men\'s Haircut & Beard Trim',
    description: 'Stylized scissor haircut, warm towel shave, beard detailing, and styling gel treatment.',
    price: 299.0,
    priceType: 'fixed',
    duration: '45 mins',
    category: 'Beauty',
  ),

  // Sherlys Salon (p29)
  const ServiceItem(
    id: 's46',
    providerId: 'p29',
    name: 'Herbal Hair Coloring & Spa (Ladies)',
    description: 'Organic henna coloring or standard L\'Oreal global color application plus scalp conditioning.',
    price: 899.0,
    priceType: 'fixed',
    duration: '2 hours',
    category: 'Beauty',
  ),

  // Dhanyas AC (p30)
  const ServiceItem(
    id: 's47',
    providerId: 'p30',
    name: 'Refrigerator Condenser & Defrost Repair',
    description: 'Replacing faulty defrost timer, fan blade, or gas top-up for double door fridges.',
    price: 699.0,
    priceType: 'fixed',
    duration: '1.5 hours',
    category: 'AC Repair',
  )
];
