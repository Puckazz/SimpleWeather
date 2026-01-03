import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:weather_app/config/app_config.dart';
import 'package:weather_app/config/app_theme.dart';
import 'package:weather_app/core/api/api_service.dart';
import 'package:weather_app/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/domain/usecases/get_weather.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/controllers/theme_controller.dart';
import 'package:weather_app/presentation/controllers/location_controller.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'dart:io' show Platform;
import 'package:weather_app/presentation/pages/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env.local");
  AppConfig.validate();

  // Only use DevicePreview on emulator/simulator in debug mode
  final useDevicePreview = kDebugMode && !_isPhysicalDevice();

  runApp(
    useDevicePreview
        ? DevicePreview(enabled: true, builder: (context) => const MyApp())
        : const MyApp(),
  );
}

bool _isPhysicalDevice() {
  if (kIsWeb) return false;

  try {
    final isEmulator =
        Platform.environment.containsKey('FLUTTER_TEST') ||
        Platform.environment.containsKey('ANDROID_EMULATOR');
    return !isEmulator;
  } catch (e) {
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Controller
        ChangeNotifierProvider<ThemeController>(
          create: (_) => ThemeController(),
        ),
        ChangeNotifierProvider<TemperatureUnitController>(
          create: (_) => TemperatureUnitController(),
        ),
        // API Service
        Provider<ApiService>(create: (_) => ApiService()),
        // Location Controller with ApiService dependency
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
        // Remote Data Source
        ProxyProvider<ApiService, WeatherRemoteDataSource>(
          update: (_, apiService, _) =>
              WeatherRemoteDataSourceImpl(apiService: apiService),
        ),
        // Repository
        ProxyProvider<WeatherRemoteDataSource, WeatherRepository>(
          update: (_, remoteDataSource, _) =>
              WeatherRepositoryImpl(remoteDataSource: remoteDataSource),
        ),
        // Use Case
        ProxyProvider<WeatherRepository, GetWeatherUseCase>(
          update: (_, repository, _) =>
              GetWeatherUseCase(repository: repository),
        ),
        // Controller
        ChangeNotifierProxyProvider<GetWeatherUseCase, WeatherController>(
          create: (context) => WeatherController(
            getWeatherUseCase: context.read<GetWeatherUseCase>(),
          ),
          update: (_, getWeatherUseCase, previous) =>
              previous ??
              WeatherController(getWeatherUseCase: getWeatherUseCase),
        ),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Weather App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            locale: kDebugMode && !_isPhysicalDevice()
                ? DevicePreview.locale(context)
                : null,
            builder: kDebugMode && !_isPhysicalDevice()
                ? DevicePreview.appBuilder
                : null,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
