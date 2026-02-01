import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import '../utils/colors.dart';
import '../widgets/custom_header.dart';
import '../services/calendar_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarService _calendarService = CalendarService();
  List<calendar.Event> _events = [];
  bool _isSignedIn = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    // In a real app, you might persist auth state or silently sign in
    // For now, we start as not signed in
    setState(() {
      _isSignedIn = _calendarService.isSignedIn;
    });
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    final account = await _calendarService.signIn();
    if (account != null) {
      await _fetchEvents();
      setState(() {
        _isSignedIn = true;
      });
    }
    setState(() => _isLoading = false);
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
            
            // Calendar Integration Section
            _buildCalendarSection(),
            
            const SizedBox(height: 20),
            
            // Outfit Grid (or Event Grid)
            Expanded(
              child: _buildMainContent(),
            ),
            
            // Footer Action
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
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
                children: const [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Text("Calendar Connected", style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
             ),
        ],
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
          final time = start != null ? "${start.hour}:${start.minute.toString().padLeft(2, '0')}" : 'All Day';
          
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

    // Default Grid if no events or not signed in
    return _buildOutfitGrid();
  }

  Widget _buildOutfitGrid() {
     final days = [
      {'date': 'Today-Friday, Dec 24', 'type': 'Formal', 'img': 'https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&q=80&w=400'},
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
        return _buildDayCard(day['date'] as String, day['img'] as String?, day['type'] as String);
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
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(imgUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
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
