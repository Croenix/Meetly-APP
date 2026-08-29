import '../../core/models/chat_message.dart';

final List<ChatMessage> mockMessages = [
  // Conversation 1: c1 (Aarav Nair) and up1 (Arun Thomas - AC Specialist)
  ChatMessage(
    id: 'm1_1',
    senderId: 'c1',
    receiverId: 'up1',
    message: 'Hello Arun, I need an AC gas refill for my Daikin split AC. Are you available tomorrow morning?',
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm1_2',
    senderId: 'up1',
    receiverId: 'c1',
    message: 'Hello Aarav! Yes, I am available tomorrow between 10:00 AM and 1:00 PM. What type of gas does the AC use? R32 or R410?',
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm1_3',
    senderId: 'c1',
    receiverId: 'up1',
    message: 'It is R32 gas. I also think there is a small leak in the outer pipe. Can you check that too?',
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm1_4',
    senderId: 'up1',
    receiverId: 'c1',
    message: 'Yes, definitely. I will check for micro-leaks using nitrogen testing before filling the gas. See you tomorrow around 10:30 AM.',
    timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
    isRead: true,
  ),

  // Conversation 2: c2 (Meera Joseph) and up2 (Rajesh K.R. - Electrician)
  ChatMessage(
    id: 'm2_1',
    senderId: 'c2',
    receiverId: 'up2',
    message: 'Hi Rajesh, one of my bedrooms has no power in any of the sockets. The lights are working fine though. Can you check this?',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm2_2',
    senderId: 'up2',
    receiverId: 'c2',
    message: 'Hi Meera. It sounds like an individual MCB trip or a loose connection in the distribution board. I can visit today at 4 PM.',
    timestamp: DateTime.now().subtract(const Duration(days: 3, hours: -1)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm2_3',
    senderId: 'c2',
    receiverId: 'up2',
    message: '4 PM is perfect. Please let me know the approximate inspection charge.',
    timestamp: DateTime.now().subtract(const Duration(days: 3, hours: -2)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm2_4',
    senderId: 'up2',
    receiverId: 'c2',
    message: 'The base inspection charge is ₹199. If any part needs replacement, it will be extra.',
    timestamp: DateTime.now().subtract(const Duration(days: 3, hours: -3)),
    isRead: true,
  ),

  // Conversation 3: c3 (Rahul Krishnan) and up4 (Suresh Kumar - Plumber)
  ChatMessage(
    id: 'm3_1',
    senderId: 'c3',
    receiverId: 'up4',
    message: 'Hello Suresh, my kitchen sink drain pipe has a heavy leak. The water is flooding the cabinet.',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm3_2',
    senderId: 'up4',
    receiverId: 'c3',
    message: 'Hi Rahul! Please don\'t use the sink for now. I am completing a job nearby and can reach your house in 45 minutes.',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm3_3',
    senderId: 'c3',
    receiverId: 'up4',
    message: 'Thank you! That will be really helpful. Reaching location: Lakeview House near Beach.',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    isRead: true,
  ),

  // Conversation 4: c4 (Riya Mathew) and up10 (Mary Skaria - Cleaner)
  ChatMessage(
    id: 'm4_1',
    senderId: 'c4',
    receiverId: 'up10',
    message: 'Hi Mary, do you bring your own cleaning liquids and vacuum cleaners for kitchen deep cleaning?',
    timestamp: DateTime.now().subtract(const Duration(days: 5)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm4_2',
    senderId: 'up10',
    receiverId: 'c4',
    message: 'Yes Riya, we bring all professional cleaning agents, scrubbing machines, microfiber cloths, and dry/wet vacuum machines. You don\'t need to provide anything.',
    timestamp: DateTime.now().subtract(const Duration(days: 5, hours: -1)),
    isRead: true,
  ),

  // Conversation 5: c5 (Adithya Pillai) and up13 (Tony Mathew - AC)
  ChatMessage(
    id: 'm5_1',
    senderId: 'c5',
    receiverId: 'up13',
    message: 'Hi Tony, do you charge extra for AC installation brackets?',
    timestamp: DateTime.now().subtract(const Duration(days: 6)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm5_2',
    senderId: 'up13',
    receiverId: 'c5',
    message: 'Yes, heavy-duty powder-coated outdoor wall brackets cost ₹750 extra if you don\'t have them. If you purchase them yourself, I will only charge ₹1499 for the labor.',
    timestamp: DateTime.now().subtract(const Duration(days: 6, hours: -2)),
    isRead: true,
  ),

  // Conversation 6: c6 (Anjali Menon) and up12 (Sunitha Devadas - Makeup)
  ChatMessage(
    id: 'm6_1',
    senderId: 'c6',
    receiverId: 'up12',
    message: 'Hi Sunitha, do you do party makeup at the customer\'s home? I have a family function next Sunday.',
    timestamp: DateTime.now().subtract(const Duration(hours: 18)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm6_2',
    senderId: 'up12',
    receiverId: 'c6',
    message: 'Hello Anjali! Yes, I offer doorstep makeup services for groups or special events. Which package are you looking for?',
    timestamp: DateTime.now().subtract(const Duration(hours: 17)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm6_3',
    senderId: 'c6',
    receiverId: 'up12',
    message: 'Just a basic HD makeup and simple hair styling. It is for 2 people.',
    timestamp: DateTime.now().subtract(const Duration(hours: 15)),
    isRead: true,
  ),

  // Conversation 7: c7 (Deepak Kurian) and up19 (Subhash Chandran - Computer Repair)
  ChatMessage(
    id: 'm7_1',
    senderId: 'c7',
    receiverId: 'up19',
    message: 'Hi Subhash, my MacBook Pro screen is flickering. Do you replace MacBook screens?',
    timestamp: DateTime.now().subtract(const Duration(hours: 24)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm7_2',
    senderId: 'up19',
    receiverId: 'c7',
    message: 'Hi Deepak, screen flickering on MacBook might be a flex cable issue or display panel damage. Please share the model number printed on the back.',
    timestamp: DateTime.now().subtract(const Duration(hours: 23)),
    isRead: true,
  ),

  // Conversation 8: c8 (Sandra George) and up21 (Priya Rajan - Tutor)
  ChatMessage(
    id: 'm8_1',
    senderId: 'c8',
    receiverId: 'up21',
    message: 'Hello Priya, do you offer tuition classes for CBSE Class 10 science subjects as well or only mathematics?',
    timestamp: DateTime.now().subtract(const Duration(days: 4)),
    isRead: true,
  ),
  ChatMessage(
    id: 'up21',
    senderId: 'up21',
    receiverId: 'c8',
    message: 'Hello Sandra! I only specialize in Mathematics for Class 9 to 12. However, I can recommend a good Physics tutor from my colleague network if you need.',
    timestamp: DateTime.now().subtract(const Duration(days: 4, hours: -1)),
    isRead: true,
  ),

  // Conversation 9: c9 (Gautham S.) and up24 (Sajith K.P. - Mechanic)
  ChatMessage(
    id: 'm9_1',
    senderId: 'c9',
    receiverId: 'up24',
    message: 'Hi Sajith, do you do wheel balancing and alignment at your workshop?',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm9_2',
    senderId: 'up24',
    receiverId: 'c9',
    message: 'Hi Gautham! Yes, we have 3D wheel alignment and balancing machines at our Palarivattom workshop. You can bring the car anytime before 6:30 PM.',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: false, // Unread message
  ),

  // Conversation 10: c10 (Shruti Varma) and up28 (Jaison Abraham - Grooming)
  ChatMessage(
    id: 'm10_1',
    senderId: 'c10',
    receiverId: 'up28',
    message: 'Hello Jaison, can you visit my residence tomorrow morning around 8 AM for a haircut and facial shave?',
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    isRead: true,
  ),
  ChatMessage(
    id: 'm10_2',
    senderId: 'up28',
    receiverId: 'c10',
    message: 'Sure Shruti, I can slot you in at 8 AM. Please book the "Premium Haircut & Beard Trim" service on the app to lock the booking.',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    isRead: false, // Unread message
  ),
];
