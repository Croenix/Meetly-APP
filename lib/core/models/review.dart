class Review {
  final String id;
  final String bookingId;
  final String providerId;
  final String customerName;
  final String customerAvatar;
  final double rating;
  final String comment;
  final String date;
  final String? reply;

  const Review({
    required this.id,
    required this.bookingId,
    required this.providerId,
    required this.customerName,
    required this.customerAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.reply,
  });

  Review copyWith({
    String? id,
    String? bookingId,
    String? providerId,
    String? customerName,
    String? customerAvatar,
    double? rating,
    String? comment,
    String? date,
    String? reply,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      providerId: providerId ?? this.providerId,
      customerName: customerName ?? this.customerName,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      reply: reply ?? this.reply,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'providerId': providerId,
      'customerName': customerName,
      'customerAvatar': customerAvatar,
      'rating': rating,
      'comment': comment,
      'date': date,
      'reply': reply,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      providerId: json['providerId'] as String,
      customerName: json['customerName'] as String,
      customerAvatar: json['customerAvatar'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      date: json['date'] as String,
      reply: json['reply'] as String?,
    );
  }
}
