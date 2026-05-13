class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> actionsPerformed;
  final bool isError;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionsPerformed = const [],
    this.isError = false,
  });
}
