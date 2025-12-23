import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/data/models/forecast_model.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';

class GetWeatherUseCase {
  final WeatherRepository repository;

  GetWeatherUseCase({required this.repository});

  /// Get weather by city name
  Future<WeatherEntity> call(String city, {String units = 'metric'}) async {
    return await repository.getWeatherByCity(city, units: units);
  }

  /// Get weather by coordinates
  Future<WeatherEntity> callByCoordinates(
    double latitude,
    double longitude, {
    String units = 'metric',
  }) async {
    return await repository.getWeatherByCoordinates(
      latitude,
      longitude,
      units: units,
    );
  }

  /// Get forecast by city name
  Future<ForecastModel> getForecastByCity(
    String city, {
    String units = 'metric',
  }) async {
    return await repository.getForecastByCity(city, units: units);
  }

  /// Get forecast by coordinates
  Future<ForecastModel> getForecastByCoordinates(
    double latitude,
    double longitude, {
    String units = 'metric',
  }) async {
    return await repository.getForecastByCoordinates(
      latitude,
      longitude,
      units: units,
    );
  }
}
