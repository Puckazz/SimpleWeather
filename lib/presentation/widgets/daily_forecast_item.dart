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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              if (Theme.of(context).brightness == Brightness.dark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineSmall!.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    condition,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$displayTempMax$unitSymbol',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.headlineSmall!.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$displayTempMin$unitSymbol',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
