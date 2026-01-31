import 'package:flutter/material.dart';
import '../utils/colors.dart';

class StyleBotScreen extends StatefulWidget {
  const StyleBotScreen({super.key});

  @override
  State<StyleBotScreen> createState() => _StyleBotScreenState();
}

class _StyleBotScreenState extends State<StyleBotScreen> {
  bool _isChatActive = false;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isChatActive = true;
      _messages.add({'isUser': true, 'message': _messageController.text});
      // Simulate bot response
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add({
              'isUser': false,
              'message':
                  'For next week\'s college outfits, you can go for a mix of comfort and style. On Monday, try an oversized cream sweater with straight-leg jeans and white sneakers for a cozy start. Tuesday can be a casual chic look with a black ribbed top, wide-leg pants, and a small crossbody bag. Mid-week on Wednesday, a white tee with a denim jacket and a mini or midi skirt gives a cute, fresh vibe. On Thursday, switch to a relaxed streetwear style with an oversized graphic tee, cargo pants, and sneakers. For Friday, keep it smart casual with a light button-down tucked into mom jeans paired with loafers. These outfits stay comfortable for everyday campus life.',
            });
          });
        }
      });
      _messageController.clear();
    });
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
          // Time placeholder if needed, skipping for now as it's system bar usually
          const SizedBox(height: 40),
          const Text(
            'Hello Hirushie,',
            style: TextStyle(
              fontSize: 28, // Large serif font
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif', // Using default serif for now
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(flex: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(
                0xFFEBEBEB,
              ).withOpacity(0.8), // Light grey/beige
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ask Stylebot',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 80), // Space for typing area feel
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(
                    Icons.mic_none_rounded,
                    color: Colors.grey[600],
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
          // Assuming bottom nav is handled by HomeScreen, so we don't duplicate it here.
          // However, to make this functional, tapping the container should switch state or focus input.
          // For this demo, let's make it interactive.
          TextField(
            controller: _messageController,
            onSubmitted: (_) => _sendMessage(),
            decoration: const InputDecoration(
              hintText: 'Type your request...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
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
            itemCount: _messages.length,
            itemBuilder: (context, index) {
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
            'Stylebot',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF4A4A4A), // Dark grey
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          // Add close button or back if needed, but image doesn't show one clearly
          // (assuming it's a tab or top level).
          // If pushed, we need a back button.
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
              color: isUser
                  ? AppColors.primaryMaroon
                  : const Color(0xFFE0E0E0), // Grey for bot
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
              children: [
                const Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
                const SizedBox(width: 12),
                const Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.thumb_down_alt_outlined,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.ios_share_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.more_horiz_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
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
    // This is redundant if we assume the bottom nav is there,
    // but in "Chat" view we usually have an input bar.
    // The image shows the bottom nav below the chat.
    // And NO input bar in the "Chat" view image (Right image).
    // Wait, the Right Image shows the response and action buttons.
    // It DOES NOT show an input bar. It shows the bottom nav.
    // This implies the conversation might be "Request -> Response" and then maybe you tap somewhere to reply?
    // Or maybe the input bar is hidden or I just missed it?
    // Actually, looking closely at the Right Image, there IS NO input bar visible.
    // It ends with the bot message and the action row.
    // Maybe it scrolls?
    // I'll add a minimal input bar similar to the empty state one, or just a placeholder.
    // I'll add a standard input bar for functionality.

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
                  hintText: 'Reply...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
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
        ],
      ),
    );
  }
}
