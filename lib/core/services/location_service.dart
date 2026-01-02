import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/core/utils/logger.dart';
import 'package:weather_app/core/api/api_service.dart';

/// Model class to hold location data
class LocationData {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? country;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.country,
  });

  String get displayName {
    if (cityName != null && country != null) {
      return '${_cleanCityName(cityName!)}, $country';
    }
    return cityName != null ? _cleanCityName(cityName!) : 'Current Location';
  }

  /// Clean up city name by removing prefixes and suffixes
  String _cleanCityName(String name) {
    final prefixes = [
      'Thị xã ',
      'Thành phố ',
      'Thị trấn ',
      'Huyện ',
      'Quận ',
      'Phường ',
      'Xã ',
      'City of ',
      'Township of ',
    ];

    final suffixes = [' County', ' Municipality', ' District', ' Province'];

    String cleanName = name;

    // Remove prefixes
    for (final prefix in prefixes) {
      if (cleanName.startsWith(prefix)) {
        cleanName = cleanName.substring(prefix.length);
        break;
      }
    }

    // Remove suffixes
    for (final suffix in suffixes) {
      if (cleanName.endsWith(suffix)) {
        cleanName = cleanName.substring(0, cleanName.length - suffix.length);
        break;
      }
    }

    return cleanName;
  }
}

/// Service to handle location-related operations
class LocationService {
  final ApiService? _apiService;

  LocationService({ApiService? apiService}) : _apiService = apiService;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permission
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get the current position with permission handling
  Future<LocationData> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.w('Location services are disabled');
      throw LocationServiceException(
        'Location services are disabled. Please enable location services in your device settings.',
      );
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        logger.w('Location permission denied');
        throw LocationServiceException(
          'Location permission denied. Please allow location access to use this feature.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      logger.w('Location permission permanently denied');
      throw LocationServiceException(
        'Location permission is permanently denied. Please enable it in your device settings.',
      );
    }

    // Get current position
    logger.d('Getting current position...');
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    logger.i('Position obtained: ${position.latitude}, ${position.longitude}');

    // Get address from coordinates
    String? cityName;
    String? country;

    try {
      logger.d(
        'Attempting native reverse geocoding for: ${position.latitude}, ${position.longitude}',
      );
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      logger.d('Placemarks count: ${placemarks.length}');

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        // Log all available placemark data for debugging
        logger.d(
          'Placemark data: '
          'locality=${placemark.locality}, '
          'subAdmin=${placemark.subAdministrativeArea}, '
          'admin=${placemark.administrativeArea}, '
          'country=${placemark.country}, '
          'isoCode=${placemark.isoCountryCode}',
        );

        cityName =
            placemark.locality ??
            placemark.subAdministrativeArea ??
            placemark.administrativeArea;
        country = placemark.isoCountryCode ?? placemark.country;
        logger.i('Location resolved via native geocoding: $cityName, $country');
      } else {
        logger.w('Native reverse geocoding returned empty placemarks list');
      }
    } catch (e, stackTrace) {
      logger.w('Native geocoding failed: $e');
      logger.d('Geocoding error stack: $stackTrace');

      // Fallback to API-based reverse geocoding
      if (_apiService != null) {
        try {
          logger.i('Trying API-based reverse geocoding...');
          final result = await _apiService.reverseGeocode(
            position.latitude,
            position.longitude,
          );

          if (result != null) {
            cityName = result['name'] as String?;
            country = result['country'] as String?;
            logger.i('Location resolved via API: $cityName, $country');
          } else {
            logger.w('API reverse geocoding returned no results');
          }
        } catch (apiError) {
          logger.w('API reverse geocoding also failed: $apiError');
        }
      } else {
        logger.w('No API service available for fallback geocoding');
      }
    }

    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: cityName,
      country: country,
    );
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}

/// Custom exception for location service errors
class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => message;
}
