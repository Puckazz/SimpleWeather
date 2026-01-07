import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static String get environment => dotenv.env['ENV'] ?? 'dev';
  
  // Check hardcoded data usage
  static bool get useHardcodedCities {
    final value = dotenv.env['USE_HARDCODED_DATA']?.toLowerCase();
    return value == 'true';
  }
  
  static bool get isProduction => environment == 'prod';
  static bool get isDevelopment => environment == 'dev';
  
  static String get baseUrl => 'https://api.openweathermap.org/data/2.5';

  // list cities if hardcoded data is used
  static List<Map<String, dynamic>> get defaultCities {
    if (!useHardcodedCities) return [];
    
    return [
      {'name': 'New York', 'lat': 40.7128, 'lon': -74.0060},
      {'name': 'London', 'lat': 51.5074, 'lon': -0.1278},
      {'name': 'Tokyo', 'lat': 35.6762, 'lon': 139.6503},
      {'name': 'Sydney', 'lat': -33.8688, 'lon': 151.2093},
    ];
  }

  static void validate() {
    if (weatherApiKey.isEmpty) {
      throw Exception('WEATHER_API_KEY is not set in .env file');
    }
    print('✅ Environment: $environment');
    print('✅ Use Hardcoded Cities: $useHardcodedCities');
    print('✅ API Key loaded: ${weatherApiKey.substring(0, 8)}...');
  }
}
