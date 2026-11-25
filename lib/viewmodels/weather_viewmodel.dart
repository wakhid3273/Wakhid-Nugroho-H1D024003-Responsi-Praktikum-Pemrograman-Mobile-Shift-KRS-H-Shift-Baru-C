import 'package:flutter/foundation.dart';

import '../core/view_state.dart';
import '../models/location.dart';
import '../models/weather.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// ViewModel untuk Home / Weather Screen.
class WeatherViewModel extends ChangeNotifier {
  final WeatherService _service;
  final StorageService _storage;

  WeatherViewModel(this._service, this._storage);

  // Lokasi default: Kudus, Jawa Tengah.
  static const defaultLocation = Location(
    name: 'Kudus',
    latitude: -6.8048,
    longitude: 110.8405,
    admin1: 'Jawa Tengah',
    country: 'Indonesia',
  );

  ViewState _state = ViewState.initial;
  Location? _location;
  WeatherData? _weather;
  String _error = '';

  ViewState get state => _state;
  Location? get location => _location;
  WeatherData? get weather => _weather;
  String get error => _error;

  Future<void> init() async {
    _location = _storage.loadLastLocation() ?? defaultLocation;
    await loadWeather();
  }

  Future<void> selectLocation(Location location) async {
    _location = location;
    _weather = null;
    await _storage.saveLastLocation(location);
    await loadWeather();
  }

  Future<void> loadWeather() async {
    final loc = _location;
    if (loc == null) return;

    _state = ViewState.loading;
    notifyListeners();

    try {
      final data = await _service.fetchWeather(loc);
      _weather = data;
      _state = data.daily.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiException catch (e) {
      _error = e.message;
      _state = ViewState.error;
    } catch (_) {
      _error = 'Terjadi kesalahan tak terduga.';
      _state = ViewState.error;
    }
    notifyListeners();
  }
}
