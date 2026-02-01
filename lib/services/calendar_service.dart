import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';

class CalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [CalendarApi.calendarReadonlyScope],
  );

  GoogleSignInAccount? _currentUser;
  CalendarApi? _calendarApi;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        final httpClient = await _googleSignIn.authenticatedClient();
        if (httpClient != null) {
          _calendarApi = CalendarApi(httpClient);
        }
      }
      return _currentUser;
    } catch (error) {
      print('Google Sign-In Error: $error');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _calendarApi = null;
  }

  Future<List<Event>> getEvents() async {
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
      print('Error fetching events: $e');
      return [];
    }
  }

  bool get isSignedIn => _currentUser != null;
}
