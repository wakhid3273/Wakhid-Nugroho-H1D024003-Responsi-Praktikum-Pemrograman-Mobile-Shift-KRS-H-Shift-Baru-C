import 'package:flutter/material.dart';

/// Konversi WMO weather code ke deskripsi (Indonesia) dan ikon.
class WeatherCode {
  static String description(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah berawan';
      case 2:
        return 'Berawan sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 56:
      case 57:
        return 'Gerimis beku';
      case 61:
        return 'Hujan ringan';
      case 63:
        return 'Hujan sedang';
      case 65:
        return 'Hujan lebat';
      case 66:
      case 67:
        return 'Hujan beku';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Salju';
      case 80:
      case 81:
      case 82:
        return 'Hujan deras sesaat';
      case 85:
      case 86:
        return 'Hujan salju';
      case 95:
        return 'Badai petir';
      case 96:
      case 99:
        return 'Badai petir & es';
      default:
        return 'Tidak diketahui';
    }
  }

  static IconData icon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code == 1 || code == 2) return Icons.wb_cloudy_rounded;
    if (code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 57) return Icons.grain;
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return Icons.water_drop_rounded;
    }
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return Icons.ac_unit_rounded;
    }
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.help_outline_rounded;
  }

  static Color color(int code) {
    if (code == 0 || code == 1) return Colors.orange;
    if (code == 2 || code == 3 || code == 45 || code == 48) {
      return Colors.blueGrey;
    }
    if (code >= 95) return Colors.deepPurple;
    if (code >= 71 && code <= 77) return Colors.lightBlue;
    return Colors.blue;
  }
}
