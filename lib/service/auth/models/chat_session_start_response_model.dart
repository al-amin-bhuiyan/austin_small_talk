/// Model for Chat Session Start Response
class ChatSessionStartResponse {
  final String status;
  final String sessionId;
  final bool isNewSession;
  final AiMessage aiMessage;

  ChatSessionStartResponse({
    required this.status,
    required this.sessionId,
    required this.isNewSession,
    required this.aiMessage,
  });

  factory ChatSessionStartResponse.fromJson(Map<String, dynamic> json) {
    return ChatSessionStartResponse(
      status: json['status'] ?? '',
      sessionId: json['session_id'] ?? '',
      isNewSession: json['is_new_session'] ?? false,
      aiMessage: AiMessage.fromJson(json['ai_message'] ?? {}),
    );
  }
}

/// Model for AI Message
class AiMessage {
  final int id;
  final String messageType;
  final String textContent;
  final String? audioUrl;
  final String createdAt;
  final MessageMetadata? metadata;

  AiMessage({
    required this.id,
    required this.messageType,
    required this.textContent,
    this.audioUrl,
    required this.createdAt,
    this.metadata,
  });

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      id: json['id'] ?? 0,
      messageType: json['message_type'] ?? '',
      textContent: json['text_content'] ?? '',
      audioUrl: json['audio_url'],
      createdAt: json['created_at'] ?? '',
      metadata: json['metadata'] != null 
          ? MessageMetadata.fromJson(json['metadata']) 
          : null,
    );
  }
}

/// Model for Message Metadata
class MessageMetadata {
  final String? gender;
  final bool? isWelcome;
  final RawAiResponse? rawAiResponse;

  MessageMetadata({
    this.gender,
    this.isWelcome,
    this.rawAiResponse,
  });

  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      gender: json['gender'],
      isWelcome: json['is_welcome'],
      rawAiResponse: json['raw_ai_response'] != null
          ? RawAiResponse.fromJson(json['raw_ai_response'])
          : null,
    );
  }
}

/// Model for Raw AI Response
class RawAiResponse {
  final String status;
  final String? welcomeMessage;
  final String? scenarioId;
  final String? userText;
  final String? aiText;
  final ScenarioInfo? scenario;

  RawAiResponse({
    required this.status,
    this.welcomeMessage,
    this.scenarioId,
    this.userText,
    this.aiText,
    this.scenario,
  });

  factory RawAiResponse.fromJson(Map<String, dynamic> json) {
    return RawAiResponse(
      status: json['status'] ?? '',
      welcomeMessage: json['welcome_message'],
      scenarioId: json['scenario_id'],
      userText: json['user_text'],
      aiText: json['ai_text'],
      scenario: json['scenario'] != null
          ? ScenarioInfo.fromJson(json['scenario'])
          : null,
    );
  }
}

/// Model for Scenario Info
class ScenarioInfo {
  final String scenarioId;
  final String emoji;
  final String title;
  final String description;
  final String difficulty;

  ScenarioInfo({
    required this.scenarioId,
    required this.emoji,
    required this.title,
    required this.description,
    required this.difficulty,
  });

  factory ScenarioInfo.fromJson(Map<String, dynamic> json) {
    return ScenarioInfo(
      scenarioId: json['scenario_id'] ?? '',
      emoji: json['emoji'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? '',
    );
  }
}
