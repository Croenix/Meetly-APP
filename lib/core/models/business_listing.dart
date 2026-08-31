import 'dart:math' as math;

class BusinessListing {
  final String id;
  final String name;
  final String category;
  final String pincode;
  final String address;
  final String phone;
  final double rating;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String city;

  BusinessListing({
    required this.id,
    required this.name,
    required this.category,
    required this.pincode,
    required this.address,
    required this.phone,
    required this.rating,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.city,
  });

  factory BusinessListing.fromJson(Map<String, dynamic>? json) {
    if (json == null) return BusinessListing.fallback();
    return BusinessListing(
      id: json['id']?.toString() ?? 'biz_${math.Random().nextInt(999999)}',
      name: json['name']?.toString() ?? 'Local Business Pro',
      category: json['category']?.toString() ?? 'General',
      pincode: json['pincode']?.toString() ?? '682001',
      address: json['address']?.toString() ?? 'Kochi, Kerala',
      phone: json['phone']?.toString() ?? '+91 9847012345',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      imageUrl: json['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 9.9312,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 76.2673,
      city: json['city']?.toString() ?? 'Kochi',
    );
  }

  factory BusinessListing.fallback() {
    return BusinessListing(
      id: 'biz_default',
      name: 'Kerala Expert Electrician',
      category: 'Electrician',
      pincode: '682001',
      address: 'MG Road, Kochi, Ernakulam',
      phone: '+91 9847000000',
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=500',
      latitude: 9.9312,
      longitude: 76.2673,
      city: 'Kochi',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'pincode': pincode,
      'address': address,
      'phone': phone,
      'rating': rating,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
    };
  }
}
