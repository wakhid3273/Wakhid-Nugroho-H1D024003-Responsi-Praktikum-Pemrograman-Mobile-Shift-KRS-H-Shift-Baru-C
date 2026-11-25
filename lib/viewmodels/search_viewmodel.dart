import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/view_state.dart';
import '../models/location.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// ViewModel untuk Search / Location Screen (pencarian, favorit, riwayat).
class SearchViewModel extends ChangeNotifier {
  final WeatherService _service;
  final StorageService _storage;

  SearchViewModel(this._service, this._storage) {
    _favorites = _storage.loadFavorites();
    _history = _storage.loadHistory();
  }

  static const _maxHistory = 10;

  ViewState _state = ViewState.initial;
  String _query = '';
  String _error = '';
  List<Location> _results = [];
  late List<Location> _favorites;
  late List<Location> _history;
  Timer? _debounce;

  ViewState get state => _state;
  String get query => _query;
  String get error => _error;
  List<Location> get results => _results;
  List<Location> get favorites => _favorites;
  List<Location> get history => _history;

  bool isFavorite(Location l) => _favorites.any((f) => f.key == l.key);

  /// Dipanggil tiap teks berubah; ditunda 500 ms (debounce).
  void onQueryChanged(String text) {
    _query = text.trim();
    _debounce?.cancel();
    if (_query.isEmpty) {
      _results = [];
      _state = ViewState.initial;
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => search(_query));
    notifyListeners();
  }

  Future<void> search(String text) async {
    final q = text.trim();
    if (q.isEmpty) return;
    _query = q;
    _state = ViewState.loading;
    notifyListeners();

    try {
      final res = await _service.searchLocations(q);
      if (q != _query) return; // abaikan respons usang
      _results = res;
      _state = res.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiException catch (e) {
      if (q != _query) return;
      _error = e.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(Location l) async {
    if (isFavorite(l)) {
      _favorites = _favorites.where((f) => f.key != l.key).toList();
    } else {
      _favorites = [l, ..._favorites];
    }
    notifyListeners();
    await _storage.saveFavorites(_favorites);
  }

  Future<void> addToHistory(Location l) async {
    _history = [l, ..._history.where((h) => h.key != l.key)]
        .take(_maxHistory)
        .toList();
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _storage.saveHistory(_history);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
