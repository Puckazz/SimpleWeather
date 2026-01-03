import 'package:weather_app/data/models/forecast_model.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';

/// Abstract repository interface for weather data operations.
/// This interface belongs in the domain layer and defines the contract
/// that data layer implementations must follow.
abstract class WeatherRepository {
  /// Get weather data by city name
  Future<WeatherEntity> getWeatherByCity(
    String city, {
    String units = 'metric',
  });

  /// Get weather data by coordinates
  Future<WeatherEntity> getWeatherByCoordinates(
    double latitude,
    double longitude, {
    String units = 'metric',
  });

  /// Get forecast data by city name
  Future<ForecastModel> getForecastByCity(
    String city, {
    String units = 'metric',
  });

  /// Get forecast data by coordinates
  Future<ForecastModel> getForecastByCoordinates(
    double latitude,
    double longitude, {
    String units = 'metric',
  });
}
