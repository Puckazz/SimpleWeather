import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:weather_app/core/api/api_service.dart';
import 'package:weather_app/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/domain/repositories/weather_repository.dart';
import 'package:weather_app/domain/usecases/get_current_weather.dart';
import 'package:weather_app/domain/usecases/get_forecast.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/controllers/theme_controller.dart';
import 'package:weather_app/presentation/controllers/location_controller.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';

/// Dependency Injection Container
/// Tập trung quản lý tất cả dependencies của ứng dụng
class InjectionContainer {
  InjectionContainer._();

  /// Lấy danh sách tất cả providers cho ứng dụng
  static List<SingleChildWidget> get providers => [
    // ===== Core Services =====
    Provider<ApiService>(create: (_) => ApiService()),

    // ===== Controllers (Independent) =====
    ChangeNotifierProvider<ThemeController>(create: (_) => ThemeController()),
    ChangeNotifierProvider<TemperatureUnitController>(
      create: (_) => TemperatureUnitController(),
    ),

    // ===== Location Controller (depends on ApiService) =====
    ChangeNotifierProxyProvider<ApiService, LocationController>(
      create: (_) => LocationController(),
      update: (_, apiService, previous) {
        if (previous != null) {
          previous.updateApiService(apiService);
          return previous;
        }
        return LocationController(apiService: apiService);
      },
    ),

    // ===== Data Layer =====
    ProxyProvider<ApiService, WeatherRemoteDataSource>(
      update: (_, apiService, previous) =>
          WeatherRemoteDataSourceImpl(apiService: apiService),
    ),

    // ===== Repository =====
    ProxyProvider<WeatherRemoteDataSource, WeatherRepository>(
      update: (_, remoteDataSource, previous) =>
          WeatherRepositoryImpl(remoteDataSource: remoteDataSource),
    ),

    // ===== Use Cases =====
    ProxyProvider<WeatherRepository, GetCurrentWeatherUseCase>(
      update: (_, repository, previous) =>
          GetCurrentWeatherUseCase(repository: repository),
    ),
    ProxyProvider<WeatherRepository, GetForecastUseCase>(
      update: (_, repository, previous) =>
          GetForecastUseCase(repository: repository),
    ),

    // ===== Presentation Controllers =====
    ChangeNotifierProxyProvider2<
      GetCurrentWeatherUseCase,
      GetForecastUseCase,
      WeatherController
    >(
      create: (context) => WeatherController(
        getCurrentWeatherUseCase: context.read<GetCurrentWeatherUseCase>(),
        getForecastUseCase: context.read<GetForecastUseCase>(),
      ),
      update: (_, getCurrentWeather, getForecast, previous) =>
          previous ??
          WeatherController(
            getCurrentWeatherUseCase: getCurrentWeather,
            getForecastUseCase: getForecast,
          ),
    ),
  ];
}
