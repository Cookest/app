import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';

final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => [
  ChatMessage(
    text: "Hi! I'm Cookest AI. I can help you find recipes, plan your meals, or answer cooking questions. What's on your mind?",
    isUser: false,
    timestamp: DateTime.now(),
  ),
]);

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    
    final messages = ref.read(chatMessagesProvider);
    ref.read(chatMessagesProvider.notifier).state = [
      ...messages,
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    ];

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    try {
      final response = await ref.read(chatRepositoryProvider).sendMessage(text);
      
      final updatedMessages = ref.read(chatMessagesProvider);
      ref.read(chatMessagesProvider.notifier).state = [
        ...updatedMessages,
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      ];
    } catch (e) {
      final updatedMessages = ref.read(chatMessagesProvider);
      ref.read(chatMessagesProvider.notifier).state = [
        ...updatedMessages,
        ChatMessage(text: e.toString(), isUser: false, timestamp: DateTime.now()),
      ];
    } finally {
      setState(() => _isLoading = false);
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cookest AI', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Cookest AI is typing...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: message.isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: !message.isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: 24,
            child: IconButton(
              icon: const Icon(LucideIcons.send, color: Colors.white, size: 20),
              onPressed: _isLoading ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
