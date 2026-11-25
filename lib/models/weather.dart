/// Cuaca saat ini (field `current` dari API).
class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  const CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> j) => CurrentWeather(
        temperature: (j['temperature_2m'] as num).toDouble(),
        apparentTemperature: (j['apparent_temperature'] as num).toDouble(),
        humidity: (j['relative_humidity_2m'] as num).round(),
        precipitation: (j['precipitation'] as num).toDouble(),
        weatherCode: (j['weather_code'] as num).toInt(),
        windSpeed: (j['wind_speed_10m'] as num).toDouble(),
      );
}

/// Prakiraan satu hari (field `daily` dari API).
class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int precipitationProbability;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitationProbability,
    required this.weatherCode,
  });
}

class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;

  const WeatherData({required this.current, required this.daily});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current =
        CurrentWeather.fromJson(json['current'] as Map<String, dynamic>);
    final d = json['daily'] as Map<String, dynamic>;
    final times = (d['time'] as List).cast<String>();
    final maxT = d['temperature_2m_max'] as List;
    final minT = d['temperature_2m_min'] as List;
    final prob = d['precipitation_probability_max'] as List;
    final codes = d['weather_code'] as List;

    final daily = List<DailyForecast>.generate(times.length, (i) {
      return DailyForecast(
        date: DateTime.parse(times[i]),
        maxTemp: (maxT[i] as num?)?.toDouble() ?? 0,
        minTemp: (minT[i] as num?)?.toDouble() ?? 0,
        precipitationProbability: (prob[i] as num?)?.round() ?? 0,
        weatherCode: (codes[i] as num?)?.toInt() ?? 0,
      );
    });
    return WeatherData(current: current, daily: daily);
  }
}
