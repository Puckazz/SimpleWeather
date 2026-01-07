import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/domain/usecases/get_current_weather.dart';

import 'get_current_weather_test.mocks.dart';

@GenerateMocks([WeatherRepository])
void main() {
  late GetCurrentWeatherUseCase usecase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    usecase = GetCurrentWeatherUseCase(repository: mockWeatherRepository);
  });

  const tCity = 'Ho Chi Minh City';
  const tUnits = 'metric';
  const tLatitude = 10.8231;
  const tLongitude = 106.6297;

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

  group('GetCurrentWeatherUseCase', () {
    test(
      'should get current weather from the repository by city name',
      () async {
        // arrange
        when(
          mockWeatherRepository.getWeatherByCity(any, units: anyNamed('units')),
        ).thenAnswer((_) async => tWeatherEntity);

        // act
        final result = await usecase(tCity, units: tUnits);

        // assert
        expect(result, equals(tWeatherEntity));
        verify(mockWeatherRepository.getWeatherByCity(tCity, units: tUnits));
        verifyNoMoreInteractions(mockWeatherRepository);
      },
    );

    test(
      'should get current weather with default units when not specified',
      () async {
        // arrange
        when(
          mockWeatherRepository.getWeatherByCity(any, units: anyNamed('units')),
        ).thenAnswer((_) async => tWeatherEntity);

        // act
        final result = await usecase(tCity);

        // assert
        expect(result, equals(tWeatherEntity));
        verify(mockWeatherRepository.getWeatherByCity(tCity, units: 'metric'));
        verifyNoMoreInteractions(mockWeatherRepository);
      },
    );

    test(
      'should get current weather from the repository by coordinates',
      () async {
        // arrange
        when(
          mockWeatherRepository.getWeatherByCoordinates(
            any,
            any,
            units: anyNamed('units'),
          ),
        ).thenAnswer((_) async => tWeatherEntity);

        // act
        final result = await usecase.byCoordinates(
          tLatitude,
          tLongitude,
          units: tUnits,
        );

        // assert
        expect(result, equals(tWeatherEntity));
        verify(
          mockWeatherRepository.getWeatherByCoordinates(
            tLatitude,
            tLongitude,
            units: tUnits,
          ),
        );
        verifyNoMoreInteractions(mockWeatherRepository);
      },
    );

    test(
      'should get current weather by coordinates with default units when not specified',
      () async {
        // arrange
        when(
          mockWeatherRepository.getWeatherByCoordinates(
            any,
            any,
            units: anyNamed('units'),
          ),
        ).thenAnswer((_) async => tWeatherEntity);

        // act
        final result = await usecase.byCoordinates(tLatitude, tLongitude);

        // assert
        expect(result, equals(tWeatherEntity));
        verify(
          mockWeatherRepository.getWeatherByCoordinates(
            tLatitude,
            tLongitude,
            units: 'metric',
          ),
        );
        verifyNoMoreInteractions(mockWeatherRepository);
      },
    );

    test('should throw an exception when repository fails', () async {
      // arrange
      when(
        mockWeatherRepository.getWeatherByCity(any, units: anyNamed('units')),
      ).thenThrow(Exception('Failed to fetch weather'));

      // act
      final call = usecase(tCity, units: tUnits);

      // assert
      expect(call, throwsException);
      verify(mockWeatherRepository.getWeatherByCity(tCity, units: tUnits));
      verifyNoMoreInteractions(mockWeatherRepository);
    });

    test(
      'should throw an exception when repository fails for coordinates',
      () async {
        // arrange
        when(
          mockWeatherRepository.getWeatherByCoordinates(
            any,
            any,
            units: anyNamed('units'),
          ),
        ).thenThrow(Exception('Failed to fetch weather'));

        // act
        final call = usecase.byCoordinates(
          tLatitude,
          tLongitude,
          units: tUnits,
        );

        // assert
        expect(call, throwsException);
        verify(
          mockWeatherRepository.getWeatherByCoordinates(
            tLatitude,
            tLongitude,
            units: tUnits,
          ),
        );
        verifyNoMoreInteractions(mockWeatherRepository);
      },
    );
  });
}
