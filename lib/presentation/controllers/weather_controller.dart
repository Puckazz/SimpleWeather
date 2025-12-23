import 'package:flutter/material.dart';
import 'package:weather_app/core/utils/logger.dart';
import 'package:weather_app/data/models/forecast_model.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/usecases/get_weather.dart';

class WeatherController extends ChangeNotifier {
  final GetWeatherUseCase getWeatherUseCase;

  WeatherController({required this.getWeatherUseCase});

  WeatherEntity? _weather;
  ForecastModel? _forecast;
  bool _isLoading = false;
  String? _error;
  String _currentCity = '';

  // Getters
  WeatherEntity? get weather => _weather;
  ForecastModel? get forecast => _forecast;
  List<ForecastItem> get hourlyForecast => _forecast?.hourlyForecast ?? [];
  List<DailyForecast> get dailyForecast => _forecast?.dailyForecast ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCity => _currentCity;

  /// Fetch weather by city name
  Future<void> fetchWeatherByCity(String city, {String units = 'metric'}) async {
    logger.d('Controller: fetching weather for $city with units: $units');
    _currentCity = city;
    _setLoading(true);
    _error = null;
    try {
      // Fetch both weather and forecast in parallel
      final results = await Future.wait([
        getWeatherUseCase.call(city, units: units),
        getWeatherUseCase.getForecastByCity(city, units: units),
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

  /// Fetch weather by coordinates
  Future<void> fetchWeatherByCoordinates(
    double latitude,
    double longitude, {
    String units = 'metric',
  }) async {
    _setLoading(true);
    _error = null;
    try {
      // Fetch both weather and forecast in parallel
      final results = await Future.wait([
        getWeatherUseCase.callByCoordinates(latitude, longitude, units: units),
        getWeatherUseCase.getForecastByCoordinates(
          latitude,
          longitude,
          units: units,
        ),
      ]);

      _weather = results[0] as WeatherEntity;
      _forecast = results[1] as ForecastModel;
      _currentCity = _weather?.name ?? '';

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

  /// Refresh weather data with new units
  Future<void> refreshWithUnits(String units) async {
    logger.d('Controller: refreshWithUnits called with units=$units, currentCity=$_currentCity');
    
    // Check if we have weather data
    if (_weather != null && _weather!.name.isNotEmpty) {
      await fetchWeatherByCity(_weather!.name, units: units);
    } else if (_currentCity.isNotEmpty) {
      await fetchWeatherByCity(_currentCity, units: units);
    } else {
      logger.w('Controller: No city to refresh, skipping');
    }
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
