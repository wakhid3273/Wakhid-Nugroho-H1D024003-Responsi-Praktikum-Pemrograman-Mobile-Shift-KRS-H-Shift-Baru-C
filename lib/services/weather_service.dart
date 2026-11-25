import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location.dart';
import '../models/weather.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

/// Mengakses REST API Open-Meteo (HTTP GET).
class WeatherService {
  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Weather Forecast API.
  Future<WeatherData> fetchWeather(Location location) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'precipitation,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    final json = await _get(uri);
    try {
      return WeatherData.fromJson(json);
    } catch (_) {
      throw ApiException('Format data cuaca tidak sesuai.');
    }
  }

  /// Geocoding API: cari kota berdasarkan nama.
  Future<List<Location>> searchLocations(String query) async {
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': query,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });
    final json = await _get(uri);
    // Jika tidak ada hasil, API tidak menyertakan key "results".
    final results = json['results'] as List?;
    if (results == null) return [];
    return results
        .map((e) => Location.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    try {
      final res = await _client.get(uri).timeout(_timeout);
      if (res.statusCode != 200) {
        throw ApiException('Server bermasalah (kode ${res.statusCode}).');
      }
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Coba lagi.');
    } on FormatException {
      throw ApiException('Respons server tidak valid.');
    } catch (_) {
      throw ApiException('Tidak dapat terhubung. Periksa koneksi internet.');
    }
  }
}
