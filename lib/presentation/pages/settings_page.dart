import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:weather_app/presentation/controllers/theme_controller.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';
import 'package:weather_app/presentation/controllers/location_controller.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh permission when returning from system settings
    if (state == AppLifecycleState.resumed) {
      context.read<LocationController>().refreshPermissionStatus();
    }
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
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineSmall!.color,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsSectionHeader(title: 'PREFERENCES'),
              const SizedBox(height: 16),
              _buildTemperatureUnitCard(context),
              const SizedBox(height: 32),
              const SettingsSectionHeader(title: 'GENERAL'),
              const SizedBox(height: 16),
              _buildGeneralCard(context),
              const SizedBox(height: 32),
              _buildLegalCard(context),
              const SizedBox(height: 40),
              _buildAppInfo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemperatureUnitCard(BuildContext context) {
    return SettingsCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.thermometer,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature Unit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.headlineSmall!.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select your preferred unit',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Consumer<TemperatureUnitController>(
                builder: (context, unitController, _) => Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await unitController.setUnit(true); // Fahrenheit
                        // No need to refresh weather data, conversion happens at display time
                      },
                      child: _buildUnitButton(
                        context,
                        '°F',
                        unitController.isFahrenheit,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        await unitController.setUnit(false); // Celsius
                        // No need to refresh weather data, conversion happens at display time
                      },
                      child: _buildUnitButton(
                        context,
                        '°C',
                        unitController.isCelsius,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitButton(BuildContext context, String unit, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.transparent,
        border: !isSelected
            ? Border.all(color: Theme.of(context).dividerColor)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        unit,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isSelected
              ? Colors.white
              : Theme.of(context).textTheme.bodyMedium!.color,
        ),
      ),
    );
  }

  Widget _buildGeneralCard(BuildContext context) {
    return SettingsCard(
      children: [
        SettingsItem(
          icon: CupertinoIcons.bell_fill,
          iconColor: Colors.orange,
          title: 'Notifications',
          trailing: CupertinoSwitch(
            value: false,
            onChanged: (value) {},
            activeTrackColor: Colors.blue,
          ),
        ),
        const SettingsDivider(),
        Consumer<LocationController>(
          builder: (context, locationController, _) => SettingsItem(
            icon: CupertinoIcons.location_fill,
            iconColor: Colors.green,
            title: 'Location Access',
            subtitle: locationController.isLocationEnabled
                ? 'Enabled'
                : 'Disabled',
            trailing: CupertinoSwitch(
              value: locationController.isLocationEnabled,
              onChanged: (value) async {
                final enabled = await locationController.toggleLocationAccess();
                if (enabled && context.mounted) {
                  // Auto-fetch weather for current location
                  _fetchCurrentLocationWeather();
                }
              },
              activeTrackColor: Colors.blue,
            ),
          ),
        ),
        const SettingsDivider(),
        Consumer<ThemeController>(
          builder: (context, controller, _) => SettingsItem(
            icon: CupertinoIcons.moon_fill,
            iconColor: Colors.purple,
            title: 'Dark Mode',
            trailing: CupertinoSwitch(
              value: controller.isDarkMode,
              onChanged: (value) {
                controller.setTheme(value);
              },
              activeTrackColor: Colors.blue,
            ),
          ),
        ),
      ],
    );
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
    }
  }

  Widget _buildLegalCard(BuildContext context) {
    return SettingsCard(
      children: [
        SettingsLinkItem(
          title: 'Privacy Policy',
          trailingIcon: CupertinoIcons.arrow_up_right_square,
          onTap: () {
            // Open privacy policy
          },
        ),
        const SettingsDivider(indent: 20, endIndent: 20),
        SettingsLinkItem(
          title: 'Terms of Service',
          trailingIcon: CupertinoIcons.arrow_up_right_square,
          onTap: () {
            // Open terms of service
          },
        ),
      ],
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              CupertinoIcons.cloud_fill,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Weather App $_appVersion',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
