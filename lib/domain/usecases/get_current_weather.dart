import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

/// UseCase để lấy thời tiết hiện tại theo tên thành phố
class GetCurrentWeatherUseCase {
  final WeatherRepository repository;

  GetCurrentWeatherUseCase({required this.repository});

  /// Get weather by city name
  Future<WeatherEntity> call(String city, {String units = 'metric'}) async {
    return await repository.getWeatherByCity(city, units: units);
  }

  /// Get weather by coordinates
  Future<WeatherEntity> byCoordinates(
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
}
