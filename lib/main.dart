import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:weather_app/config/app_config.dart';
import 'package:weather_app/config/app_theme.dart';
import 'package:weather_app/injection_container.dart';
import 'package:weather_app/presentation/controllers/theme_controller.dart';
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
      providers: InjectionContainer.providers,
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
