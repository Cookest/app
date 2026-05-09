import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cookest_ui/cookest_ui.dart';

import '../repositories/chat_repository.dart';
import '../models/chat_message.dart';

final chatMessagesProvider = StateProvider<List<ChatMessage>>((ref) => [
      ChatMessage(
        text:
            "Hi! I'm Cookest AI. I can help you find recipes, plan your meals, or answer cooking questions. What's on your mind?",
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
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
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

  Future<void> _sendMessage([String? _]) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final messages = ref.read(chatMessagesProvider);
    ref.read(chatMessagesProvider.notifier).state = [
      ...messages,
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    ];

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    try {
      final response =
          await ref.read(chatRepositoryProvider).sendMessage(text);
      final updated = ref.read(chatMessagesProvider);
      ref.read(chatMessagesProvider.notifier).state = [
        ...updated,
        ChatMessage(
            text: response, isUser: false, timestamp: DateTime.now()),
      ];
    } catch (e) {
      final updated = ref.read(chatMessagesProvider);
      ref.read(chatMessagesProvider.notifier).state = [
        ...updated,
        ChatMessage(
            text: e.toString(), isUser: false, timestamp: DateTime.now()),
      ];
    } finally {
      if (mounted) setState(() => _isLoading = false);
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);

    return Scaffold(
      backgroundColor: CookestTokens.colorBackgroundLight,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: CookestTokens.colorBackgroundLight,
        elevation: 0,
        title: Text(
          'Cookest AI',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: CookestTokens.colorHeadingLight,
          ),
        ),
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
                if (message.isUser) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12, left: 48),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: CookestTokens.colorPrimaryDEFAULT,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        message.text,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ),
                  );
                }
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12, right: 48),
                    child: CkCard(
                      variant: CkCardVariant.standard,
                      padding: CkCardPadding.sm,
                      child: Text(message.text,
                          style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CookestTokens.colorSurfaceLight,
              border: Border(
                top: BorderSide(color: CookestTokens.colorBorderLight),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
                8, 8, 8, MediaQuery.of(context).padding.bottom + 8),
            child: Row(
              children: [
                Expanded(
                  child: CkInput(
                    controller: _messageController,
                    placeholder: 'Ask Cookest AI...',
                    fullWidth: true,
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                _isLoading
                    ? const CkSpinner(size: CkSpinnerSize.sm)
                    : CkButton(
                        variant: CkButtonVariant.ghost,
                        size: CkButtonSize.sm,
                        iconLeft: const Icon(LucideIcons.send, size: 16),
                        onPressed: () => _sendMessage(),
                        child: const SizedBox.shrink(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
