class ServiceItem {
  final String id;
  final String providerId;
  final String name;
  final String description;
  final double price;
  final String priceType; // 'fixed' or 'hourly'
  final String duration;  // e.g. '1 hour', '2-3 hours'
  final String category;

  const ServiceItem({
    required this.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.price,
    required this.priceType,
    required this.duration,
    required this.category,
  });

  ServiceItem copyWith({
    String? id,
    String? providerId,
    String? name,
    String? description,
    double? price,
    String? priceType,
    String? duration,
    String? category,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      priceType: priceType ?? this.priceType,
      duration: duration ?? this.duration,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'name': name,
      'description': description,
      'price': price,
      'priceType': priceType,
      'duration': duration,
      'category': category,
    };
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      priceType: json['priceType'] as String,
      duration: json['duration'] as String,
      category: json['category'] as String,
    );
  }
}
