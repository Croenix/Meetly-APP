import '../../core/models/notification_item.dart';

final List<NotificationItem> mockNotifications = [
  // Notifications for Customer 1 (Aarav Nair)
  NotificationItem(
    id: 'n1',
    userId: 'c1',
    title: 'Booking Confirmed! 🎉',
    description: 'Your booking with Rajesh K.R. for Ceiling Fan Installation on 25 Aug has been confirmed.',
    timestamp: DateTime.now().subtract(const Duration(days: 4)),
    isRead: true,
    type: 'booking_accepted',
  ),
  NotificationItem(
    id: 'n2',
    userId: 'c1',
    title: 'Service Completed! 🌟',
    description: 'How was your ceiling fan installation service with Rajesh K.R.? Please leave a review.',
    timestamp: DateTime.now().subtract(const Duration(days: 4, hours: -1)),
    isRead: true,
    type: 'review_request',
  ),
  NotificationItem(
    id: 'n3',
    userId: 'c1',
    title: 'Booking Confirmed! 🎉',
    description: 'Mary Skaria has confirmed your booking for Full Home Deep Sanitization on 31 Aug.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
    type: 'booking_accepted',
  ),

  // Notifications for Customer 2 (Meera Joseph)
  NotificationItem(
    id: 'n4',
    userId: 'c2',
    title: 'Arun is on the way! 📍',
    description: 'Arun Thomas is on the way to your location for Split AC Service.',
    timestamp: DateTime.now().subtract(const Duration(days: 9)),
    isRead: true,
    type: 'booking_reminder',
  ),
  NotificationItem(
    id: 'n5',
    userId: 'c2',
    title: 'Booking Confirmed! 🎉',
    description: 'Anil Kumar has confirmed your booking for LED Tubelight Fitting on 30 Aug.',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    isRead: false,
    type: 'booking_accepted',
  ),

  // Notifications for Customer 3 (Rahul Krishnan)
  NotificationItem(
    id: 'n6',
    userId: 'c3',
    title: 'New Message from Suresh 💬',
    description: 'Suresh: "I am completing a job nearby and can reach your house..."',
    timestamp: DateTime.now().subtract(const Duration(days: 14)),
    isRead: true,
    type: 'new_message',
  ),

  // Notifications for Customer 6 (Anjali Menon)
  NotificationItem(
    id: 'n7',
    userId: 'c6',
    title: 'Booking Confirmed! 🎉',
    description: 'Sunitha Devadas has confirmed your booking for Glow Facial on 24 Aug.',
    timestamp: DateTime.now().subtract(const Duration(days: 6)),
    isRead: true,
    type: 'booking_accepted',
  ),

  // Notifications for Provider 1 (up1 - Arun Thomas)
  NotificationItem(
    id: 'n8',
    userId: 'up1',
    title: 'New Booking Request! 📅',
    description: 'Neha Roy has requested a booking for AC Gas Refill on 02 Sep.',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    isRead: false,
    type: 'booking_reminder',
  ),
  NotificationItem(
    id: 'n9',
    userId: 'up1',
    title: 'New Review Received ⭐⭐⭐⭐⭐',
    description: 'Meera Joseph left a 5-star review: "Fantastic service! Arun did..."',
    timestamp: DateTime.now().subtract(const Duration(days: 9)),
    isRead: true,
    type: 'review_request',
  ),

  // Notifications for Provider 2 (up2 - Rajesh K.R.)
  NotificationItem(
    id: 'n10',
    userId: 'up2',
    title: 'Job Finished! Check Payment 💰',
    description: 'Ceiling Fan Installation job for Aarav Nair marked as completed. Total: ₹249.',
    timestamp: DateTime.now().subtract(const Duration(days: 4)),
    isRead: true,
    type: 'booking_accepted',
  ),
  NotificationItem(
    id: 'n11',
    userId: 'up2',
    title: 'New Message from Meera 💬',
    description: 'Meera: "Hi Rajesh, one of my bedrooms has no power..."',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
    type: 'new_message',
  ),

  // Notifications for Admin 1 (a1 - Rajesh Pillai)
  NotificationItem(
    id: 'n12',
    userId: 'a1',
    title: 'New Provider Verification Request 🛡️',
    description: 'Apex Electricals Changanassery (Manoj Kumar) has submitted documents for verification.',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: false,
    type: 'booking_reminder',
  ),
  NotificationItem(
    id: 'n13',
    userId: 'a1',
    title: 'New Provider Verification Request 🛡️',
    description: 'Simis Clean & Shine (Simi George) has submitted documents for verification.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: false,
    type: 'booking_reminder',
  ),
  NotificationItem(
    id: 'n14',
    userId: 'a1',
    title: 'New Review Moderate Alert ⚠️',
    description: 'A new review comment contains flagged words. Moderate required.',
    timestamp: DateTime.now().subtract(const Duration(days: 5)),
    isRead: true,
    type: 'review_request',
  ),

  // Extra Customer Notification for Customer 12 (Neha Roy)
  NotificationItem(
    id: 'n15',
    userId: 'c12',
    title: 'New Message from Arun 💬',
    description: 'Arun: "What type of gas does the AC use? R32 or R410?"',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
    type: 'new_message',
  ),
];
