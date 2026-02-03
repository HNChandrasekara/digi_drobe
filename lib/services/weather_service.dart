import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // TODO: Replace with your actual AccuWeather API Key from https://developer.accuweather.com
  static const String _apiKey = 'YOUR_ACCUWEATHER_API_KEY';
  static const String _baseUrl = 'http://dataservice.accuweather.com';

  /// Returns a simple string for the chat bot
  Future<String> getWeatherString(String city) async {
    final data = await getForecast(city);
    if (data.isEmpty) return "Could not fetch weather for $city.";
    final current = data.first;
    return "Current weather in $city: ${current['condition']}, ${current['temp']}.";
  }

  /// Returns a 5-day forecast list from AccuWeather API or mocked data
  Future<List<Map<String, dynamic>>> getForecast(String city) async {
    // Mock Mode fallback
    if (_apiKey.contains('YOUR_') || _apiKey.isEmpty) {
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate network
      return _getMockForecast(city);
    }

    try {
      // 1. Search for City Key
      final searchUrl = Uri.parse(
        '$_baseUrl/locations/v1/cities/search?apikey=$_apiKey&q=$city&language=en',
      );
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        if (searchData is List && searchData.isNotEmpty) {
          final cityKey = searchData[0]['Key'];

          // 2. Get 5-Day Forecast
          // Details: true returns full forecast data
          final forecastUrl = Uri.parse(
            '$_baseUrl/forecasts/v1/daily/5day/$cityKey?apikey=$_apiKey&details=true&metric=true',
          );
          final forecastResponse = await http.get(forecastUrl);

          if (forecastResponse.statusCode == 200) {
            final forecastData = json.decode(forecastResponse.body);
            if (forecastData is Map && forecastData['DailyForecasts'] != null) {
              final dailyForecasts = forecastData['DailyForecasts'] as List;
              return dailyForecasts.map((day) {
                final temp = day['Temperature']['Maximum']['Value'];
                final text = day['Day']['IconPhrase'];
                return {
                  'temp': '${temp.toStringAsFixed(0)}° C',
                  'condition': text,
                  'isSunny': text.toString().toLowerCase().contains('sun'),
                };
              }).toList();
            }
          }
        }
      }
      return [];
    } catch (e) {
      print('[WeatherService] Error fetching forecast: $e');
      // On error, return mock
      return _getMockForecast(city);
    }
  }

  List<Map<String, dynamic>> _getMockForecast(String city) {
    // Mock 5 items for the UI strip
    return [
      {'temp': '25° C', 'condition': 'Sunny', 'isSunny': true},
      {'temp': '24° C', 'condition': 'Mostly Cloudy', 'isSunny': false},
      {'temp': '22° C', 'condition': 'Rainy', 'isSunny': false},
      {'temp': '20° C', 'condition': 'Sunny', 'isSunny': true},
      {'temp': '21° C', 'condition': 'Cloudy', 'isSunny': false},
    ];
  }
}
