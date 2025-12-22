import 'package:flutter/material.dart';

/// A widget for displaying hourly forecast item
class HourlyForecastItem extends StatelessWidget {
  final String time;
  final IconData icon;
  final Color iconColor;
  final String temperature;
  final bool isSelected;

  const HourlyForecastItem({
    super.key,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.temperature,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.headlineSmall!.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Icon(icon, color: isSelected ? Colors.white : iconColor, size: 32),
          const SizedBox(height: 12),
          Text(
            temperature,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).textTheme.headlineSmall!.color,
            ),
          ),
        ],
      ),
    );
  }
}
