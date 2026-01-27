/// Scenario Data Model for passing through navigation
class ScenarioData {
  final String scenarioId;
  final String scenarioType;
  final String scenarioIcon;
  final String scenarioTitle;
  final String scenarioDescription;
  final String? difficulty;
  final String? sourceScreen; // Track where user came from for smart back navigation

  ScenarioData({
    required this.scenarioId,
    required this.scenarioType,
    required this.scenarioIcon,
    required this.scenarioTitle,
    required this.scenarioDescription,
    this.difficulty,
    this.sourceScreen, // home, history, create_scenario, etc.
  });

  Map<String, dynamic> toJson() {
    return {
      'scenarioId': scenarioId,
      'scenarioType': scenarioType,
      'scenarioIcon': scenarioIcon,
      'scenarioTitle': scenarioTitle,
      'scenarioDescription': scenarioDescription,
      'difficulty': difficulty,
      'sourceScreen': sourceScreen,
    };
  }

  factory ScenarioData.fromJson(Map<String, dynamic> json) {
    return ScenarioData(
      scenarioId: json['scenarioId'] ?? '',
      scenarioType: json['scenarioType'] ?? '',
      scenarioIcon: json['scenarioIcon'] ?? '',
      scenarioTitle: json['scenarioTitle'] ?? '',
      scenarioDescription: json['scenarioDescription'] ?? '',
      difficulty: json['difficulty'],
      sourceScreen: json['sourceScreen'],
    );
  }

  @override
  String toString() {
    return 'ScenarioData(id: $scenarioId, type: $scenarioType, title: $scenarioTitle)';
  }
}
