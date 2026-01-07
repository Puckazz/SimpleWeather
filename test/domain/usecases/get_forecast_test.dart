import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_app/data/models/forecast_model.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/domain/usecases/get_forecast.dart';

import 'get_forecast_test.mocks.dart';

@GenerateMocks([WeatherRepository])
void main() {
  late GetForecastUseCase usecase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    usecase = GetForecastUseCase(repository: mockWeatherRepository);
  });

  const tCity = 'Ho Chi Minh City';
  const tUnits = 'metric';
  const tLatitude = 10.8231;
  const tLongitude = 106.6297;

  const tForecastModel = ForecastModel(
    cityName: 'Ho Chi Minh City',
    country: 'VN',
    items: [],
  );

  group('GetForecastUseCase', () {
    test('should get forecast from the repository by city name', () async {
      // arrange
      when(
        mockWeatherRepository.getForecastByCity(any, units: anyNamed('units')),
      ).thenAnswer((_) async => tForecastModel);

      // act
      final result = await usecase(tCity, units: tUnits);

      // assert
      expect(result, equals(tForecastModel));
      verify(mockWeatherRepository.getForecastByCity(tCity, units: tUnits));
      verifyNoMoreInteractions(mockWeatherRepository);
    });

    test('should get forecast with default units when not specified', () async {
      // arrange
      when(
        mockWeatherRepository.getForecastByCity(any, units: anyNamed('units')),
      ).thenAnswer((_) async => tForecastModel);

      // act
      final result = await usecase(tCity);

      // assert
      expect(result, equals(tForecastModel));
      verify(mockWeatherRepository.getForecastByCity(tCity, units: 'metric'));
      verifyNoMoreInteractions(mockWeatherRepository);
    });

    test('should get forecast from the repository by coordinates', () async {
      // arrange
      when(
        mockWeatherRepository.getForecastByCoordinates(
          any,
          any,
          units: anyNamed('units'),
        ),
      ).thenAnswer((_) async => tForecastModel);

      // act
      final result = await usecase.byCoordinates(
        tLatitude,
        tLongitude,
        units: tUnits,
      );

      // assert
      expect(result, equals(tForecastModel));
      verify(
        mockWeatherRepository.getForecastByCoordinates(
          tLatitude,
          tLongitude,
          units: tUnits,
        ),
      );
      verifyNoMoreInteractions(mockWeatherRepository);
    });

    test(
      'should get forecast by coordinates with default units when not specified',
      () async {
        // arrange
        when(
          mockWeatherRepository.getForecastByCoordinates(
            any,
            any,
            units: anyNamed('units'),
          ),
        ).thenAnswer((_) async => tForecastModel);

        // act
        final result = await usecase.byCoordinates(tLatitude, tLongitude);

        // assert
        expect(result, equals(tForecastModel));
        verify(
          mockWeatherRepository.getForecastByCoordinates(
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
        mockWeatherRepository.getForecastByCity(any, units: anyNamed('units')),
      ).thenThrow(Exception('Failed to fetch forecast'));

      // act
      final call = usecase(tCity, units: tUnits);

      // assert
      expect(call, throwsException);
      verify(mockWeatherRepository.getForecastByCity(tCity, units: tUnits));
      verifyNoMoreInteractions(mockWeatherRepository);
    });

    test(
      'should throw an exception when repository fails for coordinates',
      () async {
        // arrange
        when(
          mockWeatherRepository.getForecastByCoordinates(
            any,
            any,
            units: anyNamed('units'),
          ),
        ).thenThrow(Exception('Failed to fetch forecast'));

        // act
        final call = usecase.byCoordinates(
          tLatitude,
          tLongitude,
          units: tUnits,
        );

        // assert
        expect(call, throwsException);
        verify(
          mockWeatherRepository.getForecastByCoordinates(
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
