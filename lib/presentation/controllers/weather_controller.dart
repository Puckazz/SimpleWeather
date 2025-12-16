import 'package:flutter/material.dart';
import 'package:weather_app/core/utils/logger.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/usecases/get_weather.dart';

class WeatherController extends ChangeNotifier {
  final GetWeatherUseCase getWeatherUseCase;

  WeatherController({required this.getWeatherUseCase});

  WeatherEntity? _weather;
  bool _isLoading = false;
  String? _error;

  // Getters
  WeatherEntity? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch weather by city name
  Future<void> fetchWeatherByCity(String city) async {
    logger.d('Controller: fetching weather for $city');
    _setLoading(true);
    _error = null;
    try {
      _weather = await getWeatherUseCase.call(city);
      logger.i('Weather fetched successfully for ${_weather?.name}');
      notifyListeners();
    } catch (e) {
      logger.e('Controller error: $e');
      _error = e.toString().replaceAll('Exception: ', '');
      _weather = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch weather by coordinates
  Future<void> fetchWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      _weather = await getWeatherUseCase.callByCoordinates(latitude, longitude);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _weather = null;
      notifyListeners();
    } finally {
      _setLoading(false);
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
    _error = null;
    notifyListeners();
  }
}
