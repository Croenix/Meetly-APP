import '../../core/models/review.dart';

final List<Review> mockReviews = [
  // Rajesh Electrical (p1) reviews
  const Review(
    id: 'r1',
    bookingId: 'b1',
    providerId: 'p1',
    customerName: 'Aarav Nair',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=AaravNair',
    rating: 5.0,
    comment: 'Rajesh did an excellent job installing the ceiling fan. He was very professional, arrived on time, and cleaned up after completing the work. Highly recommended!',
    date: '25 Aug 2026',
    reply: 'Thank you Aarav! It was a pleasure working at your place.',
  ),
  const Review(
    id: 'r2',
    bookingId: 'b_old1',
    providerId: 'p1',
    customerName: 'Neha Roy',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=NehaRoy',
    rating: 4.5,
    comment: 'Very polite and knowledgeable. Quickly identified a short circuit fault in our kitchen switchboard and fixed it. Charges were reasonable.',
    date: '12 Aug 2026',
  ),
  const Review(
    id: 'r3',
    bookingId: 'b_old2',
    providerId: 'p1',
    customerName: 'Anjali Menon',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=AnjaliMenon',
    rating: 5.0,
    comment: 'Super fast response! He reached within 20 minutes of booking and replaced the master MCB switch. Very trustworthy electrician.',
    date: '05 Aug 2026',
    reply: 'Happy to help, Anjali! Glad I could reach you quickly.',
  ),

  // Anil Electrical (p2) reviews
  const Review(
    id: 'r4',
    bookingId: 'b_old3',
    providerId: 'p2',
    customerName: 'Meera Joseph',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=MeeraJoseph',
    rating: 4.5,
    comment: 'Good workmanship. Anil installed our home inverter and explained the safety features clearly. Recommending him to others.',
    date: '22 Aug 2026',
  ),
  const Review(
    id: 'r5',
    bookingId: 'b_old4',
    providerId: 'p2',
    customerName: 'Deepak Kurian',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Deepak',
    rating: 4.8,
    comment: 'Helpful and efficient. Anil fixed multiple light points and ran a new cable connection for our balcony. Clean job.',
    date: '10 Aug 2026',
  ),

  // Suresh Plumbing (p4) reviews
  const Review(
    id: 'r6',
    bookingId: 'b3',
    providerId: 'p4',
    customerName: 'Rahul Krishnan',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=RahulK',
    rating: 5.0,
    comment: 'Excellent plumbing work. Suresh resolved a persistent tap leak that two other plumbers could not fix properly. No leaks since then.',
    date: '15 Aug 2026',
    reply: 'Thank you for the kind words, Rahul! Glad I could resolve it.',
  ),
  const Review(
    id: 'r7',
    bookingId: 'b_old5',
    providerId: 'p4',
    customerName: 'Kiran Paul',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=KiranP',
    rating: 4.0,
    comment: 'Completed the flush tank mechanism replacement quickly. A bit expensive, but quality of work is very good.',
    date: '02 Aug 2026',
  ),

  // Shaji Plumbing (p5) reviews
  const Review(
    id: 'r8',
    bookingId: 'b_old6',
    providerId: 'p5',
    customerName: 'Devika Sunil',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Devika',
    rating: 4.5,
    comment: 'Shaji installed the water pump motor at our home. He was polite, and his work was very neat. Motor is running perfectly.',
    date: '18 Aug 2026',
  ),

  // Arun AC Care (p7) reviews
  const Review(
    id: 'r9',
    bookingId: 'b2',
    providerId: 'p7',
    customerName: 'Meera Joseph',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=MeeraJoseph',
    rating: 5.0,
    comment: 'Fantastic service! Arun did a deep foam jet wash of our split AC. The cooling has improved dramatically and the water leakage is fixed. Very professional.',
    date: '20 Aug 2026',
    reply: 'Thanks Meera! Regular jet cleaning every 6 months prevents most AC blockages.',
  ),
  const Review(
    id: 'r10',
    bookingId: 'b_old7',
    providerId: 'p7',
    customerName: 'Arya S. Kumar',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=AryaSK',
    rating: 4.8,
    comment: 'Arun installed a new Daikin split AC at my office. He was very detailed with routing the copper piping and vacuuming the lines. Highly recommended!',
    date: '14 Aug 2026',
  ),
  const Review(
    id: 'r11',
    bookingId: 'b_old8',
    providerId: 'p7',
    customerName: 'Riya Mathew',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=RiyaMathew',
    rating: 5.0,
    comment: 'Gas refilling was done quickly. He checked for leaks first to make sure gas won\'t leak again. Honesty is appreciated!',
    date: '01 Aug 2026',
    reply: 'Thank you Riya! Yes, checking for micro-leaks is a must before recharging.',
  ),

  // Tony AC Care (p8) reviews
  const Review(
    id: 'r12',
    bookingId: 'b_old9',
    providerId: 'p8',
    customerName: 'Sandra George',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=SandraG',
    rating: 4.7,
    comment: 'Tony replaced the capacitor in our window AC. Fair pricing and fast service. Recommending.',
    date: '11 Aug 2026',
  ),

  // Marys Deep Cleaning (p10) reviews
  const Review(
    id: 'r13',
    bookingId: 'b4',
    providerId: 'p10',
    customerName: 'Riya Mathew',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=RiyaMathew',
    rating: 5.0,
    comment: 'Outstanding deep cleaning of my modular kitchen! Mary and her helper cleaned the greasy cabinets, exhaust fan, and floor till they were shining. Worth every rupee.',
    date: '18 Aug 2026',
    reply: 'Thank you Riya! Clean kitchen, healthy cooking!',
  ),
  const Review(
    id: 'r14',
    bookingId: 'b_old10',
    providerId: 'p10',
    customerName: 'Anjali Menon',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=AnjaliMenon',
    rating: 4.8,
    comment: 'Booked Mary for sofa shampooing. The fabric looks brand new and smells great. Professional equipment used.',
    date: '08 Aug 2026',
  ),

  // Lathas Eco Clean (p11) reviews
  const Review(
    id: 'r15',
    bookingId: 'b_old11',
    providerId: 'p11',
    customerName: 'Neha Roy',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=NehaRoy',
    rating: 4.6,
    comment: 'Latha uses herbal agents which is great for homes with pets. Bathrooms were cleaned beautifully. Good service.',
    date: '10 Aug 2026',
  ),

  // Binoys Furniture (p13) reviews
  const Review(
    id: 'r16',
    bookingId: 'b5',
    providerId: 'p13',
    customerName: 'Adithya Pillai',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Adithya',
    rating: 5.0,
    comment: 'Binoy did a perfect job installing the Godrej main door lock. Very precise wood cutting and lock alignment. Very polite.',
    date: '22 Aug 2026',
    reply: 'Thank you Adithya! Heavy wood doors need perfect chiseling for locks to catch smoothly.',
  ),

  // Minu Wood Craft (p14) reviews
  const Review(
    id: 'r17',
    bookingId: 'b_old12',
    providerId: 'p14',
    customerName: 'Arya S. Kumar',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=AryaSK',
    rating: 4.5,
    comment: 'Minu planed our swollen monsoon bedroom doors. They slide smoothly now. Quick and cheap service.',
    date: '15 Aug 2026',
  ),

  // Biju Hardwood (p15) reviews
  const Review(
    id: 'r18',
    bookingId: 'b_old13',
    providerId: 'p15',
    customerName: 'Manu Varghese',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=ManuV',
    rating: 4.8,
    comment: 'Repolished our dining table set. The teak finish looks extremely glossy. Reliable carpenter.',
    date: '02 Aug 2026',
  ),

  // Jacob & Co Painting (p16) reviews
  const Review(
    id: 'r19',
    bookingId: 'b_old14',
    providerId: 'p16',
    customerName: 'Parvathy Hari',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Parvathy',
    rating: 4.7,
    comment: 'Geetha and her team painted two rooms at our place. Good paint coverage, clean edges, and minimum dust.',
    date: '20 Aug 2026',
  ),

  // Lekhas Wall Decors (p17) reviews
  const Review(
    id: 'r20',
    bookingId: 'b_old15',
    providerId: 'p17',
    customerName: 'Aarav Nair',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=AaravNair',
    rating: 5.0,
    comment: 'Beautiful metallic texture wall created in our living room! Lekha is an artist. Everyone who visits compliments the wall.',
    date: '10 Aug 2026',
    reply: 'Thank you Aarav! That texture pattern is called Safari Dusk.',
  ),

  // Subhash IT Tech (p19) reviews
  const Review(
    id: 'r21',
    bookingId: 'b7',
    providerId: 'p19',
    customerName: 'Deepak Kurian',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Deepak',
    rating: 5.0,
    comment: 'Saved my laptop! The OS was completely corrupted. Subhash installed Windows 11, updated the BIOS, and backed up my important files. Outstanding technical skill.',
    date: '10 Aug 2026',
    reply: 'Glad I could save your files, Deepak. Make sure to back up on cloud occasionally!',
  ),
  const Review(
    id: 'r22',
    bookingId: 'b_old16',
    providerId: 'p19',
    customerName: 'Manu Varghese',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=ManuV',
    rating: 4.8,
    comment: 'Installed 500GB NVMe SSD and 8GB RAM in my old HP laptop. It boots up in 8 seconds now instead of 2 minutes. Excellent work!',
    date: '04 Aug 2026',
  ),

  // Joby Computer Care (p20) reviews
  const Review(
    id: 'r23',
    bookingId: 'b_old17',
    providerId: 'p20',
    customerName: 'Meera Joseph',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=MeeraJoseph',
    rating: 4.6,
    comment: 'Joby installed 4 IP CCTV cameras around our compound. The wiring was neat, and he connected the app to my mobile so I can check live feeds. Very good.',
    date: '13 Aug 2026',
  ),

  // Priya Rajan Classes (p21) reviews
  const Review(
    id: 'r24',
    bookingId: 'b8',
    providerId: 'p21',
    customerName: 'Sandra George',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=SandraG',
    rating: 5.0,
    comment: 'Priya teaches mathematics in a very friendly and simple way. My daughter was struggling with trigonometry, but now she is very confident. Highly recommend her home tuition.',
    date: '12 Aug 2026',
    reply: 'Thank you Sandra! Building confidence is half the battle in mathematics.',
  ),

  // Preethas Academy (p22) reviews
  const Review(
    id: 'r25',
    bookingId: 'b_old18',
    providerId: 'p22',
    customerName: 'Rahul Krishnan',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=RahulK',
    rating: 4.8,
    comment: 'Excellent speaking session practice. Preetha reviews your grammar, suggests better vocabulary, and helps with confidence booster. Got a Band 7.5!',
    date: '01 Aug 2026',
  ),

  // Sajith Automobile (p24) reviews
  const Review(
    id: 'r26',
    bookingId: 'b9',
    providerId: 'p24',
    customerName: 'Gautham S.',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Gautham',
    rating: 5.0,
    comment: 'Sajith came for a battery jumpstart within 15 minutes of booking. He jumpstarted the car, tested my battery health, and confirmed it just needed a recharge. Quick and reliable.',
    date: '14 Aug 2026',
    reply: 'Thank you Gautham! Jumpstarting is easy, but making sure the alternator is charging is key.',
  ),
  const Review(
    id: 'r27',
    bookingId: 'b_old19',
    providerId: 'p24',
    customerName: 'Kiran Paul',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=KiranP',
    rating: 4.8,
    comment: 'Got my Swift serviced here. Oil change, filter swap, and brake pads cleaning done professionally. Reached home delivery.',
    date: '10 Aug 2026',
  ),

  // Vipins Two-Wheeler (p25) reviews
  const Review(
    id: 'r28',
    bookingId: 'b_old20',
    providerId: 'p25',
    customerName: 'Akshay Kumar',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=AkshayK',
    rating: 4.5,
    comment: 'Vipin serviced my Honda Activa. The scooter feels very smooth now, brakes are tight, and engine noise is reduced. Honest rates.',
    date: '06 Aug 2026',
  ),

  // Sunithas Bridal (p27) reviews
  const Review(
    id: 'r29',
    bookingId: 'b6',
    providerId: 'p27',
    customerName: 'Anjali Menon',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=AnjaliMenon',
    rating: 5.0,
    comment: 'Fabulous facial detan service! Sunitha is very gentle and uses excellent organic products. The massage was very relaxing.',
    date: '24 Aug 2026',
    reply: 'Thank you Anjali! Glad you enjoyed the herbal massage.',
  ),
  const Review(
    id: 'r30',
    bookingId: 'b_old21',
    providerId: 'p27',
    customerName: 'Devika Sunil',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Devika',
    rating: 5.0,
    comment: 'Best bridal makeup artist in Kochi. She did my sister\'s wedding look and it was flawless. Saree drapery was tight and beautiful. Highly recommended!',
    date: '28 Jul 2026',
  ),

  // Jaisons Grooming (p28) reviews
  const Review(
    id: 'r31',
    bookingId: 'b10',
    providerId: 'p28',
    customerName: 'Shruti Varma',
    customerAvatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Shruti',
    rating: 5.0,
    comment: 'Jaison did a wonderful home haircut and beard trim for my son. He is very patient and friendly. Excellent styling.',
    date: '17 Aug 2026',
  )
];
