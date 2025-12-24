import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/utils/logger.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';
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
  List<Map<String, dynamic>> _savedLocations = [];
  final Map<String, WeatherEntity> _citiesWeather = {};
  bool _isLoadingWeather = false;
  bool _isEditMode = false;
  static const String _savedLocationsKey = 'saved_locations_v2';

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
    final locationsJson = prefs.getStringList(_savedLocationsKey);

    if (locationsJson != null) {
      setState(() {
        _savedLocations = locationsJson.map<Map<String, dynamic>>((json) {
          final parts = json.split('|');
          return <String, dynamic>{
            'name': parts[0],
            'lat': double.parse(parts[1]),
            'lon': double.parse(parts[2]),
          };
        }).toList();
      });
    } else {
      // Migrate old data or use defaults
      setState(() {
        _savedLocations = <Map<String, dynamic>>[
          <String, dynamic>{
            'name': 'New York',
            'lat': 40.7128,
            'lon': -74.0060,
          },
          <String, dynamic>{'name': 'London', 'lat': 51.5074, 'lon': -0.1278},
          <String, dynamic>{'name': 'Tokyo', 'lat': 35.6762, 'lon': 139.6503},
          <String, dynamic>{'name': 'Sydney', 'lat': -33.8688, 'lon': 151.2093},
        ];
      });
      _saveCities();
    }
    _fetchWeatherForCities();
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    final locationsJson = _savedLocations.map((loc) {
      return '${loc['name']}|${loc['lat']}|${loc['lon']}';
    }).toList();
    await prefs.setStringList(_savedLocationsKey, locationsJson);
  }

  void _addCity(String cityName, double lat, double lon) {
    final exists = _savedLocations.any((loc) => loc['name'] == cityName);
    if (!exists) {
      final newLocation = Map<String, dynamic>.from({
        'name': cityName,
        'lat': lat,
        'lon': lon,
      });
      setState(() {
        _savedLocations.insert(0, newLocation);
      });
      _saveCities();
      _fetchWeatherForCity(cityName, lat, lon);
    }
  }

  Future<void> _fetchWeatherForCities() async {
    setState(() {
      _isLoadingWeather = true;
    });

    final useCase = context.read<WeatherController>().getWeatherUseCase;

    for (final location in _savedLocations) {
      final name = location['name'] as String;
      final lat = location['lat'] as double;
      final lon = location['lon'] as double;

      try {
        final weather = await useCase.callByCoordinates(
          lat,
          lon,
          units: 'metric',
        );
        if (mounted) {
          setState(() {
            _citiesWeather[name] = weather;
          });
        }
      } catch (e) {
        logger.e('Failed to fetch weather for $name: $e');
      }
    }

    if (mounted) {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _fetchWeatherForCity(
    String cityName,
    double lat,
    double lon,
  ) async {
    final useCase = context.read<WeatherController>().getWeatherUseCase;
    try {
      final weather = await useCase.callByCoordinates(
        lat,
        lon,
        units: 'metric',
      );
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
    try {
      final location = _savedLocations.firstWhere(
        (loc) => loc['name'] == cityName,
      );
      final lat = (location['lat'] as num).toDouble();
      final lon = (location['lon'] as num).toDouble();

      context.read<WeatherController>().fetchWeatherByCoordinates(
        lat,
        lon,
        displayName: cityName,
      );
      Navigator.pop(context);
    } catch (e) {
      logger.e('Error selecting city: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error loading city data'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteCity(String cityName) {
    setState(() {
      _savedLocations.removeWhere((loc) => loc['name'] == cityName);
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
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(
                _isEditMode ? Icons.done : CupertinoIcons.pencil,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: _toggleEditMode,
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 32),
                  _buildCurrentLocation(),
                  const SizedBox(height: 32),
                  _buildSavedCities(constraints),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return CityAutocomplete(
      controller: _searchController,
      onCitySelected: (cityName, lat, lon) {
        if (cityName.isNotEmpty) {
          // Clear search and hide suggestions before showing sheet
          _searchController.clear();
          _showCityWeatherSheet(cityName, lat, lon);
        }
      },
    );
  }

  void _showCityWeatherSheet(String cityName, double lat, double lon) {
    final units = context.read<TemperatureUnitController>().unit;
    // Use coordinates instead of city name for accurate weather data
    context.read<WeatherController>().fetchWeatherByCoordinates(
      lat,
      lon,
      displayName: cityName,
      units: units,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CityWeatherSheet(
        cityName: cityName,
        lat: lat,
        lon: lon,
        onAddCity: _addCity,
      ),
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
              cityName: controller.displayName,
              condition: weather.main,
              iconCode: weather.icon,
              temperature: weather.temperature,
              tempHigh: weather.tempMax,
              tempLow: weather.tempMin,
              isCurrentLocation: true,
              onTap: () {
                _searchController.clear();
                // Use weather coordinates (from WeatherEntity)
                // Note: WeatherEntity doesn't expose lat/lon directly
                // So we need to fetch it again or just navigate back
                Navigator.pop(context);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSavedCities(BoxConstraints constraints) {
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
              '${_savedLocations.length} SAVED',
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
            : _savedLocations.isEmpty
            ? ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 400,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 64,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.location_slash,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.color!.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved cities yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.headlineSmall!.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Search and add cities to see their weather',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _savedLocations.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final location = _savedLocations[index];
                  final cityName = location['name'] as String;
                  final weather = _citiesWeather[cityName];

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
                                  onPressed: () => _deleteCity(cityName),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // City card with animation
                        Expanded(
                          child: CityCard(
                            cityName: cityName,
                            condition: weather?.main ?? 'Loading',
                            iconCode: weather?.icon ?? '01d',
                            temperature: weather?.temperature ?? 0,
                            tempHigh: weather?.tempMax ?? 0,
                            tempLow: weather?.tempMin ?? 0,
                            isCurrentLocation: false,
                            localTime: weather != null
                                ? WeatherHelpers.getLocalTime(weather.timezone)
                                : null,
                            onTap: _isEditMode
                                ? null
                                : () => _selectCity(cityName),
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
  final double lat;
  final double lon;
  final Function(String, double, double) onAddCity;

  const _CityWeatherSheet({
    required this.cityName,
    required this.lat,
    required this.lon,
    required this.onAddCity,
  });

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
              onAddCity(cityName, lat, lon);
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
            temperature: weather.temperature,
            condition: WeatherHelpers.getConditionText(
              weather.main,
              weather.icon,
            ),
            tempMax: weather.tempMax,
            tempMin: weather.tempMin,
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
