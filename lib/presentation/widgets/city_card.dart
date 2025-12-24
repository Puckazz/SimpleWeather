import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/utils/helpers.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';
import 'package:weather_app/presentation/widgets/weather_helpers.dart';

/// A card widget for displaying city weather information
class CityCard extends StatelessWidget {
  final String cityName;
  final String condition;
  final String iconCode;
  final double temperature;
  final double tempHigh;
  final double tempLow;
  final bool isCurrentLocation;
  final String? localTime;
  final VoidCallback? onTap;

  const CityCard({
    super.key,
    required this.cityName,
    required this.condition,
    required this.iconCode,
    required this.temperature,
    required this.tempHigh,
    required this.tempLow,
    this.isCurrentLocation = false,
    this.localTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final weatherIcon = WeatherHelpers.getWeatherIcon(condition, iconCode);
    final iconColor = WeatherHelpers.getWeatherColor(condition, iconCode);
    final conditionText = WeatherHelpers.getConditionText(condition, iconCode);

    return Consumer<TemperatureUnitController>(
      builder: (context, unitController, _) {
        final isFahrenheit = unitController.isFahrenheit;
        final displayTemp = Helpers.getTemperature(
          temperature,
          isFahrenheit: isFahrenheit,
        ).round();
        final displayTempHigh = Helpers.getTemperature(
          tempHigh,
          isFahrenheit: isFahrenheit,
        ).round();
        final displayTempLow = Helpers.getTemperature(
          tempLow,
          isFahrenheit: isFahrenheit,
        ).round();
        final unitSymbol = unitController.unitSymbol;

        return GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Large faded icon in background
                  Positioned(
                    right: -40,
                    bottom: -30,
                    child: Icon(
                      weatherIcon,
                      size: 150,
                      color: iconColor.withValues(alpha: 0.1),
                    ),
                  ),
                  // Content in foreground
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cityName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.headlineSmall!.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (isCurrentLocation) ...[
                                  const Icon(
                                    CupertinoIcons.location_fill,
                                    size: 14,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Flexible(
                                  child: Text(
                                    conditionText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isCurrentLocation
                                          ? Colors.blue
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!isCurrentLocation &&
                                    localTime != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '• $localTime',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$displayTemp$unitSymbol',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w300,
                              color: Theme.of(
                                context,
                              ).textTheme.headlineSmall!.color,
                            ),
                          ),
                          Text(
                            'H:$displayTempHigh$unitSymbol L:$displayTempLow$unitSymbol',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
