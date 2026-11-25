/// Model lokasi (hasil Geocoding API Open-Meteo).
class Location {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1; // provinsi / negara bagian

  const Location({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  /// Kunci unik untuk membandingkan lokasi (dipakai di favorit & riwayat).
  String get key =>
      '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';

  String get subtitle => [admin1, country]
      .where((e) => e != null && e.isNotEmpty)
      .join(', ');

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        country: json['country'] as String?,
        admin1: json['admin1'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'admin1': admin1,
      };
}
