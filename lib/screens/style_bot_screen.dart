import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/weather_service.dart';

class StyleBotScreen extends StatefulWidget {
  const StyleBotScreen({super.key});

  @override
  State<StyleBotScreen> createState() => _StyleBotScreenState();
}

class _StyleBotScreenState extends State<StyleBotScreen> {
  bool _isChatActive = false;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isChatActive = true;
      _messages.add({'isUser': true, 'message': text});
      _isLoading = true;
    });
    _messageController.clear();

    String response;
    final lowerText = text.toLowerCase();

    // Simple intent detection
    if (lowerText.contains('weather')) {
      // Extract city logic (naive)
      String city = 'London'; // Default
      if (lowerText.contains('in ')) {
        city = text.substring(lowerText.indexOf('in ') + 3).trim();
        // Remove punctuation
        city = city.replaceAll(RegExp(r'[^\w\s]'), '');
      } else {
        response = "Please specify a city, e.g., 'Weather in Paris'.";
        _addBotResponse(response);
        return;
      }

      response = await _weatherService.getWeatherString(city);
    } else {
      // Fallback for non-weather queries (Mock Style Bot)
      await Future.delayed(const Duration(milliseconds: 500));
      response =
          "I am focusing on Weather updates right now! Ask me 'Weather in [City]' to get outfit advice based on the forecast.";
    }

    _addBotResponse(response);
  }

  void _addBotResponse(String response) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add({'isUser': false, 'message': response});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: _isChatActive ? _buildChatView() : _buildWelcomeView(),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Hello Hirushie,',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(flex: 2),
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB).withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Ask about Weather...',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.mic_none_rounded,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice input not implemented yet'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final msg = _messages[index];
              return _buildMessageBubble(msg['message'], msg['isUser']);
            },
          ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Text(
            'Style & Weather',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF4A4A4A),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (Navigator.canPop(context))
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primaryMaroon : const Color(0xFFE0E0E0),
              borderRadius: isUser
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(5),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          if (!isUser) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
                SizedBox(width: 12),
                Icon(Icons.thumb_up_alt_outlined, size: 18, color: Colors.grey),
                SizedBox(width: 12),
                Icon(
                  Icons.thumb_down_alt_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                SizedBox(width: 12),
                Icon(Icons.ios_share_rounded, size: 18, color: Colors.grey),
                SizedBox(width: 12),
                Icon(Icons.more_horiz_rounded, size: 18, color: Colors.grey),
              ],
            ),
          ],
          if (isUser) ...[
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.copy_rounded, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Check weather...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primaryMaroon,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
