import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/presentation/controllers/location_controller.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';
import 'package:weather_app/presentation/controllers/theme_controller.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/pages/home_page.dart';
import 'package:weather_app/core/utils/logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      logger.i('Initializing app...');

      // Wait a bit to ensure context is ready
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // Initialize controllers
      await _waitForControllersReady();
      await _initializeLocation();

      // Load weather data
      await _loadInitialWeatherData();

      logger.i('App initialization completed');

      // Wait for minimum splash duration
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } catch (e, stackTrace) {
      logger.e('Error during initialization: $e');
      logger.d('Stack trace: $stackTrace');
      // Even on error, navigate to home page after delay
      await Future.delayed(const Duration(milliseconds: 2000));
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    }
  }

  Future<void> _waitForControllersReady() async {
    if (!mounted) return;

    final themeController = context.read<ThemeController>();
    final unitController = context.read<TemperatureUnitController>();

    // Wait for both controllers to finish loading
    while (themeController.isLoading || unitController.isLoading) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
    }

    logger.d('Theme and Temperature Unit controllers ready');
  }

  Future<void> _initializeLocation() async {
    if (!mounted) return;
    final locationController = context.read<LocationController>();
    await locationController.initialize();
    logger.d('Location controller initialized');
  }

  Future<void> _loadInitialWeatherData() async {
    if (!mounted) return;

    final locationController = context.read<LocationController>();
    final weatherController = context.read<WeatherController>();
    final unitController = context.read<TemperatureUnitController>();

    logger.i('Loading initial weather data...');

    try {
      // First time launch - ask for permission
      if (!locationController.hasAskedPermission) {
        final granted = await locationController
            .requestPermissionOnFirstLaunch();
        if (granted) {
          await _fetchWeatherByLocation(
            locationController,
            weatherController,
            unitController,
          );
          return;
        }
      } else if (locationController.isLocationEnabled) {
        // Permission was granted before, fetch location
        await _fetchWeatherByLocation(
          locationController,
          weatherController,
          unitController,
        );
        return;
      }

      // Fallback to default city if location is not available
      logger.d('Loading default city weather');
      await weatherController.fetchWeatherByCity(
        'San Francisco',
        units: unitController.unit,
      );
    } catch (e) {
      logger.e('Error loading weather data: $e');
      // Load default city on error
      await weatherController.fetchWeatherByCity(
        'San Francisco',
        units: unitController.unit,
      );
    }
  }

  Future<void> _fetchWeatherByLocation(
    LocationController locationController,
    WeatherController weatherController,
    TemperatureUnitController unitController,
  ) async {
    final location = await locationController.getCurrentLocation();

    if (location != null) {
      logger.d('Fetching weather for: ${location.displayName}');
      await weatherController.fetchWeatherByCoordinates(
        location.latitude,
        location.longitude,
        displayName: location.displayName,
        units: unitController.unit,
      );
    } else {
      // Fallback to default city
      logger.d('Location not available, loading default city');
      await weatherController.fetchWeatherByCity(
        'San Francisco',
        units: unitController.unit,
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1a1a2e)
          : const Color(0xFF4A90E2),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Weather icon
                    Icon(
                      Icons.wb_cloudy,
                      size: 120,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    // App name
                    Text(
                      'Weather App',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your personal weather companion',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
