import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';
import 'package:weather_app/presentation/widgets/weather_helpers.dart';
import 'package:weather_app/core/utils/helpers.dart';
import 'package:weather_app/data/models/forecast_model.dart';

class HourlyForecastPage extends StatelessWidget {
  const HourlyForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
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

                  final hourlyData = controller.hourlyForecast;
                  if (hourlyData.isEmpty) {
                    return const Center(
                      child: Text('No forecast data available'),
                    );
                  }

                  return _buildForecastList(context, hourlyData);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final weatherController = context.watch<WeatherController>();
    final cityName = weatherController.displayName;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(),
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color,
                size: 24,
              ),
            ),
          ),
          // Title
          Expanded(
            child: Column(
              children: [
                Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineSmall!.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cityName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
              ],
            ),
          ),
          // Placeholder for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildForecastList(
    BuildContext context,
    List<ForecastItem> hourlyData,
  ) {
    final now = DateTime.now();
    final unitController = context.watch<TemperatureUnitController>();

    // Group by day
    final Map<String, List<ForecastItem>> groupedByDay = {};

    for (final item in hourlyData) {
      final date = item.dateTimeAsDateTime;
      final dayKey = DateFormat('yyyy-MM-dd').format(date);

      if (!groupedByDay.containsKey(dayKey)) {
        groupedByDay[dayKey] = [];
      }
      groupedByDay[dayKey]!.add(item);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        ...groupedByDay.entries.map((entry) {
          final date = DateTime.parse(entry.key);
          final isToday =
              date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;
          final isTomorrow =
              date.day == now.add(const Duration(days: 1)).day &&
              date.month == now.add(const Duration(days: 1)).month &&
              date.year == now.add(const Duration(days: 1)).year;

          String dayLabel;
          if (isToday) {
            dayLabel = 'Today';
          } else if (isTomorrow) {
            dayLabel = 'Tomorrow';
          } else {
            dayLabel = DateFormat('EEEE, MMM d').format(date);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Text(
                  dayLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
              ),
              ...entry.value.asMap().entries.map((indexedItem) {
                final index = indexedItem.key;
                final item = indexedItem.value;
                final isFirst = index == 0 && isToday;

                return _buildHourlyCard(
                  context,
                  item,
                  isFirst,
                  unitController.unitSymbol,
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHourlyCard(
    BuildContext context,
    ForecastItem item,
    bool isNow,
    String unitSymbol,
  ) {
    final time = item.dateTimeAsDateTime;
    final timeString = isNow ? 'Now' : DateFormat('h a').format(time);

    final weatherIcon = WeatherHelpers.getWeatherIcon(item.main, item.icon);
    final iconColor = WeatherHelpers.getWeatherColor(item.main, item.icon);
    final conditionText = WeatherHelpers.getConditionText(item.main, item.icon);

    final unitController = context.watch<TemperatureUnitController>();
    final displayTemp = Helpers.getTemperature(
      item.temperature,
      isFahrenheit: unitController.isFahrenheit,
    ).toInt();

    // Additional info based on conditions
    String? additionalInfo;
    if (item.rain3h != null && item.rain3h! > 0) {
      final chance = (item.rain3h! * 10).clamp(0, 100).toInt();
      additionalInfo = '$chance% Chance';
    } else if (item.windSpeed > 5) {
      additionalInfo = 'Wind ${item.windSpeed.toInt()} mph';
    } else if (item.humidity > 70) {
      additionalInfo = 'Humidity ${item.humidity}%';
    } else {
      additionalInfo =
          'UV Index ${(item.cloudiness / 20).clamp(1, 10).toInt()}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isNow
            ? const LinearGradient(
                colors: [Color(0xFF2b8cee), Color(0xFF1e6bbf)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isNow
            ? null
            : Theme.of(context).cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNow
              ? Colors.transparent
              : Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: isNow
            ? [
                BoxShadow(
                  color: const Color(0xFF2b8cee).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Time
          SizedBox(
            width: 48,
            child: Text(
              timeString,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isNow
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Condition
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conditionText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isNow
                        ? Colors.white
                        : Theme.of(context).textTheme.headlineSmall!.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  additionalInfo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isNow
                        ? Colors.white.withValues(alpha: 0.9)
                        : (item.rain3h != null && item.rain3h! > 0
                              ? Colors.blue
                              : Theme.of(context).textTheme.bodyMedium!.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Icon
          Icon(weatherIcon, color: isNow ? Colors.white : iconColor, size: 28),
          const SizedBox(width: 16),
          // Temperature
          SizedBox(
            width: 44,
            child: Text(
              '$displayTemp$unitSymbol',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isNow
                    ? Colors.white
                    : Theme.of(context).textTheme.headlineSmall!.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
