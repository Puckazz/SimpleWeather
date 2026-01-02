import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static String get environment => dotenv.env['ENV'] ?? 'dev';


  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static void validate() {
    if (weatherApiKey.isEmpty) {
      throw Exception('WEATHER_API_KEY is not set in .env.local file');
    }
    print('✅ Environment: $environment');
    print('✅ API Key loaded: ${weatherApiKey.substring(0, 8)}...');
  }
}
