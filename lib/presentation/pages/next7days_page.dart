import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';
import 'package:weather_app/presentation/widgets/weather_helpers.dart';
import 'package:weather_app/core/utils/helpers.dart';
import 'package:weather_app/presentation/widgets/widgets.dart';

class Next7DaysPage extends StatelessWidget {
  const Next7DaysPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherController>(
      builder: (context, controller, _) {
        final daily = controller.dailyForecast;
        final city = controller.displayName;

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
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  '7-Day Forecast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  city,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          body: daily.isEmpty
              ? Center(
                  child: Text(
                    'No forecast data available',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tomorrow card (prominent)
                        _buildTomorrowCard(context, daily),
                        const SizedBox(height: 24),

                        // Section header like ManageCities
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '7-DAY FORECAST',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.color,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '${daily.length} DAYS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.color,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Expandable day list with details
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: daily.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final day = daily[index];
                            return _buildDayTile(context, day);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildTomorrowCard(BuildContext context, List<dynamic> daily) {
    // Use index 1 if available (tomorrow), otherwise first available
    final tomorrow = daily.length > 1 ? daily[1] : daily.first;

    final icon = WeatherHelpers.getWeatherIcon(tomorrow.main, tomorrow.icon);
    final color = WeatherHelpers.getWeatherColor(tomorrow.main, tomorrow.icon);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: label & temps
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tomorrow',
                  style: TextStyle(
                    color: const Color(0xFF42A5F5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<TemperatureUnitController>(
                  builder: (context, unitController, _) {
                    final isFahrenheit = unitController.isFahrenheit;
                    final displayTemp = Helpers.getTemperature(
                      tomorrow.tempMax,
                      isFahrenheit: isFahrenheit,
                    ).round();
                    final displayMin = Helpers.getTemperature(
                      tomorrow.tempMin,
                      isFahrenheit: isFahrenheit,
                    ).round();
                    final unitSymbol = unitController.unitSymbol;
                    return Text(
                      '$displayTemp°$unitSymbol',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Consumer<TemperatureUnitController>(
                  builder: (context, unitController, _) {
                    final isFahrenheit = unitController.isFahrenheit;
                    final displayMin = Helpers.getTemperature(
                      tomorrow.tempMin,
                      isFahrenheit: isFahrenheit,
                    ).round();
                    final unitSymbol = unitController.unitSymbol;
                    return Text(
                      '/ $displayMin°$unitSymbol',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  WeatherHelpers.getConditionText(tomorrow.main, tomorrow.icon),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          // Right: icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 48, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(BuildContext context, dynamic day) {
    final icon = WeatherHelpers.getWeatherIcon(day.main, day.icon);
    final color = WeatherHelpers.getWeatherColor(day.main, day.icon);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Icon(icon, size: 28, color: color),
          const SizedBox(width: 16),
          // Day name
          SizedBox(
            width: 70,
            child: Text(
              day.dayName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          // Condition
          Expanded(
            child: Text(
              WeatherHelpers.getConditionText(day.main, day.icon),
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          // Temps
          Consumer<TemperatureUnitController>(
            builder: (context, unitController, _) {
              final isFahrenheit = unitController.isFahrenheit;
              final displayMin = Helpers.getTemperature(
                day.tempMin,
                isFahrenheit: isFahrenheit,
              ).round();
              final displayMax = Helpers.getTemperature(
                day.tempMax,
                isFahrenheit: isFahrenheit,
              ).round();
              final unitSymbol = unitController.unitSymbol;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$displayMax°',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$displayMin°',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayTile(BuildContext context, dynamic day) {
    final icon = WeatherHelpers.getWeatherIcon(day.main, day.icon);
    final color = WeatherHelpers.getWeatherColor(day.main, day.icon);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          day.dayName,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          WeatherHelpers.getConditionText(day.main, day.icon),
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        trailing: Consumer<TemperatureUnitController>(
          builder: (context, unitController, _) {
            final isFahrenheit = unitController.isFahrenheit;
            final displayMin = Helpers.getTemperature(
              day.tempMin,
              isFahrenheit: isFahrenheit,
            ).round();
            final displayMax = Helpers.getTemperature(
              day.tempMax,
              isFahrenheit: isFahrenheit,
            ).round();
            final unit = unitController.unitSymbol;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$displayMax°$unit',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$displayMin°$unit',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            );
          },
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: CupertinoIcons.drop_fill,
                  iconColor: Colors.blue,
                  label: 'Humidity',
                  value: '${day.humidity ?? 0}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: CupertinoIcons.wind,
                  iconColor: Colors.green,
                  label: 'Wind',
                  value: '${(day.windSpeed ?? 0).toStringAsFixed(1)} m/s',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: CupertinoIcons.cloud_fill,
                  iconColor: Colors.grey,
                  label: 'Clouds',
                  value: '${day.cloudiness ?? 0}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
