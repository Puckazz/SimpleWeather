import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A header widget for weather pages
class WeatherHeader extends StatelessWidget {
  final String cityName;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onTrailingPressed;

  const WeatherHeader({
    super.key,
    required this.cityName,
    this.leadingIcon,
    this.trailingIcon,
    this.onLeadingPressed,
    this.onTrailingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEE, MMM d');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (leadingIcon != null)
          IconButton(icon: leadingIcon!, onPressed: onLeadingPressed)
        else
          const SizedBox(width: 48),
        Column(
          children: [
            Text(cityName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(now),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        if (trailingIcon != null)
          IconButton(icon: trailingIcon!, onPressed: onTrailingPressed)
        else
          const SizedBox(width: 48),
      ],
    );
  }
}
