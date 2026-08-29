import 'package:flutter/material.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/models/booking.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
  });

  factory StatusBadge.booking(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const StatusBadge(
          label: 'Pending',
          color: Color(0xFFFEF3C7), // soft amber
          textColor: Color(0xFFD97706),
        );
      case BookingStatus.accepted:
        return const StatusBadge(
          label: 'Accepted',
          color: Color(0xFFE0F2FE), // soft light blue
          textColor: Color(0xFF0284C7),
        );
      case BookingStatus.confirmed:
        return const StatusBadge(
          label: 'Confirmed',
          color: Color(0xFFEEF2FF), // soft indigo
          textColor: Color(0xFF4F46E5),
        );
      case BookingStatus.onTheWay:
        return const StatusBadge(
          label: 'On The Way',
          color: Color(0xFFFAE8FF), // soft purple/magenta
          textColor: Color(0xFFC084FC),
        );
      case BookingStatus.inProgress:
        return const StatusBadge(
          label: 'In Progress',
          color: Color(0xFFE0F7FA), // soft cyan
          textColor: Color(0xFF00ACC1),
        );
      case BookingStatus.completed:
        return const StatusBadge(
          label: 'Completed',
          color: Color(0xFFDCFCE7), // soft green
          textColor: Color(0xFF15803D),
        );
      case BookingStatus.cancelled:
        return const StatusBadge(
          label: 'Cancelled',
          color: Color(0xFFFEE2E2), // soft red
          textColor: Color(0xFFB91C1C),
        );
    }
  }

  factory StatusBadge.verified(bool verified) {
    if (verified) {
      return const StatusBadge(
        label: 'Verified',
        color: Color(0xFFE0F2FE), // soft light blue
        textColor: Color(0xFF0284C7),
      );
    } else {
      return const StatusBadge(
        label: 'Unverified',
        color: Color(0xFFF1F5F9), // soft slate grey
        textColor: Color(0xFF64748B),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
