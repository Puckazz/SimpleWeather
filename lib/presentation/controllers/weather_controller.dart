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

  // Getters
  WeatherEntity? get weather => _weather;
  ForecastModel? get forecast => _forecast;
  List<ForecastItem> get hourlyForecast => _forecast?.hourlyForecast ?? [];
  List<DailyForecast> get dailyForecast => _forecast?.dailyForecast ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch weather by city name
  Future<void> fetchWeatherByCity(String city) async {
    logger.d('Controller: fetching weather for $city');
    _setLoading(true);
    _error = null;
    try {
      // Fetch both weather and forecast in parallel
      final results = await Future.wait([
        getWeatherUseCase.call(city),
        getWeatherUseCase.getForecastByCity(city),
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
    double longitude,
  ) async {
    _setLoading(true);
    _error = null;
    try {
      // Fetch both weather and forecast in parallel
      final results = await Future.wait([
        getWeatherUseCase.callByCoordinates(latitude, longitude),
        getWeatherUseCase.getForecastByCoordinates(latitude, longitude),
      ]);

      _weather = results[0] as WeatherEntity;
      _forecast = results[1] as ForecastModel;

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
    notifyListeners();
  }
}
