import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/utils/helpers.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';
import 'package:weather_app/presentation/controllers/location_controller.dart';
import 'package:weather_app/presentation/pages/settings_page.dart';
import 'package:weather_app/presentation/pages/manage_cities_page.dart';
import 'package:weather_app/presentation/pages/hourly_forecast_page.dart';
import 'package:weather_app/presentation/pages/next7days_page.dart';
import 'package:weather_app/presentation/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh permission when returning from settings
    if (state == AppLifecycleState.resumed) {
      _checkAndRefreshLocation();
    }
  }

  Future<void> _checkAndRefreshLocation() async {
    final locationController = context.read<LocationController>();
    final wasEnabled = locationController.isLocationEnabled;

    await locationController.refreshPermissionStatus();

    // If location was just enabled, fetch weather for current location
    if (!wasEnabled && locationController.isLocationEnabled) {
      await _fetchCurrentLocationWeather();
    }
  }

  Future<void> _fetchCurrentLocationWeather() async {
    final locationController = context.read<LocationController>();
    final weatherController = context.read<WeatherController>();
    final unitController = context.read<TemperatureUnitController>();

    final location = await locationController.getCurrentLocation();

    if (location != null) {
      await weatherController.fetchWeatherByCoordinates(
        location.latitude,
        location.longitude,
        displayName: location.displayName,
        units: unitController.unit,
      );
    } else {
      // Fallback to default city
      await weatherController.fetchWeatherByCity(
        'San Francisco',
        units: unitController.unit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.error != null
                ? _buildErrorState(controller.error!)
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 20.0,
                              left: 20.0,
                              right: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(controller),
                                const SizedBox(height: 40),
                                _buildMainWeather(controller),
                                const SizedBox(height: 40),
                                _buildWeatherStats(controller),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_buildHourlyForecast(controller)],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20.0,
                              bottom: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 40),
                                _buildNext7Days(controller),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    final locationController = context.read<LocationController>();
    final weatherController = context.read<WeatherController>();
    final unitController = context.read<TemperatureUnitController>();

    // If location is enabled, try to refresh with current location
    if (locationController.isLocationEnabled) {
      final location = await locationController.getCurrentLocation();
      if (location != null) {
        await weatherController.fetchWeatherByCoordinates(
          location.latitude,
          location.longitude,
          displayName: location.displayName,
          units: unitController.unit,
        );
        return;
      }
    }

    // Otherwise refresh current city
    final currentCity = weatherController.currentCity;
    if (currentCity.isNotEmpty) {
      await weatherController.fetchWeatherByCity(
        currentCity,
        units: unitController.unit,
      );
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final unitController = context.read<TemperatureUnitController>();
              context.read<WeatherController>().fetchWeatherByCity(
                'San Francisco',
                units: unitController.unit,
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WeatherController controller) {
    return WeatherHeader(
      cityName: controller.displayName,
      leadingIcon: Icon(
        Icons.menu_rounded,
        size: 28,
        color: Theme.of(context).iconTheme.color,
      ),
      trailingIcon: Icon(
        Icons.settings,
        size: 28,
        color: Theme.of(context).iconTheme.color,
      ),
      onLeadingPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageCitiesPage()),
        );
      },
      onTrailingPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
      },
    );
  }

  Widget _buildMainWeather(WeatherController controller) {
    final weather = controller.weather;
    if (weather == null) {
      return const Center(child: Text('No weather data'));
    }

    return MainWeatherDisplay(
      icon: WeatherHelpers.getWeatherIcon(weather.main, weather.icon),
      iconColor: WeatherHelpers.getWeatherColor(weather.main, weather.icon),
      temperature: weather.temperature,
      condition: WeatherHelpers.getConditionText(weather.main, weather.icon),
      tempMax: weather.tempMax,
      tempMin: weather.tempMin,
    );
  }

  Widget _buildWeatherStats(WeatherController controller) {
    final weather = controller.weather;
    if (weather == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: CupertinoIcons.drop_fill,
            iconColor: Colors.blue,
            label: 'Humidity',
            value: '${weather.humidity}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: CupertinoIcons.wind,
            iconColor: Colors.green,
            label: 'Wind',
            value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: CupertinoIcons.cloud_fill,
            iconColor: Colors.grey,
            label: 'Clouds',
            value: '${weather.cloudiness}%',
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyForecast(WeatherController controller) {
    final hourlyData = controller.hourlyForecast;
    final currentWeather = controller.weather;
    final timezoneOffset = currentWeather?.timezone ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hourly Forecast',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HourlyForecastPage(),
                    ),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Consumer<TemperatureUnitController>(
          builder: (context, unitController, _) {
            final isFahrenheit = unitController.isFahrenheit;
            final unitSymbol = unitController.unitSymbol;

            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourlyData.length,
                padding: const EdgeInsets.only(
                  right: 20.0,
                ), // Thêm padding bên phải
                itemBuilder: (context, index) {
                  final isFirst = index == 0;

                  String time;
                  IconData icon;
                  String temp;
                  Color iconColor;

                  if (isFirst && currentWeather != null) {
                    time = 'Now';
                    icon = WeatherHelpers.getWeatherIcon(
                      currentWeather.main,
                      currentWeather.icon,
                    );
                    final displayTemp = Helpers.getTemperature(
                      currentWeather.temperature,
                      isFahrenheit: isFahrenheit,
                    ).round();
                    temp = '$displayTemp$unitSymbol';
                    iconColor = WeatherHelpers.getWeatherColor(
                      currentWeather.main,
                      currentWeather.icon,
                    );
                  } else {
                    final item = hourlyData[index];
                    final localTime = item.dateTimeAsDateTime.toUtc().add(
                      Duration(seconds: timezoneOffset),
                    );
                    final hour = localTime.hour;
                    final period = hour >= 12 ? 'PM' : 'AM';
                    final displayHour = hour > 12
                        ? hour - 12
                        : (hour == 0 ? 12 : hour);
                    time = '$displayHour $period';
                    icon = WeatherHelpers.getWeatherIcon(item.main, item.icon);
                    final displayTemp = Helpers.getTemperature(
                      item.temperature,
                      isFahrenheit: isFahrenheit,
                    ).round();
                    temp = '$displayTemp$unitSymbol';
                    iconColor = WeatherHelpers.getWeatherColor(
                      item.main,
                      item.icon,
                    );
                  }

                  return HourlyForecastItem(
                    time: time,
                    icon: icon,
                    iconColor: iconColor,
                    temperature: temp,
                    isSelected: isFirst,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNext7Days(WeatherController controller) {
    final dailyData = controller.dailyForecast;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next 7 Days',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              icon: Icon(
                CupertinoIcons.calendar,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Next7DaysPage(),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyData.length,
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final day = dailyData[index];
              return DailyForecastItem(
                dayName: day.dayName,
                icon: WeatherHelpers.getWeatherIcon(day.main, day.icon),
                iconColor: WeatherHelpers.getWeatherColor(day.main, day.icon),
                condition: WeatherHelpers.getConditionText(day.main, day.icon),
                tempMin: day.tempMin,
                tempMax: day.tempMax,
              );
            },
          ),
        ),
      ],
    );
  }
}
