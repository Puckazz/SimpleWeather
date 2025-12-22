import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/utils/logger.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/domain/entities/weather_entity.dart';

class ManageCitiesPage extends StatefulWidget {
  const ManageCitiesPage({super.key});

  @override
  State<ManageCitiesPage> createState() => _ManageCitiesPageState();
}

class _ManageCitiesPageState extends State<ManageCitiesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _savedCities = [];
  final Map<String, WeatherEntity> _citiesWeather = {};
  bool _isLoadingWeather = false;
  bool _isEditMode = false;
  static const String _savedCitiesKey = 'saved_cities';

  @override
  void initState() {
    super.initState();
    _loadSavedCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    final cities =
        prefs.getStringList(_savedCitiesKey) ??
        ['New York', 'London', 'Tokyo', 'Sydney'];
    setState(() {
      _savedCities = cities;
    });
    _fetchWeatherForCities();
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedCitiesKey, _savedCities);
  }

  void _addCity(String cityName) {
    if (!_savedCities.contains(cityName)) {
      setState(() {
        _savedCities.insert(0, cityName);
      });
      _saveCities();
      _fetchWeatherForCity(cityName);
    }
  }

  Future<void> _fetchWeatherForCities() async {
    setState(() {
      _isLoadingWeather = true;
    });

    final useCase = context.read<WeatherController>().getWeatherUseCase;

    for (final city in _savedCities) {
      try {
        final weather = await useCase.call(city);
        if (mounted) {
          setState(() {
            _citiesWeather[city] = weather;
          });
        }
      } catch (e) {
        logger.e('Failed to fetch weather for $city: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _fetchWeatherForCity(String cityName) async {
    final useCase = context.read<WeatherController>().getWeatherUseCase;
    try {
      final weather = await useCase.call(cityName);
      if (mounted) {
        setState(() {
          _citiesWeather[cityName] = weather;
        });
      }
    } catch (e) {
      logger.e('Failed to fetch weather for $cityName: $e');
    }
  }

  void _selectCity(String cityName) {
    context.read<WeatherController>().fetchWeatherByCity(cityName);
    Navigator.pop(context);
  }

  void _deleteCity(String cityName) {
    setState(() {
      _savedCities.remove(cityName);
      _citiesWeather.remove(cityName);
    });
    _saveCities();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manage Cities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineSmall!.color,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isEditMode ? Icons.done : CupertinoIcons.pencil,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 32),
              _buildCurrentLocation(),
              const SizedBox(height: 32),
              _buildSavedCities(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return CityAutocomplete(
      controller: _searchController,
      onCitySelected: (cityName) {
        if (cityName.isNotEmpty) {
          // Clear search and hide suggestions before showing sheet
          _searchController.clear();
          _showCityWeatherSheet(cityName);
        }
      },
    );
  }

  void _showCityWeatherSheet(String cityName) {
    context.read<WeatherController>().fetchWeatherByCity(cityName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _CityWeatherSheet(cityName: cityName, onAddCity: _addCity),
    );
  }

  Widget _buildCurrentLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              CupertinoIcons.location_solid,
              size: 16,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
            const SizedBox(width: 8),
            Text(
              'CURRENT LOCATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium!.color,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<WeatherController>(
          builder: (context, controller, _) {
            final weather = controller.weather;
            if (weather == null) {
              return const SizedBox.shrink();
            }

            return CityCard(
              cityName: weather.name,
              condition: weather.main,
              iconCode: weather.icon,
              temperature: weather.temperature.round(),
              tempHigh: weather.tempMax.round(),
              tempLow: weather.tempMin.round(),
              isCurrentLocation: true,
              onTap: () {
                _searchController.clear();
                _showCityWeatherSheet(weather.name);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSavedCities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SAVED CITIES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium!.color,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '${_savedCities.length} SAVED',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium!.color,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _isLoadingWeather
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedCities.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final city = _savedCities[index];
                  final weather = _citiesWeather[city];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Row(
                      children: [
                        // Delete button with animation
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: _isEditMode ? 50 : 0,
                          child: _isEditMode
                              ? IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.minus_circle_fill,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  onPressed: () => _deleteCity(city),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // City card with animation
                        Expanded(
                          child: CityCard(
                            cityName: city,
                            condition: weather?.main ?? 'Loading',
                            iconCode: weather?.icon ?? '01d',
                            temperature: weather?.temperature.round() ?? 0,
                            tempHigh: weather?.tempMax.round() ?? 0,
                            tempLow: weather?.tempMin.round() ?? 0,
                            isCurrentLocation: false,
                            localTime: weather != null
                                ? WeatherHelpers.getLocalTime(weather.timezone)
                                : null,
                            onTap: _isEditMode ? null : () => _selectCity(city),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }
}

/// Bottom sheet widget for displaying city weather details
class _CityWeatherSheet extends StatelessWidget {
  final String cityName;
  final Function(String) onAddCity;

  const _CityWeatherSheet({required this.cityName, required this.onAddCity});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Consumer<WeatherController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error != null) {
                  return Center(
                    child: Text(
                      'Error: ${controller.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final weather = controller.weather;
                if (weather == null) {
                  return const Center(child: Text('No weather data'));
                }

                return _buildWeatherContent(context, weather);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          ),
          Text(
            cityName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall!.color,
            ),
          ),
          TextButton(
            onPressed: () {
              onAddCity(cityName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added $cityName to saved cities'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Add',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent(BuildContext context, WeatherEntity weather) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main weather display
          MainWeatherDisplay(
            icon: WeatherHelpers.getWeatherIcon(weather.main, weather.icon),
            iconColor: WeatherHelpers.getWeatherColor(
              weather.main,
              weather.icon,
            ),
            temperature: weather.temperature.round(),
            condition: WeatherHelpers.getConditionText(
              weather.main,
              weather.icon,
            ),
            tempMax: weather.tempMax.round(),
            tempMin: weather.tempMin.round(),
          ),
          const SizedBox(height: 40),
          // Weather stats
          Row(
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
          ),
        ],
      ),
    );
  }
}
