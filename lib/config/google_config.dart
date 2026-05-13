/// Google Sign-In Configuration
class GoogleConfig {
  // Web Client ID - Replace with your actual Google OAuth 2.0 Web Client ID
  // Get this from Google Cloud Console: https://console.cloud.google.com/
  // Project: Create a project or use existing
  // APIs & Services > Credentials > OAuth 2.0 Client IDs > Web Application
  static const String webClientId =
      'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  // Android Client ID - Replace with your actual Google OAuth 2.0 Android Client ID
  static const String androidClientId =
      'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com';

  // iOS Client ID - Replace with your actual Google OAuth 2.0 iOS Client ID
  static const String iOSClientId =
      'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';

  // Scopes for Google Calendar API
  static const List<String> calendarScopes = [
    'https://www.googleapis.com/auth/calendar.readonly',
  ];
}
