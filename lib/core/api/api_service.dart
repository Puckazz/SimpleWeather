import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weather_app/config/app_config.dart';
import 'package:weather_app/core/utils/logger.dart';

class ApiService {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String geoUrl = 'https://api.openweathermap.org/geo/1.0';
  static const String apiKey = AppConfig.weatherApiKey;

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// Fetch weather data by city name
  Future<Map<String, dynamic>> getWeatherByCity(
    String city, {
    String units = 'metric',
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/weather?q=$city&appid=$apiKey&units=$units',
      );

      logger.d('API: Fetching weather for $city with units=$units');
      logger.d('API URL: $url');

      final response = await client
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Fetch weather data by coordinates
  Future<Map<String, dynamic>> getWeatherByCoordinates(
    double latitude,
    double longitude, {
    String units = 'metric',
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=$units',
      );

      final response = await client
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Search for cities by name
  Future<List<Map<String, dynamic>>> searchCities(
    String cityName, {
    int limit = 10,
  }) async {
    logger.d('Searching cities: $cityName');
    try {
      final url = Uri.parse(
        '$geoUrl/direct?q=$cityName&limit=$limit&appid=$apiKey',
      );

      final response = await client
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        return results.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      logger.e('Error searching cities: $e');
      return [];
    }
  }

  /// Fetch 5-day / 3-hour forecast data by city name
  Future<Map<String, dynamic>> getForecastByCity(
    String city, {
    String units = 'metric',
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/forecast?q=$city&appid=$apiKey&units=$units',
      );

      // logger
      logger.d('API: Fetching forecast for $city with units=$units');

      final response = await client
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        throw Exception('City not found');
      } else {
        throw Exception('Failed to fetch forecast data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Fetch 5-day / 3-hour forecast data by coordinates
  Future<Map<String, dynamic>> getForecastByCoordinates(
    double latitude,
    double longitude, {
    String units = 'metric',
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$apiKey&units=$units',
      );

      final response = await client
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch forecast data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  /// Reverse geocoding: Get location name from coordinates
  Future<Map<String, dynamic>?> reverseGeocode(
    double latitude,
    double longitude, {
    int limit = 1,
  }) async {
    try {
      final url = Uri.parse(
        '$geoUrl/reverse?lat=$latitude&lon=$longitude&limit=$limit&appid=$apiKey',
      );

      logger.d('API: Reverse geocoding for $latitude, $longitude');

      final response = await client
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timeout'),
          );

      if (response.statusCode == 200) {
        final List<dynamic> results = jsonDecode(response.body);
        if (results.isNotEmpty) {
          return results.first as Map<String, dynamic>;
        }
        return null;
      } else {
        logger.w(
          'Reverse geocoding failed with status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      logger.e('Error in reverse geocoding: $e');
      return null;
    }
  }
}
