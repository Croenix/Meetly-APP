enum BookingStatus {
  pending,
  accepted,
  confirmed,
  onTheWay,
  inProgress,
  completed,
  cancelled
}

class Booking {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String providerId;
  final String providerName;
  final String providerProfession;
  final String serviceId;
  final String serviceName;
  final String date;
  final String time;
  final String location;
  final double priceEstimate;
  final String description;
  final BookingStatus status;
  final List<Map<String, String>> statusTimeline; // e.g. [{'status': 'pending', 'time': '29 Aug, 06:12 PM'}]

  const Booking({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.providerId,
    required this.providerName,
    required this.providerProfession,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.location,
    required this.priceEstimate,
    required this.description,
    required this.status,
    required this.statusTimeline,
  });

  Booking copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? providerId,
    String? providerName,
    String? providerProfession,
    String? serviceId,
    String? serviceName,
    String? date,
    String? time,
    String? location,
    double? priceEstimate,
    String? description,
    BookingStatus? status,
    List<Map<String, String>>? statusTimeline,
  }) {
    return Booking(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerProfession: providerProfession ?? this.providerProfession,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      priceEstimate: priceEstimate ?? this.priceEstimate,
      description: description ?? this.description,
      status: status ?? this.status,
      statusTimeline: statusTimeline ?? this.statusTimeline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'providerId': providerId,
      'providerName': providerName,
      'providerProfession': providerProfession,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'date': date,
      'time': time,
      'location': location,
      'priceEstimate': priceEstimate,
      'description': description,
      'status': status.name,
      'statusTimeline': statusTimeline,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      providerProfession: json['providerProfession'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      location: json['location'] as String,
      priceEstimate: (json['priceEstimate'] as num).toDouble(),
      description: json['description'] as String,
      status: BookingStatus.values.firstWhere((e) => e.name == json['status']),
      statusTimeline: (json['statusTimeline'] as List)
          .map((item) => Map<String, String>.from(item as Map))
          .toList(),
    );
  }
}
