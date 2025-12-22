import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Helper class for weather-related utilities
class WeatherHelpers {
  WeatherHelpers._();

  /// Get weather icon based on condition and time of day
  static IconData getWeatherIcon(String condition, String iconCode) {
    final isNight = iconCode.endsWith('n');

    switch (condition.toLowerCase()) {
      case 'clear':
        return isNight
            ? CupertinoIcons.moon_stars_fill
            : CupertinoIcons.sun_max_fill;
      case 'clouds':
        return isNight
            ? CupertinoIcons.cloud_moon_fill
            : CupertinoIcons.cloud_fill;
      case 'rain':
      case 'drizzle':
        return CupertinoIcons.cloud_rain_fill;
      case 'thunderstorm':
        return CupertinoIcons.cloud_bolt_fill;
      case 'snow':
        return CupertinoIcons.snow;
      case 'mist':
      case 'fog':
      case 'haze':
        return CupertinoIcons.cloud_fog_fill;
      case 'smoke':
        return CupertinoIcons.smoke_fill;
      default:
        return CupertinoIcons.cloud;
    }
  }

  /// Get weather color based on condition and time of day
  static Color getWeatherColor(String condition, String iconCode) {
    final isNight = iconCode.endsWith('n');

    switch (condition.toLowerCase()) {
      case 'clear':
        return isNight ? Colors.indigo : Colors.amber;
      case 'clouds':
        return Colors.grey;
      case 'rain':
      case 'drizzle':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.deepPurple;
      case 'snow':
        return Colors.lightBlue;
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  /// Get human-readable condition text based on condition and time of day
  static String getConditionText(String condition, [String? iconCode]) {
    final isNight = iconCode?.endsWith('n') ?? false;

    switch (condition.toLowerCase()) {
      case 'clear':
        return isNight ? 'Clear' : 'Sunny';
      case 'clouds':
        return 'Cloudy';
      case 'rain':
        return 'Rain';
      case 'drizzle':
        return 'Drizzle';
      case 'thunderstorm':
        return 'Storm';
      case 'snow':
        return 'Snow';
      case 'mist':
        return 'Mist';
      case 'fog':
        return 'Fog';
      case 'haze':
        return 'Haze';
      case 'smoke':
        return 'Smoke';
      default:
        return condition;
    }
  }

  /// Get local time string from timezone offset
  static String getLocalTime(int timezoneOffset) {
    final nowUtc = DateTime.now().toUtc();
    final localTime = nowUtc.add(Duration(seconds: timezoneOffset));
    final hour = localTime.hour;
    final minute = localTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
