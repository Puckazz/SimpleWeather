import 'package:weather_app/core/api/api_service.dart';
import 'package:weather_app/core/utils/logger.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/data/models/forecast_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getWeatherByCity(String city, {String units});
  Future<WeatherModel> getWeatherByCoordinates(
    double latitude,
    double longitude, {
    String units,
  });
  Future<ForecastModel> getForecastByCity(String city, {String units});
  Future<ForecastModel> getForecastByCoordinates(
    double latitude,
    double longitude, {
    String units,
  });
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final ApiService apiService;

  WeatherRemoteDataSourceImpl({required this.apiService});

  @override
  Future<WeatherModel> getWeatherByCity(
    String city, {
    String units = 'metric',
  }) async {
    logger.d('Fetching weather for city: $city with units: $units');
    try {
      final jsonData = await apiService.getWeatherByCity(city, units: units);
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
    double longitude, {
    String units = 'metric',
  }) async {
    try {
      final jsonData = await apiService.getWeatherByCoordinates(
        latitude,
        longitude,
        units: units,
      );
      return WeatherModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to fetch weather data: $e');
    }
  }

  @override
  Future<ForecastModel> getForecastByCity(
    String city, {
    String units = 'metric',
  }) async {
    logger.d('Fetching forecast for city: $city with units: $units');
    try {
      final jsonData = await apiService.getForecastByCity(city, units: units);
      logger.d('Forecast data fetched successfully');
      return ForecastModel.fromJson(jsonData);
    } catch (e) {
      logger.e('DataSource error fetching forecast: $e');
      rethrow;
    }
  }

  @override
  Future<ForecastModel> getForecastByCoordinates(
    double latitude,
    double longitude, {
    String units = 'metric',
  }) async {
    try {
      final jsonData = await apiService.getForecastByCoordinates(
        latitude,
        longitude,
        units: units,
      );
      return ForecastModel.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to fetch forecast data: $e');
    }
  }
}
