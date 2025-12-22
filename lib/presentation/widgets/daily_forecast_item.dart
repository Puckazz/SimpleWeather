import 'package:flutter/material.dart';

/// A widget for displaying daily forecast item
class DailyForecastItem extends StatelessWidget {
  final String dayName;
  final IconData icon;
  final Color iconColor;
  final String condition;
  final int tempMin;
  final int tempMax;

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
          Text('$tempMin°', style: Theme.of(context).textTheme.bodyMedium),
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
            width: 32,
            child: Text(
              '$tempMax°',
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
  }
}
