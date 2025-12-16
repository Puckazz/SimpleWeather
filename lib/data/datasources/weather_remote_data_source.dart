import 'package:weather_app/core/api/api_service.dart';
import 'package:weather_app/core/utils/logger.dart';
import 'package:weather_app/data/models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeatherByCity(String city);
  Future<WeatherModel> getWeatherByCoordinates(
    double latitude,
    double longitude,
  );
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiService apiService;

  WeatherRemoteDataSourceImpl({required this.apiService});

  @override
  Future<WeatherModel> getWeatherByCity(String city) async {
    logger.d('Fetching weather for city: $city');
    try {
      final jsonData = await apiService.getWeatherByCity(city);
      logger.d('Weather data fetched successfully');
      return WeatherModel.fromJson(jsonData);
    } catch (e) {
      logger.e('DataSource error: $e');
      rethrow;
    }
  }

  @override
  Future<WeatherModel> getWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final jsonData = await apiService.getWeatherByCoordinates(
        latitude,
        longitude,
      );
      return WeatherModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }
}
