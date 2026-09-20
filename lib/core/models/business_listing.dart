import 'dart:math' as math;

class StoreReviewItem {
  final String author;
  final double rating;
  final String text;
  final String time;
  final String profilePhoto;

  StoreReviewItem({
    required this.author,
    required this.rating,
    required this.text,
    required this.time,
    required this.profilePhoto,
  });

  factory StoreReviewItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return StoreReviewItem(
        author: 'Google User',
        rating: 5.0,
        text: 'Great quality and fast service!',
        time: 'Recently',
        profilePhoto: '',
      );
    }
    return StoreReviewItem(
      author: json['author']?.toString() ?? 'Google User',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      text: json['text']?.toString() ?? (json['comment']?.toString() ?? ''),
      time: json['time']?.toString() ?? '',
      profilePhoto: json['profilePhoto']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'author': author,
      'rating': rating,
      'text': text,
      'time': time,
      'profilePhoto': profilePhoto,
    };
  }
}

class BusinessListing {
  final String id;
  final String placeId;
  final String name;
  final String category;
  final List<String> secondaryCategories;
  final String pincode;
  final String address;
  final String phone;
  final double rating;
  final int reviewCount;
  final List<StoreReviewItem> reviews;
  final String imageUrl;
  final List<String> images;
  final double latitude;
  final double longitude;
  final String city;
  final String workingHours;
  final List<String> timetable;
  final bool isOpenNow;
  final String websiteUrl;
  final String mapUrl;

  BusinessListing({
    required this.id,
    required this.placeId,
    required this.name,
    required this.category,
    required this.secondaryCategories,
    required this.pincode,
    required this.address,
    required this.phone,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
    required this.imageUrl,
    required this.images,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.workingHours,
    required this.timetable,
    required this.isOpenNow,
    required this.websiteUrl,
    required this.mapUrl,
  });

  factory BusinessListing.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BusinessListing.fallback();

    List<StoreReviewItem> parseReviews(dynamic raw) {
      if (raw is List) {
        return raw.map((r) => StoreReviewItem.fromJson(r as Map<String, dynamic>?)).toList();
      }
      return [];
    }

    List<String> parseStringList(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return [];
    }

    final idVal = json['id']?.toString() ??
        json['customId']?.toString() ??
        json['_id']?.toString() ??
        'biz_${math.Random().nextInt(999999)}';

    final imagesList = parseStringList(json['images']);
    final fallbackImage = json['imageUrl']?.toString() ??
        (imagesList.isNotEmpty ? imagesList.first : 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500');

    return BusinessListing(
      id: idVal,
      placeId: json['placeId']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Local Business Pro',
      category: json['category']?.toString() ?? 'General',
      secondaryCategories: parseStringList(json['secondaryCategories']),
      pincode: json['pincode']?.toString() ?? '682001',
      address: json['address']?.toString() ?? 'Kochi, Kerala',
      phone: json['phone']?.toString() ?? '+91 9847012345',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? parseReviews(json['reviews']).length,
      reviews: parseReviews(json['reviews']),
      imageUrl: fallbackImage,
      images: imagesList.isNotEmpty ? imagesList : [fallbackImage],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 9.9312,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 76.2673,
      city: json['city']?.toString() ?? 'Kochi',
      workingHours: json['workingHours']?.toString() ?? '08:00 AM - 08:00 PM',
      timetable: parseStringList(json['timetable']),
      isOpenNow: json['isOpenNow'] is bool
          ? json['isOpenNow'] as bool
          : (json['isOpen'] is bool ? json['isOpen'] as bool : true),
      websiteUrl: json['websiteUrl']?.toString() ?? '',
      mapUrl: json['mapUrl']?.toString() ?? '',
    );
  }

  factory BusinessListing.fallback() {
    return BusinessListing(
      id: 'biz_default',
      placeId: 'place_default',
      name: 'Kerala Expert Electrical & Hardware',
      category: 'Electricians',
      secondaryCategories: ['Electricians', 'Hardware'],
      pincode: '682001',
      address: 'MG Road, Kochi, Ernakulam, Kerala',
      phone: '+91 9847000000',
      rating: 4.8,
      reviewCount: 24,
      reviews: [
        StoreReviewItem(
          author: 'Anil Kumar',
          rating: 5.0,
          text: 'Excellent service and genuine electrical products!',
          time: '2 days ago',
          profilePhoto: '',
        ),
        StoreReviewItem(
          author: 'Suresh V.',
          rating: 4.5,
          text: 'Very helpful staff and open on Sundays.',
          time: '1 week ago',
          profilePhoto: '',
        ),
      ],
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
      images: ['https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500'],
      latitude: 9.9312,
      longitude: 76.2673,
      city: 'Kochi',
      workingHours: '08:00 AM - 08:00 PM',
      timetable: [
        'Monday: 8:00 AM – 8:00 PM',
        'Tuesday: 8:00 AM – 8:00 PM',
        'Wednesday: 8:00 AM – 8:00 PM',
        'Thursday: 8:00 AM – 8:00 PM',
        'Friday: 8:00 AM – 8:00 PM',
        'Saturday: 8:00 AM – 8:00 PM',
        'Sunday: Closed'
      ],
      isOpenNow: true,
      websiteUrl: 'https://meetly.pro',
      mapUrl: 'https://maps.google.com',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'name': name,
      'category': category,
      'secondaryCategories': secondaryCategories,
      'pincode': pincode,
      'address': address,
      'phone': phone,
      'rating': rating,
      'reviewCount': reviewCount,
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'imageUrl': imageUrl,
      'images': images,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'workingHours': workingHours,
      'timetable': timetable,
      'isOpenNow': isOpenNow,
      'websiteUrl': websiteUrl,
      'mapUrl': mapUrl,
    };
  }
}

