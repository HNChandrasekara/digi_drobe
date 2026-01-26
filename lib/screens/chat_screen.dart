import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/custom_header.dart';

class ChatScreen extends StatelessWidget {
  final String channelName;

  const ChatScreen({super.key, required this.channelName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const CustomHeader(userName: 'Hirushie'),
            _buildChannelHeader(context),
            Expanded(child: _buildChatArea()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.primaryMaroon,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              channelName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryMaroon,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Follow',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildChatBubble(
          'Daily Outfit Posts',
          'A simple way to approach daily outfit posts:\n\n'
              '• Keep it consistent: Post around the same time each day so followers know when to expect content.\n'
              '• Plan outfits ahead: Mix and match basics with statement pieces to create interesting looks.\n'
              '• Photography matters: Natural light works best; simple backgrounds make your outfit stand out.\n'
              '• Engage your audience: Share a small tip or story about the outfit in the caption.\n'
              '• Use hashtags: Hashtags like #OOTD, #StyleInspo, #DailyLook help reach more people.',
        ),
        const SizedBox(height: 20),
        _buildChatBubble(
          'Wardrobe Tips',
          'A good wardrobe starts with basic, well-fitting clothes like t-shirts, pants, and jackets that can be mixed and matched easily. Neutral colors work well, and you can add some color or accessories to make outfits interesting. Shoes and accessories can change a simple look, so choose them carefully. Layering clothes can make your style more fun, and rotating clothes by season keeps them fresh. Taking care of your clothes and experimenting a little with trends helps you look stylish every day.',
        ),
      ],
    );
  }

  Widget _buildChatBubble(String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD9D9D9).withValues(alpha: 0.5),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.primaryMaroon.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Message',
                    hintStyle: TextStyle(color: AppColors.systemGray),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Icon(Icons.mic_none_rounded, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryMaroon,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
