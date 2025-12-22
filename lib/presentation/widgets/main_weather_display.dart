import 'package:flutter/material.dart';

/// A widget for displaying main weather information
class MainWeatherDisplay extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int temperature;
  final String condition;
  final int tempMax;
  final int tempMin;

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
    return Center(
      child: Column(
        children: [
          // Weather icon
          Icon(icon, size: 120, color: iconColor),
          const SizedBox(height: 30),
          // Temperature
          Text(
            '$temperature°',
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
                ' H: $tempMax°',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.arrow_downward,
                size: 16,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              Text(
                ' L: $tempMin°',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
