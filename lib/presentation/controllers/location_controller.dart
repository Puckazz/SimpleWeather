import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/core/services/location_service.dart';
import 'package:weather_app/core/api/api_service.dart';
import 'package:weather_app/core/utils/logger.dart';

/// Controller to manage location state
class LocationController extends ChangeNotifier {
  LocationService _locationService;
  static const String _locationPermissionAskedKey = 'location_permission_asked';
  static const String _locationEnabledKey = 'location_enabled';

  LocationController({ApiService? apiService})
    : _locationService = LocationService(apiService: apiService);

  /// Update the API service for location service
  void updateApiService(ApiService apiService) {
    _locationService = LocationService(apiService: apiService);
  }

  LocationData? _currentLocation;
  bool _isLoading = false;
  String? _error;
  bool _isLocationEnabled = false;
  bool _hasAskedPermission = false;

  // Getters
  LocationData? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLocation => _currentLocation != null;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get hasAskedPermission => _hasAskedPermission;

  /// Initialize and check if we should auto-fetch location
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hasAskedPermission = prefs.getBool(_locationPermissionAskedKey) ?? false;
    _isLocationEnabled = prefs.getBool(_locationEnabledKey) ?? false;
    notifyListeners();
  }

  /// Check current permission status
  Future<LocationPermission> checkPermissionStatus() async {
    return await _locationService.checkPermission();
  }

  /// Request permission on first app launch
  Future<bool> requestPermissionOnFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();

    // Mark that we've asked for permission
    await prefs.setBool(_locationPermissionAskedKey, true);
    _hasAskedPermission = true;

    // First check if location services are enabled on device
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.w('Location services are disabled on device');
      _isLocationEnabled = false;
      await prefs.setBool(_locationEnabledKey, false);
      notifyListeners();
      return false;
    }

    try {
      final permission = await _locationService.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        _isLocationEnabled = true;
        await prefs.setBool(_locationEnabledKey, true);
        notifyListeners();
        return true;
      } else {
        _isLocationEnabled = false;
        await prefs.setBool(_locationEnabledKey, false);
        notifyListeners();
        return false;
      }
    } catch (e) {
      logger.e('Error requesting permission: $e');
      _isLocationEnabled = false;
      await prefs.setBool(_locationEnabledKey, false);
      notifyListeners();
      return false;
    }
  }

  /// Toggle location access from settings
  Future<bool> toggleLocationAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final permission = await _locationService.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      // Need to open app settings
      await _locationService.openAppSettings();
      return false;
    }

    if (permission == LocationPermission.denied) {
      // Request permission
      final newPermission = await _locationService.requestPermission();
      if (newPermission == LocationPermission.always ||
          newPermission == LocationPermission.whileInUse) {
        _isLocationEnabled = true;
        await prefs.setBool(_locationEnabledKey, true);
        notifyListeners();
        return true;
      }
      return false;
    }

    // Permission already granted, toggle the setting
    _isLocationEnabled = !_isLocationEnabled;
    await prefs.setBool(_locationEnabledKey, _isLocationEnabled);
    notifyListeners();
    return _isLocationEnabled;
  }

  /// Check and update permission status (call when returning from settings)
  Future<void> refreshPermissionStatus() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if location services are enabled on device
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (_isLocationEnabled) {
        _isLocationEnabled = false;
        await prefs.setBool(_locationEnabledKey, false);
        notifyListeners();
      }
      return;
    }

    final permission = await _locationService.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Permission granted
      if (!_isLocationEnabled) {
        _isLocationEnabled = true;
        await prefs.setBool(_locationEnabledKey, true);
        notifyListeners();
      }
    } else {
      // Permission denied
      if (_isLocationEnabled) {
        _isLocationEnabled = false;
        await prefs.setBool(_locationEnabledKey, false);
        notifyListeners();
      }
    }
  }

  /// Get current location (only if enabled)
  Future<LocationData?> getCurrentLocation() async {
    if (!_isLocationEnabled) {
      logger.d('Location is disabled, skipping fetch');
      return null;
    }

    // Check if location services are enabled on device
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      logger.w('Location services are disabled on device, skipping fetch');
      return null;
    }

    _setLoading(true);
    _error = null;

    try {
      _currentLocation = await _locationService.getCurrentLocation();
      logger.i('Location obtained: ${_currentLocation?.displayName}');
      notifyListeners();
      return _currentLocation;
    } on LocationServiceException catch (e) {
      _error = e.message;
      logger.e('Location error: ${e.message}');
      notifyListeners();
      return null;
    } catch (e) {
      _error = 'Failed to get location. Please try again.';
      logger.e('Unexpected location error: $e');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
