import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/view_state.dart';
import '../models/weather.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/state_views.dart';
import 'widgets/weather_widgets.dart';

/// Screen 1: Home / Weather Screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final search = context.watch<SearchViewModel>();
    final loc = vm.location;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loc?.name ?? 'Cuaca',
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis),
                  if (loc != null && loc.subtitle.isNotEmpty)
                    Text(loc.subtitle,
                        style: Theme.of(context).textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (loc != null)
            IconButton(
              tooltip: 'Favorit',
              icon: Icon(search.isFavorite(loc)
                  ? Icons.star_rounded
                  : Icons.star_border_rounded),
              onPressed: () => search.toggleFavorite(loc),
            ),
          IconButton(
            tooltip: 'Cari kota',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    switch (vm.state) {
      case ViewState.initial:
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewState.error:
        return MessageView(
          icon: Icons.cloud_off_rounded,
          message: vm.error,
          onAction: vm.loadWeather,
        );
      case ViewState.empty:
        return MessageView(
          icon: Icons.inbox_outlined,
          message: 'Data cuaca untuk lokasi ini tidak tersedia.',
          onAction: vm.loadWeather,
          actionLabel: 'Muat ulang',
        );
      case ViewState.success:
        return RefreshIndicator(
          onRefresh: vm.loadWeather,
          child: _WeatherContent(data: vm.weather!),
        );
    }
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherData data;
  const _WeatherContent({required this.data});

  @override
  Widget build(BuildContext context) {
    final today = data.daily.first;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurrentWeatherCard(weather: data.current),
                const SizedBox(height: 16),
                InfoGrid(
                  weather: data.current,
                  rainChance: today.precipitationProbability,
                ),
                const SizedBox(height: 24),
                Text('Prakiraan ${data.daily.length} hari',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ForecastList(days: data.daily),
                const SizedBox(height: 16),
                Center(
                  child: Text('Data: Open-Meteo.com',
                      style: Theme.of(context).textTheme.labelMedium),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
