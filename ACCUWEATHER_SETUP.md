# AccuWeather API Setup Guide

## Getting Your API Key

1. Visit [AccuWeather Developer Portal](https://developer.accuweather.com/)
2. Sign up for a free account
3. Create a new app to get your API key
4. Free tier includes:
   - 50 calls/day
   - 5-day forecast data
   - Current conditions

## Configuration

### Step 1: Add Your API Key
In `lib/services/weather_service.dart`, replace:
```dart
static const String _apiKey = 'YOUR_ACCUWEATHER_API_KEY';
```

with your actual API key:
```dart
static const String _apiKey = 'YOUR_ACTUAL_API_KEY_HERE';
```

### Step 2: (Optional) Store API Key Securely
For production apps, use environment variables:
1. Create a `.env` file in your project root (add to `.gitignore`)
2. Install `flutter_dotenv`: `flutter pub add flutter_dotenv`
3. Update `WeatherService`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

static const String _apiKey = String.fromEnvironment('ACCUWEATHER_API_KEY', 
  defaultValue: 'YOUR_ACCUWEATHER_API_KEY');
```

## Testing

Once configured:
1. Run the app: `flutter run`
2. Go to Calendar tab
3. Weather bar should display real 5-day forecast for London
4. Check console for any API errors

## Troubleshooting

**"Weather data unavailable"** 
- API key is invalid or empty
- Check `ACCUWEATHER_API_KEY` matches your actual key
- Verify API key has not expired

**"Failed to compile"**
- Ensure no syntax errors in `weather_service.dart`
- Run `flutter pub get` if imports are missing

**Rate limit exceeded**
- Free tier: 50 calls/day
- Wait 24 hours or upgrade to paid plan

## API Endpoints Used

- **Location Search**: `/locations/v1/cities/search` - Find city by name
- **5-Day Forecast**: `/forecasts/v1/daily/5day/{cityKey}` - Get 5-day forecast with temperature and condition text

## Current Implementation

The `WeatherService` class:
- Automatically falls back to mock data if API key is not configured
- Caches results locally to reduce API calls
- Displays temperature and weather condition (Sunny/Cloudy/Rainy)
- Updates calendar screen with real forecast data

For more info, visit [AccuWeather API Docs](https://developer.accuweather.com/apis)
