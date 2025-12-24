import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/utils/helpers.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';

/// A widget for displaying main weather information
class MainWeatherDisplay extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double temperature;
  final String condition;
  final double tempMax;
  final double tempMin;

  const MainWeatherDisplay({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.temperature,
    required this.condition,
    required this.tempMax,
    required this.tempMin,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TemperatureUnitController>(
      builder: (context, unitController, _) {
        final isFahrenheit = unitController.isFahrenheit;
        final displayTemp = Helpers.getTemperature(
          temperature,
          isFahrenheit: isFahrenheit,
        ).round();
        final displayTempMax = Helpers.getTemperature(
          tempMax,
          isFahrenheit: isFahrenheit,
        ).round();
        final displayTempMin = Helpers.getTemperature(
          tempMin,
          isFahrenheit: isFahrenheit,
        ).round();
        final unitSymbol = unitController.unitSymbol;

        return Center(
          child: Column(
            children: [
              // Weather icon
              Icon(icon, size: 120, color: iconColor),
              const SizedBox(height: 30),
              // Temperature
              Text(
                '$displayTemp$unitSymbol',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 10),
              // Weather description
              Text(condition, style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 10),
              // High/Low temps
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_upward,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  Text(
                    ' H: $displayTempMax$unitSymbol',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    Icons.arrow_downward,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                  Text(
                    ' L: $displayTempMin$unitSymbol',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
