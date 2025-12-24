import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/core/utils/helpers.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';

/// A widget for displaying daily forecast item
class DailyForecastItem extends StatelessWidget {
  final String dayName;
  final IconData icon;
  final Color iconColor;
  final String condition;
  final double tempMin;
  final double tempMax;

  const DailyForecastItem({
    super.key,
    required this.dayName,
    required this.icon,
    required this.iconColor,
    required this.condition,
    required this.tempMin,
    required this.tempMax,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TemperatureUnitController>(
      builder: (context, unitController, _) {
        final isFahrenheit = unitController.isFahrenheit;
        final displayTempMin = Helpers.getTemperature(
          tempMin,
          isFahrenheit: isFahrenheit,
        ).round();
        final displayTempMax = Helpers.getTemperature(
          tempMax,
          isFahrenheit: isFahrenheit,
        ).round();
        final unitSymbol = unitController.unitSymbol;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 45,
                child: Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.headlineSmall!.color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              SizedBox(
                width: 60,
                child: Text(
                  condition,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Spacer(),
              Text(
                '$displayTempMin$unitSymbol',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 12),
              // Temperature bar
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      iconColor,
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.grey[300]!
                          : Colors.white24,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 40,
                child: Text(
                  '$displayTempMax$unitSymbol',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineSmall!.color,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
