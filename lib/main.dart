import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/config/app_config.dart';
import 'package:weather_app/core/api/api_service.dart';
import 'package:weather_app/data/datasources/weather_remote_data_source.dart';
import 'package:weather_app/data/repositories/weather_repository_impl.dart';
import 'package:weather_app/domain/usecases/get_weather.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/pages/home_page.dart';

void main() {
  AppConfig.validate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // API Service
        Provider<ApiService>(create: (_) => ApiService()),
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
      child: MaterialApp(
        title: 'Weather App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomePage(),
      ),
    );
  }
}
