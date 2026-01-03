import 'package:weather_app/core/utils/logger.dart';
import 'package:weather_app/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/data/models/weather_model.dart';
import 'package:weather_app/data/models/forecast_model.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WeatherEntity> getWeatherByCity(
    String city, {
    String units = 'metric',
  }) async {
    logger.d('Repository: getting weather for $city with units: $units');
    try {
      final weatherModel = await remoteDataSource.getWeatherByCity(
        city,
        units: units,
      );
      logger.i('Successfully retrieved weather for $city');
      return _modelToEntity(weatherModel);
    } catch (e) {
      logger.e('Repository error: $e');
      rethrow;
    }
  }

  @override
  Future<WeatherEntity> getWeatherByCoordinates(
    double latitude,
    double longitude, {
    String units = 'metric',
  }) async {
    try {
      final weatherModel = await remoteDataSource.getWeatherByCoordinates(
        latitude,
        longitude,
        units: units,
      );
      return _modelToEntity(weatherModel);
    } catch (e) {
      throw Exception('Repository Error: $e');
    }
  }

  @override
  Future<ForecastModel> getForecastByCity(
    String city, {
    String units = 'metric',
  }) async {
    logger.d('Repository: getting forecast for $city with units: $units');
    try {
      final forecastModel = await remoteDataSource.getForecastByCity(
        city,
        units: units,
      );
      logger.i('Successfully retrieved forecast for $city');
      return forecastModel;
    } catch (e) {
      logger.e('Repository error fetching forecast: $e');
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
      final forecastModel = await remoteDataSource.getForecastByCoordinates(
        latitude,
        longitude,
        units: units,
      );
      return forecastModel;
    } catch (e) {
      throw Exception('Repository Error fetching forecast: $e');
    }
  }

  /// Convert WeatherModel to WeatherEntity
  WeatherEntity _modelToEntity(WeatherModel model) {
    return WeatherEntity(
      id: model.id,
      name: model.name,
      country: model.country,
      temperature: model.temperature,
      feelsLike: model.feelsLike,
      tempMin: model.tempMin,
      tempMax: model.tempMax,
      pressure: model.pressure,
      humidity: model.humidity,
      visibility: model.visibility,
      windSpeed: model.windSpeed,
      windDeg: model.windDeg,
      cloudiness: model.cloudiness,
      dateTime: model.dateTime,
      main: model.main,
      description: model.description,
      icon: model.icon,
      sunrise: model.sunrise,
      sunset: model.sunset,
      timezone: model.timezone,
    );
  }
}
