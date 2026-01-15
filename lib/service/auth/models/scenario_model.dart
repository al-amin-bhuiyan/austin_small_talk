class ScenarioModel {
  final int id;
  final String scenarioTitle;
  final String description;
  final String difficultyLevel;

  ScenarioModel({
    required this.id,
    required this.scenarioTitle,
    required this.description,
    required this.difficultyLevel,
  });

  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    return ScenarioModel(
      id: json['id'],
      scenarioTitle: json['scenario_title'],
      description: json['description'],
      difficultyLevel: json['difficulty_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenario_title': scenarioTitle,
      'description': description,
      'difficulty_level': difficultyLevel,
    };
  }
}
