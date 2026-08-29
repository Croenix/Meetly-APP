import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/app_user.dart';
import '../../core/models/booking.dart';
import '../mock/mock_bookings.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookingsForUser(String userId, UserRole role);
  Future<Booking?> getBookingById(String id);
  Future<void> createBooking(Booking booking);
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);
  Future<void> cancelBooking(String bookingId);
}

class MockBookingRepository implements BookingRepository {
  final List<Booking> _bookings = List.from(mockBookings);

  @override
  Future<List<Booking>> getBookingsForUser(String userId, UserRole role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (role == UserRole.customer) {
      return _bookings.where((b) => b.customerId == userId).toList();
    } else if (role == UserRole.provider) {
      // Find associated providerId by matching userId
      // For mock purposes, providerId is 'pX' corresponding to 'upX' user
      final providerId = userId.replaceAll('up', 'p');
      return _bookings.where((b) => b.providerId == providerId).toList();
    } else {
      // Admin gets all bookings
      return _bookings;
    }
  }

  @override
  Future<Booking?> getBookingById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _bookings.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createBooking(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _bookings.add(booking);
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final oldBooking = _bookings[index];
      
      // Build updated timeline
      final formattedTime = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
      final updatedTimeline = List<Map<String, String>>.from(oldBooking.statusTimeline);
      updatedTimeline.add({'status': status.name, 'time': formattedTime});

      _bookings[index] = oldBooking.copyWith(
        status: status,
        statusTimeline: updatedTimeline,
      );
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, BookingStatus.cancelled);
  }
}

// Riverpod Provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return MockBookingRepository();
});

// User-specific Bookings List Provider
final userBookingsProvider = FutureProvider.family<List<Booking>, ({String userId, UserRole role})>((ref, arg) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingsForUser(arg.userId, arg.role);
});

// Single Booking Details Provider
final bookingDetailsProvider = FutureProvider.family<Booking?, String>((ref, id) async {
  final repo = ref.watch(bookingRepositoryProvider);
  return repo.getBookingById(id);
});
