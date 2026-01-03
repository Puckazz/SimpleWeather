import 'package:flutter/material.dart';
import 'package:weather_app/core/utils/logger.dart';
import 'package:weather_app/data/models/forecast_model.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/usecases/get_current_weather.dart';
import 'package:weather_app/domain/usecases/get_forecast.dart';

class WeatherController extends ChangeNotifier {
  final GetCurrentWeatherUseCase getCurrentWeatherUseCase;
  final GetForecastUseCase getForecastUseCase;

  WeatherController({
    required this.getCurrentWeatherUseCase,
    required this.getForecastUseCase,
  });

  WeatherEntity? _weather;
  ForecastModel? _forecast;
  bool _isLoading = false;
  String? _error;
  String _currentCity = '';
  String? _displayName;

  // Getters
  WeatherEntity? get weather => _weather;
  ForecastModel? get forecast => _forecast;
  List<ForecastItem> get hourlyForecast => _forecast?.hourlyForecast ?? [];
  List<DailyForecast> get dailyForecast => _forecast?.dailyForecast ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCity => _currentCity;
  String get displayName => _displayName ?? _weather?.name ?? _currentCity;

  /// Fetch weather by city name (always fetch in metric/Celsius)
  Future<void> fetchWeatherByCity(
    String city, {
    String units = 'metric',
  }) async {
    logger.d(
      'Controller: fetching weather for $city (always using metric for storage)',
    );
    _currentCity = city;
    _displayName = city;
    _setLoading(true);
    _error = null;
    try {
      // Always fetch with metric (Celsius) for consistent storage
      final results = await Future.wait([
        getCurrentWeatherUseCase(city, units: 'metric'),
        getForecastUseCase(city, units: 'metric'),
      ]);

      _weather = results[0] as WeatherEntity;
      _forecast = results[1] as ForecastModel;

      logger.i(
        'Weather and forecast fetched successfully for ${_weather?.name}',
      );
      notifyListeners();
    } catch (e) {
      logger.e('Controller error: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _weather = null;
      _forecast = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch weather by coordinates (always fetch in metric/Celsius)
  Future<void> fetchWeatherByCoordinates(
    double latitude,
    double longitude, {
    String? displayName,
    String units = 'metric',
  }) async {
    _setLoading(true);
    _error = null;
    try {
      // Always fetch with metric (Celsius) for consistent storage
      final results = await Future.wait([
        getCurrentWeatherUseCase.byCoordinates(
          latitude,
          longitude,
          units: 'metric',
        ),
        getForecastUseCase.byCoordinates(latitude, longitude, units: 'metric'),
      ]);

      _weather = results[0] as WeatherEntity;
      _forecast = results[1] as ForecastModel;
      _currentCity = _weather?.name ?? '';

      // Use geocoding displayName (more accurate for location), fallback to API name
      _displayName = displayName ?? _weather?.name;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _weather = null;
      _forecast = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh weather data (no longer needs units parameter)
  /// Temperature conversion is now handled at display time
  Future<void> refreshWithUnits(String units) async {
    logger.d(
      'Controller: refreshWithUnits called, but now just notifying listeners for UI update',
    );

    // Just notify listeners to update UI with new unit
    // Data is always stored in Celsius, conversion happens at display
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clear weather data
  void clearWeather() {
    _weather = null;
    _forecast = null;
    _error = null;
    _currentCity = '';
    notifyListeners();
  }
}
