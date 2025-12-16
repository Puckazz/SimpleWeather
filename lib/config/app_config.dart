class AppConfig {
  static const String weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '',
  );

  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static void validate() {
    if (weatherApiKey.isEmpty) {
      throw Exception(
        '❌ WEATHER_API_KEY is missing.\n'
        'Run app using script or --dart-define.',
      );
    }
  }
}
