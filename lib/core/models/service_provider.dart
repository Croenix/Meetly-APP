class ServiceProvider {
  final String id;
  final String userId;
  final String businessName;
  final String profession;
  final double rating;
  final int reviewCount;
  final double distance;
  final double startingPrice;
  final bool verified;
  final String bio;
  final List<String> portfolioImages;
  final Map<String, dynamic> workingHours; // e.g., {'Mon': {'available': true, 'start': '09:00', 'end': '18:00'}}
  final String serviceArea;
  final String responseTime;
  final String category;
  final String phone;
  final String location;
  final String verificationStatus; // 'not_submitted', 'under_review', 'verified', 'rejected'

  const ServiceProvider({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.profession,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.startingPrice,
    required this.verified,
    required this.bio,
    required this.portfolioImages,
    required this.workingHours,
    required this.serviceArea,
    required this.responseTime,
    required this.category,
    required this.phone,
    required this.location,
    required this.verificationStatus,
  });

  ServiceProvider copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? profession,
    double? rating,
    int? reviewCount,
    double? distance,
    double? startingPrice,
    bool? verified,
    String? bio,
    List<String>? portfolioImages,
    Map<String, dynamic>? workingHours,
    String? serviceArea,
    String? responseTime,
    String? category,
    String? phone,
    String? location,
    String? verificationStatus,
  }) {
    return ServiceProvider(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      profession: profession ?? this.profession,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distance: distance ?? this.distance,
      startingPrice: startingPrice ?? this.startingPrice,
      verified: verified ?? this.verified,
      bio: bio ?? this.bio,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      workingHours: workingHours ?? this.workingHours,
      serviceArea: serviceArea ?? this.serviceArea,
      responseTime: responseTime ?? this.responseTime,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessName': businessName,
      'profession': profession,
      'rating': rating,
      'reviewCount': reviewCount,
      'distance': distance,
      'startingPrice': startingPrice,
      'verified': verified,
      'bio': bio,
      'portfolioImages': portfolioImages,
      'workingHours': workingHours,
      'serviceArea': serviceArea,
      'responseTime': responseTime,
      'category': category,
      'phone': phone,
      'location': location,
      'verificationStatus': verificationStatus,
    };
  }

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as String,
      userId: json['userId'] as String,
      businessName: json['businessName'] as String,
      profession: json['profession'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      distance: (json['distance'] as num).toDouble(),
      startingPrice: (json['startingPrice'] as num).toDouble(),
      verified: json['verified'] as bool,
      bio: json['bio'] as String,
      portfolioImages: List<String>.from(json['portfolioImages'] as List),
      workingHours: Map<String, dynamic>.from(json['workingHours'] as Map),
      serviceArea: json['serviceArea'] as String,
      responseTime: json['responseTime'] as String,
      category: json['category'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      verificationStatus: json['verificationStatus'] as String,
    );
  }
}
