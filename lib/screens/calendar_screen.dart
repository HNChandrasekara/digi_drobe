import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_header.dart';
import '../services/weather_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    // Default city for calendar view, or could be user preference
    final data = await _weatherService.getForecast('London');
    if (mounted) {
      setState(() {
        _forecast = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(userName: 'Hirushie'),
            
            // Weather Forecast Section
            _buildWeatherForecast(),
            
            const SizedBox(height: 20),
            
            // Outfit Grid
            Expanded(
              child: _buildOutfitGrid(),
            ),
            
            // Footer Action
            _buildFooterAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherForecast() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weather Forecast',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 80, // Fixed height for row
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _forecast.map((day) {
                      final isSunny = day['isSunny'] == true || day['condition'].toString().toLowerCase().contains('sun');
                      IconData icon = isSunny ? Icons.wb_sunny_rounded : Icons.wb_cloudy_rounded;
                      if (day['condition'].toString().toLowerCase().contains('rain')) icon = Icons.umbrella_rounded;
                      if (day['condition'].toString().toLowerCase().contains('snow')) icon = Icons.ac_unit_rounded;
                      
                      Color color = isSunny ? Colors.orange : (Colors.blue[300] ?? Colors.blue);
                      if (day['condition'].toString().toLowerCase().contains('cloud')) color = Colors.grey;

                      return _buildWeatherIcon(icon, color, day['temp']);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(IconData icon, Color color, String temp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          temp,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitGrid() {
    final days = [
      {'date': 'Today-Friday, Dec 24', 'type': 'Formal', 'img': null},
      {'date': 'Saturday-Dec 25', 'type': '', 'img': null},
      {'date': 'Sunday-Dec 26', 'type': '', 'img': null},
      {'date': 'Monday-Dec 27', 'type': '', 'img': null},
      {'date': 'Tuesday-Dec 28', 'type': '', 'img': null},
      {'date': 'Wednesday-Dec 29', 'type': '', 'img': null},
    ];

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        return _buildDayCard(day['date'] as String, day['type'] as String);
      },
    );
  }

  Widget _buildDayCard(String date, String type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.systemGray6.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.checkroom_rounded,
                  color: AppColors.systemGray,
                  size: 30,
                ),
              ),
            ),
          ),
          if (type.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Today's look-$type",
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.systemGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterAction() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Set reminder',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 28),
          ),
        ],
      ),
    );
  }
}
