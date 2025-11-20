class WeatherModel {
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final int humidity;

  WeatherModel({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    return WeatherModel(
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: current['weather_code'] as int,
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: current['relative_humidity_2m'] as int,
    );
  }
}
