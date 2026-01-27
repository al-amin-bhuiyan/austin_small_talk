/// Model for Chat Message Request
class ChatMessageRequest {
  final String textContent;

  ChatMessageRequest({
    required this.textContent,
  });

  Map<String, dynamic> toJson() {
    return {
      'text_content': textContent,
    };
  }
}
