import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/presentation/controllers/weather_controller.dart';
import 'package:weather_app/presentation/controllers/temperature_unit_controller.dart';
import 'package:weather_app/presentation/widgets/weather_helpers.dart';
import 'package:weather_app/core/utils/helpers.dart';

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
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Column(
              children: [
                Text(
                  '7Days Forecast',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 2),
                Text(city, style: Theme.of(context).textTheme.bodyMedium),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Tomorrow card
                        _buildTomorrowCard(context, daily),
                        const SizedBox(height: 24),
                        // Days list
                        ...List.generate(
                          daily.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildDayItem(context, daily[index]),
                          ),
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
                  style: const TextStyle(
                    color: Color(0xFF42A5F5),
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
                    final unitSymbol = unitController.unitSymbol;
                    return Text(
                      '$displayTemp$unitSymbol',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.headlineSmall?.color,
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
                      '/ $displayMin$unitSymbol',
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
    return DayTile(day: day);
  }
}

/// An expandable/tappable day tile with smooth animation and small icons
class DayTile extends StatefulWidget {
  final dynamic day;

  const DayTile({super.key, required this.day});

  @override
  State<DayTile> createState() => _DayTileState();
}

class _DayTileState extends State<DayTile> with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final day = widget.day;
    final icon = WeatherHelpers.getWeatherIcon(day.main, day.icon);
    final color = WeatherHelpers.getWeatherColor(day.main, day.icon);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -30,
              bottom: -20,
              child: Icon(
                icon,
                size: 120,
                color: color.withValues(alpha: 0.06),
              ),
            ),
            Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, size: 24, color: color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.dayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(
                                  context,
                                ).textTheme.headlineSmall!.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              WeatherHelpers.getConditionText(
                                day.main,
                                day.icon,
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
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
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$displayMax$unitSymbol',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall!.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'L:$displayMin$unitSymbol',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SizeTransition(
                        sizeFactor: anim,
                        axisAlignment: -1.0,
                        child: child,
                      ),
                    ),
                    child: _expanded
                        ? Padding(
                            key: const ValueKey(true),
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _StatTile(
                                  icon: Icons.water_drop,
                                  label: '${day.humidity}%',
                                  title: 'Humidity',
                                  color: color,
                                ),
                                const SizedBox(width: 12),
                                _StatTile(
                                  icon: Icons.air,
                                  label:
                                      '${day.windSpeed.toStringAsFixed(1)} m/s',
                                  title: 'Wind',
                                  color: color,
                                ),
                                const SizedBox(width: 12),
                                _StatTile(
                                  icon: Icons.cloud,
                                  label: '${day.cloudiness}%',
                                  title: 'Clouds',
                                  color: color,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey(false)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
