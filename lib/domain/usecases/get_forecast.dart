import 'package:weather_app/data/models/forecast_model.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

/// UseCase để lấy dự báo thời tiết
class GetForecastUseCase {
  final WeatherRepository repository;

  GetForecastUseCase({required this.repository});

  /// Get forecast by city name
  Future<ForecastModel> call(String city, {String units = 'metric'}) async {
    return await repository.getForecastByCity(city, units: units);
  }

  /// Get forecast by coordinates
  Future<ForecastModel> byCoordinates(
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
