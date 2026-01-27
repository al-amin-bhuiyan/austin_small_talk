/// Session History with Messages Model
class SessionHistoryModel {
  final String status;
  final SessionWithMessages session;

  SessionHistoryModel({
    required this.status,
    required this.session,
  });

  factory SessionHistoryModel.fromJson(Map<String, dynamic> json) {
    return SessionHistoryModel(
      status: json['status'] ?? 'success',
      session: SessionWithMessages.fromJson(json['session'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'session': session.toJson(),
    };
  }
}

/// Session with Messages
class SessionWithMessages {
  final String sessionId;
  final String? scenarioId;
  final String? scenarioTitle;
  final String? scenarioEmoji;
  final String? scenarioDescription;
  final String? scenarioDifficulty;
  final String mode;
  final String status;
  final DateTime startedAt;
  final DateTime lastActivityAt;
  final DateTime? endedAt;
  final String userEmail;
  final List<ChatMessage> messages;

  SessionWithMessages({
    required this.sessionId,
    this.scenarioId,
    this.scenarioTitle,
    this.scenarioEmoji,
    this.scenarioDescription,
    this.scenarioDifficulty,
    required this.mode,
    required this.status,
    required this.startedAt,
    required this.lastActivityAt,
    this.endedAt,
    required this.userEmail,
    required this.messages,
  });

  factory SessionWithMessages.fromJson(Map<String, dynamic> json) {
    return SessionWithMessages(
      sessionId: json['session_id'] ?? '',
      scenarioId: json['scenario_id'],
      scenarioTitle: json['scenario_title'],
      scenarioEmoji: json['scenario_emoji'],
      scenarioDescription: json['scenario_description'],
      scenarioDifficulty: json['scenario_difficulty'],
      mode: json['mode'] ?? 'text',
      status: json['status'] ?? 'active',
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : DateTime.now(),
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.parse(json['last_activity_at'])
          : DateTime.now(),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      userEmail: json['user_email'] ?? '',
      messages: (json['messages'] as List<dynamic>?)
              ?.map((msg) => ChatMessage.fromJson(msg))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'scenario_id': scenarioId,
      'scenario_title': scenarioTitle,
      'scenario_emoji': scenarioEmoji,
      'scenario_description': scenarioDescription,
      'scenario_difficulty': scenarioDifficulty,
      'mode': mode,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'last_activity_at': lastActivityAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'user_email': userEmail,
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };
  }
}

/// Chat Message Model
class ChatMessage {
  final int id;
  final String messageType;
  final String textContent;
  final String? audioUrl;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.messageType,
    required this.textContent,
    this.audioUrl,
    required this.createdAt,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      messageType: json['message_type'] ?? 'user',
      textContent: json['text_content'] ?? '',
      audioUrl: json['audio_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message_type': messageType,
      'text_content': textContent,
      'audio_url': audioUrl,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Helper to check if this is a welcome message
  bool get isWelcomeMessage {
    return metadata != null && metadata!['is_welcome'] == true;
  }

  // Helper to get welcome message text
  String get welcomeMessageText {
    if (metadata != null && 
        metadata!['raw_ai_response'] != null &&
        metadata!['raw_ai_response']['welcome_message'] != null) {
      return metadata!['raw_ai_response']['welcome_message'];
    }
    return textContent;
  }
}
