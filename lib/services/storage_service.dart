import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/location.dart';

/// Local storage dengan SharedPreferences:
/// favorit, riwayat pencarian, dan lokasi terakhir dipilih.
class StorageService {
  static const _favKey = 'favorites';
  static const _histKey = 'history';
  static const _lastKey = 'last_location';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Location> loadFavorites() => _loadList(_favKey);
  Future<void> saveFavorites(List<Location> l) => _saveList(_favKey, l);

  List<Location> loadHistory() => _loadList(_histKey);
  Future<void> saveHistory(List<Location> l) => _saveList(_histKey, l);

  Location? loadLastLocation() {
    final raw = _prefs.getString(_lastKey);
    if (raw == null) return null;
    try {
      return Location.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLastLocation(Location l) =>
      _prefs.setString(_lastKey, jsonEncode(l.toJson()));

  List<Location> _loadList(String key) {
    final raw = _prefs.getStringList(key) ?? [];
    final result = <Location>[];
    for (final s in raw) {
      try {
        result.add(Location.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* abaikan data rusak */}
    }
    return result;
  }

  Future<void> _saveList(String key, List<Location> list) => _prefs
      .setStringList(key, list.map((e) => jsonEncode(e.toJson())).toList());
}
