import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // TODO: Replace with your actual AccuWeather API Key
  static const String _apiKey = 'YOUR_ACCUWEATHER_API_KEY';
  static const String _baseUrl = 'http://dataservice.accuweather.com';

  /// Returns a simple string for the chat bot
  Future<String> getWeatherString(String city) async {
    final data = await getForecast(city);
    if (data.isEmpty) return "Could not fetch weather for $city.";
    final current = data.first;
    return "Current weather in $city: ${current['condition']}, ${current['temp']}.";
  }

  /// Returns a list of weather data points (Mocked 5-day forecast or single current real data)
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
        '$_baseUrl/locations/v1/cities/search?apikey=$_apiKey&q=$city',
      );
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode == 200) {
        final searchData = json.decode(searchResponse.body);
        if (searchData is List && searchData.isNotEmpty) {
          final cityKey = searchData[0]['Key'];

          // 2. Get Current Conditions (Real API limit usually prevents 5-day forecast on free tier easily without separate call)
          // For now, we will fetch current and mock the rest if needed, or just return 1 item.
          // Let's try to fetch current conditions.
          final weatherUrl = Uri.parse(
            '$_baseUrl/currentconditions/v1/$cityKey?apikey=$_apiKey',
          );
          final weatherResponse = await http.get(weatherUrl);

          if (weatherResponse.statusCode == 200) {
            final weatherData = json.decode(weatherResponse.body);
            if (weatherData is List && weatherData.isNotEmpty) {
              final temp = weatherData[0]['Temperature']['Metric']['Value'];
              final unit = weatherData[0]['Temperature']['Metric']['Unit'];
              final text = weatherData[0]['WeatherText'];

              // Return real current weather as first item
              return [
                {
                  'temp': '$temp° $unit',
                  'condition': text,
                  'isSunny': text.toString().toLowerCase().contains('sun'),
                },
              ];
            }
          }
        }
      }
      return [];
    } catch (e) {
      // On error, return mock
      return _getMockForecast(city);
    }
  }

  List<Map<String, dynamic>> _getMockForecast(String city) {
    // Mock 5 items for the UI strip
    return [
      {'temp': '25° C', 'condition': 'Sunny', 'isSunny': true},
      {'temp': '24° C', 'condition': 'Cloudy', 'isSunny': false},
      {'temp': '22° C', 'condition': 'Rain', 'isSunny': false},
      {'temp': '20° C', 'condition': 'Sunny', 'isSunny': true},
      {'temp': '21° C', 'condition': 'Cloudy', 'isSunny': false},
    ];
  }
}
