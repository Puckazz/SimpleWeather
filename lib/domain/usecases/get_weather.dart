import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';

class GetWeatherUseCase {
  final WeatherRepository repository;

  GetWeatherUseCase({required this.repository});

  /// Get weather by city name
  Future<WeatherEntity> call(String city) async {
    return await repository.getWeatherByCity(city);
  }

  /// Get weather by coordinates
  Future<WeatherEntity> callByCoordinates(
    double latitude,
    double longitude,
  ) async {
    return await repository.getWeatherByCoordinates(latitude, longitude);
  }
}
