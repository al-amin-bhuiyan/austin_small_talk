/// Daily Scenario Model
class DailyScenarioModel {
  final String scenarioId;
  final String emoji;
  final String title;
  final String description;
  final String difficulty;

  DailyScenarioModel({
    required this.scenarioId,
    required this.emoji,
    required this.title,
    required this.description,
    required this.difficulty,
  });

  factory DailyScenarioModel.fromJson(Map<String, dynamic> json) {
    return DailyScenarioModel(
      scenarioId: json['scenario_id'] ?? '',
      emoji: json['emoji'] ?? '😊',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? 'Easy',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scenario_id': scenarioId,
      'emoji': emoji,
      'title': title,
      'description': description,
      'difficulty': difficulty,
    };
  }
}

/// Daily Scenarios Response Model
class DailyScenariosResponseModel {
  final String status;
  final List<DailyScenarioModel> scenarios;

  DailyScenariosResponseModel({
    required this.status,
    required this.scenarios,
  });

  factory DailyScenariosResponseModel.fromJson(Map<String, dynamic> json) {
    return DailyScenariosResponseModel(
      status: json['status'] ?? 'success',
      scenarios: (json['scenarios'] as List<dynamic>?)
              ?.map((scenario) => DailyScenarioModel.fromJson(scenario))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'scenarios': scenarios.map((scenario) => scenario.toJson()).toList(),
    };
  }
}
