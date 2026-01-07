import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:equatable/equatable.dart';

void main() {
  group('WeatherEntity', () {
    const tWeatherEntity = WeatherEntity(
      id: 1,
      name: 'Ho Chi Minh City',
      country: 'VN',
      temperature: 30.5,
      feelsLike: 32.0,
      tempMin: 28.0,
      tempMax: 33.0,
      pressure: 1013,
      humidity: 70,
      visibility: 10000,
      windSpeed: 5.5,
      windDeg: 180.0,
      cloudiness: 40,
      dateTime: 1609459200,
      main: 'Clear',
      description: 'clear sky',
      icon: '01d',
      sunrise: 1609459200,
      sunset: 1609502400,
      timezone: 25200,
    );

    test('should be a subclass of Equatable', () {
      // assert
      expect(tWeatherEntity, isA<Equatable>());
    });

    test('should have correct props', () {
      // act
      final props = tWeatherEntity.props;

      // assert
      expect(props.length, 20);
      expect(props, contains(1)); // id
      expect(props, contains('Ho Chi Minh City')); // name
      expect(props, contains('VN')); // country
      expect(props, contains(30.5)); // temperature
      expect(props, contains(32.0)); // feelsLike
      expect(props, contains(28.0)); // tempMin
      expect(props, contains(33.0)); // tempMax
      expect(props, contains(1013)); // pressure
      expect(props, contains(70)); // humidity
      expect(props, contains(10000)); // visibility
      expect(props, contains(5.5)); // windSpeed
      expect(props, contains(180.0)); // windDeg
      expect(props, contains(40)); // cloudiness
      expect(props, contains(1609459200)); // dateTime
      expect(props, contains('Clear')); // main
      expect(props, contains('clear sky')); // description
      expect(props, contains('01d')); // icon
      expect(props, contains(25200)); // timezone
    });

    test('should support value equality', () {
      // arrange
      const tWeatherEntity2 = WeatherEntity(
        id: 1,
        name: 'Ho Chi Minh City',
        country: 'VN',
        temperature: 30.5,
        feelsLike: 32.0,
        tempMin: 28.0,
        tempMax: 33.0,
        pressure: 1013,
        humidity: 70,
        visibility: 10000,
        windSpeed: 5.5,
        windDeg: 180.0,
        cloudiness: 40,
        dateTime: 1609459200,
        main: 'Clear',
        description: 'clear sky',
        icon: '01d',
        sunrise: 1609459200,
        sunset: 1609502400,
        timezone: 25200,
      );

      // assert
      expect(tWeatherEntity, equals(tWeatherEntity2));
    });

    test('should not be equal when properties differ', () {
      // arrange
      const tWeatherEntity2 = WeatherEntity(
        id: 2,
        name: 'Hanoi',
        country: 'VN',
        temperature: 25.0,
        feelsLike: 26.0,
        tempMin: 23.0,
        tempMax: 27.0,
        pressure: 1015,
        humidity: 65,
        visibility: 10000,
        windSpeed: 4.5,
        windDeg: 90.0,
        cloudiness: 20,
        dateTime: 1609459200,
        main: 'Clouds',
        description: 'few clouds',
        icon: '02d',
        sunrise: 1609459200,
        sunset: 1609502400,
        timezone: 25200,
      );

      // assert
      expect(tWeatherEntity, isNot(equals(tWeatherEntity2)));
    });

    test('should have correct hashCode', () {
      // arrange
      const tWeatherEntity2 = WeatherEntity(
        id: 1,
        name: 'Ho Chi Minh City',
        country: 'VN',
        temperature: 30.5,
        feelsLike: 32.0,
        tempMin: 28.0,
        tempMax: 33.0,
        pressure: 1013,
        humidity: 70,
        visibility: 10000,
        windSpeed: 5.5,
        windDeg: 180.0,
        cloudiness: 40,
        dateTime: 1609459200,
        main: 'Clear',
        description: 'clear sky',
        icon: '01d',
        sunrise: 1609459200,
        sunset: 1609502400,
        timezone: 25200,
      );

      // assert
      expect(tWeatherEntity.hashCode, equals(tWeatherEntity2.hashCode));
    });
  });
}
