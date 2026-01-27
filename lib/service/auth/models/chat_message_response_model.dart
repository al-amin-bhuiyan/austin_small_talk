/// Model for Chat Message Response
class ChatMessageResponse {
  final String status;
  final String sessionId;
  final bool isNewSession;
  final UserMessage? userMessage;
  final AiMessageData aiMessage;

  ChatMessageResponse({
    required this.status,
    required this.sessionId,
    required this.isNewSession,
    this.userMessage,
    required this.aiMessage,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      status: json['status'] ?? '',
      sessionId: json['session_id'] ?? '',
      isNewSession: json['is_new_session'] ?? false,
      userMessage: json['user_message'] != null
          ? UserMessage.fromJson(json['user_message'])
          : null,
      aiMessage: AiMessageData.fromJson(json['ai_message'] ?? {}),
    );
  }
}

/// Model for User Message
class UserMessage {
  final int id;
  final String messageType;
  final String textContent;
  final String? audioUrl;
  final String createdAt;
  final dynamic metadata;

  UserMessage({
    required this.id,
    required this.messageType,
    required this.textContent,
    this.audioUrl,
    required this.createdAt,
    this.metadata,
  });

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    return UserMessage(
      id: json['id'] ?? 0,
      messageType: json['message_type'] ?? '',
      textContent: json['text_content'] ?? '',
      audioUrl: json['audio_url'],
      createdAt: json['created_at'] ?? '',
      metadata: json['metadata'],
    );
  }
}

/// Model for AI Message Data
class AiMessageData {
  final int id;
  final String messageType;
  final String textContent;
  final String? audioUrl;
  final String createdAt;
  final AiMetadata? metadata;

  AiMessageData({
    required this.id,
    required this.messageType,
    required this.textContent,
    this.audioUrl,
    required this.createdAt,
    this.metadata,
  });

  factory AiMessageData.fromJson(Map<String, dynamic> json) {
    return AiMessageData(
      id: json['id'] ?? 0,
      messageType: json['message_type'] ?? '',
      textContent: json['text_content'] ?? '',
      audioUrl: json['audio_url'],
      createdAt: json['created_at'] ?? '',
      metadata: json['metadata'] != null
          ? AiMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

/// Model for AI Metadata
class AiMetadata {
  final String? gender;
  final RawAiResponseData? rawAiResponse;

  AiMetadata({
    this.gender,
    this.rawAiResponse,
  });

  factory AiMetadata.fromJson(Map<String, dynamic> json) {
    return AiMetadata(
      gender: json['gender'],
      rawAiResponse: json['raw_ai_response'] != null
          ? RawAiResponseData.fromJson(json['raw_ai_response'])
          : null,
    );
  }
}

/// Model for Raw AI Response Data
class RawAiResponseData {
  final String status;
  final String? userText;
  final String? aiText;
  final String? scenarioId;

  RawAiResponseData({
    required this.status,
    this.userText,
    this.aiText,
    this.scenarioId,
  });

  factory RawAiResponseData.fromJson(Map<String, dynamic> json) {
    return RawAiResponseData(
      status: json['status'] ?? '',
      userText: json['user_text'],
      aiText: json['ai_text'],
      scenarioId: json['scenario_id'],
    );
  }
}
