import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../database/local_database.dart';

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

final userLocationStateProvider = StateProvider<LocationDataResult?>((ref) => null);

class PersistentLocationNotifier extends StateNotifier<String?> {
  PersistentLocationNotifier() : super(null) {
    _loadSavedLocation();
  }

  static const String _storageKey = 'saved_user_location';

  Future<void> _loadSavedLocation() async {
    final saved = await HiveLocalDatabase.instance.getString(_storageKey);
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    }
  }

  Future<void> setLocation(String? address) async {
    state = address;
    if (address != null && address.isNotEmpty) {
      await HiveLocalDatabase.instance.saveString(_storageKey, address);
    }
  }
}

final selectedLocationProvider =
    StateNotifierProvider<PersistentLocationNotifier, String?>((ref) {
  return PersistentLocationNotifier();
});

String? extractPincodeFromAddress(String? address) {
  if (address == null || address.isEmpty) return null;
  final match = RegExp(r'\b\d{6}\b').firstMatch(address);
  return match?.group(0);
}

class LocationDataResult {
  final bool success;
  final String formattedAddress; // e.g. "Kakkanad, Kochi - 682030"
  final String locality;
  final String city;
  final String pincode;
  final double latitude;
  final double longitude;
  final String? errorMessage;

  LocationDataResult({
    required this.success,
    required this.formattedAddress,
    required this.locality,
    required this.city,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    this.errorMessage,
  });
}

class LocationService {
  Future<LocationDataResult> fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _getFallbackLocation('Location services are disabled on device.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _getFallbackLocation('Location permission denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _getFallbackLocation('Location permission permanently denied.');
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        return _getFallbackLocation('Could not acquire GPS position.');
      }

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          String locality = (place.subLocality?.isNotEmpty == true)
              ? place.subLocality!
              : ((place.name?.isNotEmpty == true && place.name != place.locality)
                  ? place.name!
                  : (place.locality?.isNotEmpty == true ? place.locality! : 'Kakkanad'));

          String city = (place.locality?.isNotEmpty == true)
              ? place.locality!
              : ((place.subAdministrativeArea?.isNotEmpty == true)
                  ? place.subAdministrativeArea!
                  : 'Kochi');

          String pincode = (place.postalCode?.isNotEmpty == true)
              ? place.postalCode!
              : '682030';

          String formatted = '$locality, $city - $pincode';

          return LocationDataResult(
            success: true,
            formattedAddress: formatted,
            locality: locality,
            city: city,
            pincode: pincode,
            latitude: position.latitude,
            longitude: position.longitude,
          );
        }
      } catch (_) {
        // Geocoding service fallback
      }

      return LocationDataResult(
        success: true,
        formattedAddress: 'Kakkanad, Kochi - 682030',
        locality: 'Kakkanad',
        city: 'Kochi',
        pincode: '682030',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      return _getFallbackLocation(e.toString());
    }
  }

  LocationDataResult _getFallbackLocation(String reason) {
    return LocationDataResult(
      success: true,
      formattedAddress: 'Kakkanad, Kochi - 682030',
      locality: 'Kakkanad',
      city: 'Kochi',
      pincode: '682030',
      latitude: 9.9816,
      longitude: 76.3570,
      errorMessage: reason,
    );
  }
}
