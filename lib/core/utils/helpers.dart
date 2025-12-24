import 'package:intl/intl.dart';

class Helpers {
  /// Convert Celsius to Fahrenheit
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// Convert Fahrenheit to Celsius
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Format temperature with unit conversion
  static String formatTemperature(
    double temperature, {
    bool isFahrenheit = false,
  }) {
    if (isFahrenheit) {
      final fahrenheit = celsiusToFahrenheit(temperature);
      return '${fahrenheit.toStringAsFixed(1)}°F';
    }
    return '${temperature.toStringAsFixed(1)}°C';
  }

  /// Get temperature value with conversion (without symbol)
  static double getTemperature(double celsius, {bool isFahrenheit = false}) {
    return isFahrenheit ? celsiusToFahrenheit(celsius) : celsius;
  }

  /// Format temperature
  static String formatTemperatureSimple(double temperature) {
    return '${temperature.toStringAsFixed(1)}°C';
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  /// Format date only
  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  /// Format time only
  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Convert Unix timestamp to DateTime
  static DateTime unixToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// Get weather description
  static String getWeatherDescription(String main) {
    final descriptions = {
      'Clear': 'Trời quang',
      'Clouds': 'Có mây',
      'Rain': 'Mưa',
      'Drizzle': 'Mưa nhỏ',
      'Thunderstorm': 'Giông bão',
      'Snow': 'Tuyết',
      'Mist': 'Sương mù',
      'Smoke': 'Khói',
      'Haze': 'Sương',
      'Dust': 'Bụi',
      'Fog': 'Sương mù',
      'Sand': 'Cát',
      'Ash': 'Tro',
      'Squall': 'Gió giật',
      'Tornado': 'Lốc xoáy',
    };
    return descriptions[main] ?? main;
  }

  /// Get weather icon based on condition
  static String getWeatherIcon(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
        return '🌫️';
      case 'fog':
      case 'haze':
        return '🌫️';
      default:
        return '🌤️';
    }
  }
}
