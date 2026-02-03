import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../utils/colors.dart';
import '../widgets/custom_header.dart';
import '../services/calendar_service.dart';
import '../services/weather_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarService _calendarService;
  final WeatherService _weatherService = WeatherService();
  List<calendar.Event> _events = [];
  List<Map<String, dynamic>> _weatherForecast = [];
  bool _isSignedIn = false;
  bool _isLoading = false;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with demo mode enabled for development
    // Set to false once you have Google OAuth credentials configured
    _calendarService = CalendarService(demoMode: true);
    _checkSignInStatus();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final forecast = await _weatherService.getForecast('London');
      if (mounted) {
        setState(() {
          _weatherForecast = forecast;
          _weatherLoading = false;
        });
      }
    } catch (error) {
      print('[Weather] Error loading weather: $error');
      if (mounted) {
        setState(() {
          _weatherLoading = false;
        });
      }
    }
  }

  Future<void> _checkSignInStatus() async {
    final user = await _calendarService.checkSignInStatus();
    if (mounted) {
      setState(() {
        _isSignedIn = user != null;
      });
      if (_isSignedIn) {
        await _fetchEvents();
      }
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    try {
      print('[Calendar] Starting sign-in...');
      final account = await _calendarService.signIn();
      print('[Calendar] Sign-in returned account: $account');
      print('[Calendar] isSignedIn after auth: ${_calendarService.isSignedIn}');

      if (_calendarService.isSignedIn) {
        print('[Calendar] User is signed in, fetching events...');
        await _fetchEvents();
        if (mounted) {
          setState(() {
            _isSignedIn = true;
          });
          final demoText = _calendarService.isDemoMode ? ' (Demo Mode)' : '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Calendar connected successfully!$demoText'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('[Calendar] User is not signed in');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to connect. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      print('[Calendar] Sign-in error: $error');
      print('[Calendar] Error type: ${error.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchEvents() async {
    final events = await _calendarService.getEvents();
    if (mounted) {
      setState(() {
        _events = events;
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
            _buildCalendarSection(),
            _buildWeatherBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildMainContent()),
            _buildFooterAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Schedule',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_isSignedIn)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _fetchEvents,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_isSignedIn)
            Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.calendar_today, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect Google Calendar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Sync your events for outfit advice',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : ElevatedButton(
                          onPressed: _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Connect'),
                        ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Calendar Connected",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (_calendarService.isDemoMode) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'DEMO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          _calendarService.isDemoMode
                              ? 'Using demo data (configure Google OAuth to use real calendar)'
                              : "Connected as: ",
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, size: 20),
                    onPressed: () async {
                      await _calendarService.signOut();
                      if (mounted) {
                        setState(() {
                          _isSignedIn = false;
                          _events = [];
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Google Calendar disconnected'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeatherBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _weatherLoading
            ? const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            : _weatherForecast.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.cloud_off, color: AppColors.systemGray),
                    SizedBox(width: 8),
                    Text(
                      'Weather data unavailable',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          _weatherForecast[0]['isSunny'] == true
                              ? Icons.wb_sunny
                              : Icons.wb_cloudy,
                          color: _weatherForecast[0]['isSunny'] == true
                              ? Colors.amber
                              : AppColors.systemGray,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _weatherForecast[0]['condition'] ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _weatherForecast[0]['temp'] ?? '--',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_weatherForecast.length > 1)
                    SizedBox(
                      height: 35,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _weatherForecast.length - 1,
                        itemBuilder: (context, index) {
                          final forecast = _weatherForecast[index + 1];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.systemGray6.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    forecast['isSunny'] == true
                                        ? Icons.wb_sunny
                                        : Icons.wb_cloudy,
                                    color: forecast['isSunny'] == true
                                        ? Colors.amber
                                        : AppColors.systemGray,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    forecast['temp'] ?? '--',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isSignedIn && _events.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final title = event.summary ?? 'No Title';
          final start = event.start?.dateTime ?? event.start?.date;
          final time = start != null
              ? "${start.hour}:${start.minute.toString().padLeft(2, '0')}"
              : 'All Day';

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMaroon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMaroon,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Suggested: ${index % 2 == 0 ? "Formal Suit" : "Casual Chic"}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.systemGray),
              ],
            ),
          );
        },
      );
    }

    return _buildOutfitGrid();
  }

  Widget _buildOutfitGrid() {
    final days = [
      {
        'date': 'Today-Friday, Dec 24',
        'type': 'Formal',
        'img':
            'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&q=80&w=400',
      },
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
        return _buildDayCard(
          day['date'] as String,
          day['img'],
          day['type'] as String,
        );
      },
    );
  }

  Widget _buildDayCard(String date, String? imgUrl, String type) {
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
            child: imgUrl != null
                ? Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.systemGray6,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.photo,
                            color: AppColors.systemGray,
                            size: 40,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: AppColors.systemGray,
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
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
              style: const TextStyle(fontSize: 10, color: AppColors.systemGray),
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
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
