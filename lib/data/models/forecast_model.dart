import 'package:equatable/equatable.dart';

/// Model for a single forecast item (3-hour interval)
class ForecastItem extends Equatable {
  final int dateTime;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String main;
  final String description;
  final String icon;
  final int cloudiness;
  final double? rain3h;

  const ForecastItem({
    required this.dateTime,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.main,
    required this.description,
    required this.icon,
    required this.cloudiness,
    this.rain3h,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final clouds = json['clouds'] as Map<String, dynamic>? ?? {};
    final weather =
        (json['weather'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final rain = json['rain'] as Map<String, dynamic>?;

    final weatherData = weather.isNotEmpty ? weather[0] : <String, dynamic>{};

    return ForecastItem(
      dateTime: json['dt'] as int? ?? 0,
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      humidity: main['humidity'] as int? ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      main: weatherData['main'] as String? ?? '',
      description: weatherData['description'] as String? ?? '',
      icon: weatherData['icon'] as String? ?? '',
      cloudiness: clouds['all'] as int? ?? 0,
      rain3h: (rain?['3h'] as num?)?.toDouble(),
    );
  }

  DateTime get dateTimeAsDateTime =>
      DateTime.fromMillisecondsSinceEpoch(dateTime * 1000);

  @override
  List<Object?> get props => [
    dateTime,
    temperature,
    tempMin,
    tempMax,
    humidity,
    windSpeed,
    main,
    description,
    icon,
    cloudiness,
    rain3h,
  ];
}

/// Model for the complete forecast response
class ForecastModel extends Equatable {
  final String cityName;
  final String country;
  final List<ForecastItem> items;

  const ForecastModel({
    required this.cityName,
    required this.country,
    required this.items,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final city = json['city'] as Map<String, dynamic>? ?? {};
    final list = (json['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return ForecastModel(
      cityName: city['name'] as String? ?? '',
      country: city['country'] as String? ?? '',
      items: list.map((item) => ForecastItem.fromJson(item)).toList(),
    );
  }

  /// Get hourly forecast (next 24 hours, 3-hour intervals = 8 items)
  List<ForecastItem> get hourlyForecast {
    return items.take(8).toList();
  }

  /// Get daily forecast (group by day, take max temp for each day)
  List<DailyForecast> get dailyForecast {
    final Map<String, List<ForecastItem>> groupedByDay = {};

    for (final item in items) {
      final date = item.dateTimeAsDateTime;
      final dayKey = '${date.year}-${date.month}-${date.day}';

      if (!groupedByDay.containsKey(dayKey)) {
        groupedByDay[dayKey] = [];
      }
      groupedByDay[dayKey]!.add(item);
    }

    final List<DailyForecast> dailyList = [];

    groupedByDay.forEach((dayKey, dayItems) {
      double minTemp = double.infinity;
      double maxTemp = double.negativeInfinity;
      String mainCondition = dayItems.first.main;
      String icon = dayItems.first.icon;

      for (final item in dayItems) {
        if (item.tempMin < minTemp) minTemp = item.tempMin;
        if (item.tempMax > maxTemp) maxTemp = item.tempMax;
      }

      // Get the most common condition for the day (around noon if available)
      final noonItem = dayItems.firstWhere(
        (item) =>
            item.dateTimeAsDateTime.hour >= 11 &&
            item.dateTimeAsDateTime.hour <= 14,
        orElse: () => dayItems.first,
      );
      mainCondition = noonItem.main;
      icon = noonItem.icon;

      dailyList.add(
        DailyForecast(
          dateTime: dayItems.first.dateTime,
          tempMin: minTemp,
          tempMax: maxTemp,
          main: mainCondition,
          icon: icon,
        ),
      );
    });

    return dailyList.take(7).toList();
  }

  @override
  List<Object> get props => [cityName, country, items];
}

/// Model for daily forecast summary
class DailyForecast extends Equatable {
  final int dateTime;
  final double tempMin;
  final double tempMax;
  final String main;
  final String icon;

  const DailyForecast({
    required this.dateTime,
    required this.tempMin,
    required this.tempMax,
    required this.main,
    required this.icon,
  });

  DateTime get dateTimeAsDateTime =>
      DateTime.fromMillisecondsSinceEpoch(dateTime * 1000);

  String get dayName {
    final now = DateTime.now();
    final date = dateTimeAsDateTime;

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  @override
  List<Object> get props => [dateTime, tempMin, tempMax, main, icon];
}
