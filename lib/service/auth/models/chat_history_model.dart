/// Chat History Response Model
class ChatHistoryResponseModel {
  final String status;
  final int count;
  final List<ChatSessionHistory> sessions;

  ChatHistoryResponseModel({
    required this.status,
    required this.count,
    required this.sessions,
  });

  factory ChatHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponseModel(
      status: json['status'] ?? 'success',
      count: json['count'] ?? 0,
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((session) => ChatSessionHistory.fromJson(session))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'count': count,
      'sessions': sessions.map((session) => session.toJson()).toList(),
    };
  }
}

/// Individual Chat Session History Item
class ChatSessionHistory {
  final String sessionId;
  final String? scenarioId;
  final String? scenarioTitle;
  final String? scenarioEmoji;
  final String? scenarioDifficulty;
  final String? scenarioDescription;
  final String mode;
  final String status;
  final DateTime startedAt;
  final DateTime lastActivityAt;
  final DateTime? endedAt;
  final String userEmail;
  final int messageCount;

  ChatSessionHistory({
    required this.sessionId,
    this.scenarioId,
    this.scenarioTitle,
    this.scenarioEmoji,
    this.scenarioDifficulty,
    this.scenarioDescription,
    required this.mode,
    required this.status,
    required this.startedAt,
    required this.lastActivityAt,
    this.endedAt,
    required this.userEmail,
    required this.messageCount,
  });

  factory ChatSessionHistory.fromJson(Map<String, dynamic> json) {
    return ChatSessionHistory(
      sessionId: json['session_id'] ?? '',
      scenarioId: json['scenario_id'],
      scenarioTitle: json['scenario_title'],
      scenarioEmoji: json['scenario_emoji'],
      scenarioDifficulty: json['scenario_difficulty'],
      scenarioDescription: json['scenario_description'],
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
      messageCount: json['message_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'scenario_id': scenarioId,
      'scenario_title': scenarioTitle,
      'scenario_emoji': scenarioEmoji,
      'scenario_difficulty': scenarioDifficulty,
      'scenario_description': scenarioDescription,
      'mode': mode,
      'status': status,
      'started_at': startedAt.toIso8601String(),
      'last_activity_at': lastActivityAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'user_email': userEmail,
      'message_count': messageCount,
    };
  }
}
