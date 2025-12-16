import 'package:equatable/equatable.dart';

class WeatherModel extends Equatable {
  final int id;
  final String name;
  final String country;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final int visibility;
  final double windSpeed;
  final double windDeg;
  final int cloudiness;
  final int dateTime;
  final String main;
  final String description;
  final String icon;
  final int sunrise;
  final int sunset;

  const WeatherModel({
    required this.id,
    required this.name,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    required this.cloudiness,
    required this.dateTime,
    required this.main,
    required this.description,
    required this.icon,
    required this.sunrise,
    required this.sunset,
  });

  /// Convert JSON to WeatherModel
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final sys = json['sys'] as Map<String, dynamic>? ?? {};
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final clouds = json['clouds'] as Map<String, dynamic>? ?? {};
    final weather =
        (json['weather'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final weatherData = weather.isNotEmpty ? weather[0] : {};

    return WeatherModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      country: sys['country'] as String? ?? '',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      pressure: main['pressure'] as int? ?? 0,
      humidity: main['humidity'] as int? ?? 0,
      visibility: json['visibility'] as int? ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      windDeg: (wind['deg'] as num?)?.toDouble() ?? 0.0,
      cloudiness: clouds['all'] as int? ?? 0,
      dateTime: json['dt'] as int? ?? 0,
      main: weatherData['main'] as String? ?? '',
      description: weatherData['description'] as String? ?? '',
      icon: weatherData['icon'] as String? ?? '',
      sunrise: sys['sunrise'] as int? ?? 0,
      sunset: sys['sunset'] as int? ?? 0,
    );
  }

  /// Convert WeatherModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sys': {'country': country, 'sunrise': sunrise, 'sunset': sunset},
      'main': {
        'temp': temperature,
        'feels_like': feelsLike,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'pressure': pressure,
        'humidity': humidity,
      },
      'visibility': visibility,
      'wind': {'speed': windSpeed, 'deg': windDeg},
      'clouds': {'all': cloudiness},
      'dt': dateTime,
      'weather': [
        {'main': main, 'description': description, 'icon': icon},
      ],
    };
  }

  @override
  List<Object> get props => [
    id,
    name,
    country,
    temperature,
    feelsLike,
    tempMin,
    tempMax,
    pressure,
    humidity,
    visibility,
    windSpeed,
    windDeg,
    cloudiness,
    dateTime,
    main,
    description,
    icon,
    sunrise,
    sunset,
  ];
}
