import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  // TODO: Replace with your actual valid API key
  // You can get one from https://makersuite.google.com/app/apikey
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  // static const String _apiKey = 'AIzaSy...'; // Example of a real key

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
      systemInstruction: Content.system('You are a helpful assistant for Digi Drobe. You strictly only answer questions related to fashion, outfits, vr, avatar, and weather. If the user asks about anything else, politely decline and state that you can only discuss these topics.'),
    );
  }

  Future<String> sendMessage(String message) async {
    // If the API key is not set, use Mock Mode for demonstration
    if (_apiKey == 'YOUR_API_KEY_HERE' || _apiKey.length < 20) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      return _getMockResponse(message);
    }

    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      return response.text ?? "I couldn't generate a response. Please try again.";
    } catch (e) {
      // Fallback to mock on error as well, for smoother demo
      return "Offline Mode (Error: $e)\n\n${_getMockResponse(message)}";
    }
  }

  String _getMockResponse(String message) {
    final lowerMsg = message.toLowerCase();
    
    if (lowerMsg.contains('fashion')) {
      return "Fashion is all about expressing yourself! For 2026, we're seeing a lot of sustainable fabrics and digital-first designs. How can I help you style your look today?";
    } else if (lowerMsg.contains('outfit')) {
      return "For a casual day out, try pairing wide-leg neutrals with a fitted crop top. Add some chunky sneakers for that modern edge. Would you like suggestions for a specific occasion?";
    } else if (lowerMsg.contains('vr') || lowerMsg.contains('avatar')) {
      return "Your digital avatar is looking great! Try the new 'Cyber-Chic' collection in the VR dressing room. It features glowing accents that look amazing in virtual spaces.";
    } else if (lowerMsg.contains('weather')) {
      return "Checking the weather... It looks sunny! Perfect for light linens and sunglasses. Don't forget sunscreen!";
    } else {
      return "I can help you with fashion advice, outfit recommendations, VR avatar customization, or checking the weather for style tips. What would you like to know?";
    }
  }
}
