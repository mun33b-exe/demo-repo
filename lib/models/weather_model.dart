class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json, int index) {
    return DailyForecast(
      date: DateTime.parse(json['time'][index]),
      maxTemp: (json['temperature_2m_max'][index] as num).toDouble(),
      minTemp: (json['temperature_2m_min'][index] as num).toDouble(),
      weatherCode: json['weather_code'][index] as int,
    );
  }
}

class WeatherModel {
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final int humidity;
  final List<DailyForecast> dailyForecasts;

  WeatherModel({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.dailyForecasts,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    final daily = json['daily'];

    final List<DailyForecast> dailyForecasts = [];
    if (daily != null) {
      for (int i = 0; i < (daily['time'] as List).length; i++) {
        dailyForecasts.add(DailyForecast.fromJson(daily, i));
      }
    }

    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: current['weather_code'] as int,
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: current['relative_humidity_2m'] as int,
      dailyForecasts: dailyForecasts,
    );
  }
}
