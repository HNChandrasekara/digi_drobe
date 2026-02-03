import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class CalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  GoogleSignInAccount? _currentUser;
  CalendarApi? _calendarApi;
  bool _demoMode = false;
  List<Event> _demoEvents = [];

  CalendarService({bool demoMode = false}) {
    _demoMode = demoMode;
    if (_demoMode) {
      _initializeDemoEvents();
    }
  }

  void _initializeDemoEvents() {
    final now = DateTime.now();
    _demoEvents = [
      Event(
        summary: 'Team Standup',
        start: EventDateTime(dateTime: now.add(const Duration(hours: 1))),
        end: EventDateTime(dateTime: now.add(const Duration(hours: 2))),
      ),
      Event(
        summary: 'Design Review',
        start: EventDateTime(dateTime: now.add(const Duration(hours: 3))),
        end: EventDateTime(dateTime: now.add(const Duration(hours: 4))),
      ),
      Event(
        summary: 'Client Call',
        start: EventDateTime(dateTime: now.add(const Duration(days: 1))),
        end: EventDateTime(
          dateTime: now.add(const Duration(days: 1, hours: 1)),
        ),
      ),
    ];
  }

  /// Sign in - returns demo account in demo mode, or initiates real auth
  Future<GoogleSignInAccount?> signIn() async {
    if (_demoMode) {
      print('[CalendarService] Demo mode: demo user "signed in"');
      await Future.delayed(const Duration(milliseconds: 500));
      // Just set a marker that we're signed in for demo
      _currentUser = null; // Will use _demoMode flag for isSignedIn
      return null; // Return null but isSignedIn will return true due to demo mode
    }

    try {
      print('[CalendarService] Starting real authentication...');
      _currentUser = await _googleSignIn.authenticate();
      print('[CalendarService] Auth result: $_currentUser');

      if (_currentUser != null) {
        await _setupCalendarApi();
      }
      return _currentUser;
    } catch (error) {
      print('[CalendarService] Auth error: $error - switching to demo mode');
      _demoMode = true;
      _initializeDemoEvents();
      return null; // Will use demo mode flag
    }
  }

  /// Check if user is already signed in
  Future<GoogleSignInAccount?> checkSignInStatus() async {
    if (_demoMode) return null;

    try {
      _currentUser = await _googleSignIn.attemptLightweightAuthentication();
      if (_currentUser != null) {
        await _setupCalendarApi();
      }
      return _currentUser;
    } catch (error) {
      print('[CalendarService] Check status error: $error');
      return null;
    }
  }

  /// Setup the CalendarApi with authenticated client
  Future<void> _setupCalendarApi() async {
    try {
      if (_currentUser != null) {
        final authorization = await _currentUser?.authorizationClient
            .authorizationForScopes([CalendarApi.calendarReadonlyScope]);

        if (authorization != null) {
          final auth.AuthClient client = authorization.authClient(
            scopes: [CalendarApi.calendarReadonlyScope],
          );
          _calendarApi = CalendarApi(client);
        }
      }
    } catch (error) {
      print('[CalendarService] Setup error: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _calendarApi = null;
      _demoMode = false;
    } catch (error) {
      print('[CalendarService] Sign out error: $error');
    }
  }

  Future<List<Event>> getEvents() async {
    if (_demoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _demoEvents;
    }

    if (_calendarApi == null) return [];

    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: DateTime.now().toUtc(),
        maxResults: 10,
        singleEvents: true,
        orderBy: 'startTime',
      );
      return events.items ?? [];
    } catch (e) {
      print('[CalendarService] Error: $e');
      return [];
    }
  }

  bool get isSignedIn => _demoMode || _currentUser != null;
  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isDemoMode => _demoMode;
}
