import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/view_state.dart';
import '../models/location.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/state_views.dart';

/// Screen 2: Search / Location Screen.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset pencarian setiap screen dibuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SearchViewModel>().onQueryChanged('');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _select(Location l) async {
    final search = context.read<SearchViewModel>();
    final weather = context.read<WeatherViewModel>();
    final navigator = Navigator.of(context);
    await search.addToHistory(l);
    weather.selectLocation(l); // tidak di-await: Home menampilkan loading
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (v) {
            vm.onQueryChanged(v);
            setState(() {});
          },
          onSubmitted: vm.search,
          decoration: InputDecoration(
            hintText: 'Cari nama kota...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      vm.onQueryChanged('');
                      setState(() {});
                    },
                  ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: vm.query.isEmpty ? _buildSaved(vm) : _buildResults(vm),
        ),
      ),
    );
  }

  Widget _buildResults(SearchViewModel vm) {
    switch (vm.state) {
      case ViewState.initial:
        return const SizedBox.shrink();
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewState.empty:
        return MessageView(
          icon: Icons.search_off_rounded,
          message: 'Kota "${vm.query}" tidak ditemukan.',
        );
      case ViewState.error:
        return MessageView(
          icon: Icons.cloud_off_rounded,
          message: vm.error,
          onAction: () => vm.search(vm.query),
        );
      case ViewState.success:
        return ListView.separated(
          itemCount: vm.results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final l = vm.results[i];
            return _LocationTile(
              location: l,
              isFavorite: vm.isFavorite(l),
              onTap: () => _select(l),
              onToggleFavorite: () => vm.toggleFavorite(l),
            );
          },
        );
    }
  }

  /// Saat kolom pencarian kosong: tampilkan favorit & riwayat (dari local storage).
  Widget _buildSaved(SearchViewModel vm) {
    if (vm.favorites.isEmpty && vm.history.isEmpty) {
      return const MessageView(
        icon: Icons.travel_explore,
        message: 'Ketik nama kota untuk mencari lokasi.\n'
            'Lokasi favorit & riwayat akan muncul di sini.',
      );
    }
    final theme = Theme.of(context);
    return ListView(
      children: [
        if (vm.favorites.isNotEmpty) ...[
          const _SectionHeader(title: 'Lokasi favorit'),
          for (final l in vm.favorites)
            _LocationTile(
              location: l,
              isFavorite: true,
              onTap: () => _select(l),
              onToggleFavorite: () => vm.toggleFavorite(l),
            ),
        ],
        if (vm.history.isNotEmpty) ...[
          _SectionHeader(
            title: 'Riwayat pencarian',
            trailing: TextButton(
              onPressed: vm.clearHistory,
              child: const Text('Hapus'),
            ),
          ),
          for (final l in vm.history)
            ListTile(
              leading: Icon(Icons.history, color: theme.colorScheme.outline),
              title: Text(l.name),
              subtitle: l.subtitle.isEmpty ? null : Text(l.subtitle),
              onTap: () => _select(l),
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
        child: Row(
          children: [
            Expanded(
                child: Text(title,
                    style: Theme.of(context).textTheme.titleMedium)),
            if (trailing != null) trailing!,
          ],
        ),
      );
}

class _LocationTile extends StatelessWidget {
  final Location location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _LocationTile({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_city),
      title: Text(location.name),
      subtitle: location.subtitle.isEmpty ? null : Text(location.subtitle),
      onTap: onTap,
      trailing: IconButton(
        tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
        icon: Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
            color: isFavorite ? Colors.amber : null),
        onPressed: onToggleFavorite,
      ),
    );
  }
}
