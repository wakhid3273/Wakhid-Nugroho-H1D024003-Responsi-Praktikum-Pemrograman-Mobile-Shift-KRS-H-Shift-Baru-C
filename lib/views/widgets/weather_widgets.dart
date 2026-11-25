import 'package:flutter/material.dart';

import '../../core/weather_code.dart';
import '../../models/weather.dart';

const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

/// Kartu utama: suhu, kondisi cuaca, suhu terasa.
class CurrentWeatherCard extends StatelessWidget {
  final CurrentWeather weather;
  const CurrentWeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = weather.weatherCode;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Icon(WeatherCode.icon(code),
                  size: 88, color: WeatherCode.color(code)),
              const SizedBox(height: 12),
              Text('${weather.temperature.round()}°',
                  style: theme.textTheme.displayLarge),
              const SizedBox(height: 8),
              Text(WeatherCode.description(code),
                  style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('Terasa seperti ${weather.apparentTemperature.round()}°C',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoTile(
      {super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(value,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid info tambahan yang responsif (2 kolom di HP, 4 kolom di layar lebar).
class InfoGrid extends StatelessWidget {
  final CurrentWeather weather;
  final int rainChance;
  const InfoGrid({super.key, required this.weather, required this.rainChance});

  @override
  Widget build(BuildContext context) {
    final items = [
      InfoTile(
          icon: Icons.water_drop_outlined,
          label: 'Kelembapan',
          value: '${weather.humidity}%'),
      InfoTile(
          icon: Icons.air,
          label: 'Kecepatan angin',
          value: '${weather.windSpeed.toStringAsFixed(1)} km/j'),
      InfoTile(
          icon: Icons.umbrella_outlined,
          label: 'Peluang hujan',
          value: '$rainChance%'),
      InfoTile(
          icon: Icons.grain,
          label: 'Curah hujan',
          value: '${weather.precipitation.toStringAsFixed(1)} mm'),
    ];
    return LayoutBuilder(builder: (context, c) {
      const spacing = 12.0;
      final cols = c.maxWidth >= 600 ? 4 : 2;
      final w = (c.maxWidth - spacing * (cols - 1)) / cols;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: items.map((e) => SizedBox(width: w, child: e)).toList(),
      );
    });
  }
}

class ForecastList extends StatelessWidget {
  final List<DailyForecast> days;
  const ForecastList({super.key, required this.days});

  String _label(DailyForecast d, int index) {
    if (index == 0) return 'Hari ini';
    return '${_days[d.date.weekday - 1]}, ${d.date.day} ${_months[d.date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            for (var i = 0; i < days.length; i++)
              ListTile(
                leading: Icon(WeatherCode.icon(days[i].weatherCode),
                    color: WeatherCode.color(days[i].weatherCode), size: 32),
                title: Text(_label(days[i], i)),
                subtitle: Text(
                    '${WeatherCode.description(days[i].weatherCode)} • '
                    'Hujan ${days[i].precipitationProbability}%'),
                trailing: Text(
                  '${days[i].maxTemp.round()}° / ${days[i].minTemp.round()}°',
                  style: theme.textTheme.titleMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
