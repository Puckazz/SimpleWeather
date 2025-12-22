import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
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
  final int timezone; // Timezone offset in seconds from UTC

  const WeatherEntity({
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
    required this.timezone,
  });

  @override
  List<Object> get props => [
    id,
    name,
    country,
    timezone,
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
