# Google Sign-In Setup Instructions

## For Web (Chrome)

To enable Google Calendar sign-in on the web, you need to:

1. **Create a Google Cloud Project:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select an existing one

2. **Enable the Google Calendar API:**
   - In the Google Cloud Console, navigate to APIs & Services
   - Click "Enable APIs and Services"
   - Search for "Google Calendar API"
   - Click it and press "Enable"

3. **Create OAuth 2.0 Credentials:**
   - Go to APIs & Services > Credentials
   - Click "Create Credentials" > "OAuth 2.0 Client ID"
   - Choose "Web application"
   - Add Authorized JavaScript origins:
     - `http://localhost:8080` (for local development)
     - Your production domain
   - Add Authorized redirect URIs:
     - `http://localhost:8080/` (for local development)
     - Your production domain + `/`
   - Click "Create"
   - Copy your **Client ID**

4. **Update the app configuration:**
   - Open `lib/config/google_config.dart`
   - Replace `YOUR_WEB_CLIENT_ID` with your actual Client ID from step 3

5. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

6. **Test the connection:**
   - Click the "Connect" button on the Calendar screen
   - You should be prompted to sign in with your Google account
   - After signing in, your calendar events should load

## For Android

1. Get your **Android Client ID** from Google Cloud Console (Web application > Authorized origins: `https://oauth.apps.googleusercontent.com`)
2. Update `lib/config/google_config.dart` with your Android Client ID
3. Configure `android/app/build.gradle` with proper signing config

## For iOS

1. Get your **iOS Client ID** from Google Cloud Console
2. Update `lib/config/google_config.dart` with your iOS Client ID
3. Configure iOS signing in Xcode

## Troubleshooting

If the sign-in button doesn't work:
- Check browser console for errors (F12)
- Verify Client ID is correct in config
- Ensure origin/redirect URIs match your domain
- Check that Google Calendar API is enabled in Google Cloud Console
