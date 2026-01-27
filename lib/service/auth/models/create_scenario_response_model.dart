class CreateScenarioResponseModel {
  final int id;
  final String scenarioId;
  final String scenarioTitle;
  final String description;
  final String difficultyLevel;

  CreateScenarioResponseModel({
    required this.id,
    required this.scenarioId,
    required this.scenarioTitle,
    required this.description,
    required this.difficultyLevel,
  });

  factory CreateScenarioResponseModel.fromJson(Map<String, dynamic> json) {
    // API returns ai_scenario_id which is the scenario_id needed for chat
    final scenarioId = json['ai_scenario_id'] as String? ?? 
                       json['scenario_id'] as String? ?? 
                       'scenario_${json['id']}';
    
    return CreateScenarioResponseModel(
      id: json['id'],
      scenarioId: scenarioId,  // This will be the ai_scenario_id from API
      scenarioTitle: json['scenario_title'],
      description: json['description'],
      difficultyLevel: json['difficulty_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scenario_id': scenarioId,
      'scenario_title': scenarioTitle,
      'description': description,
      'difficulty_level': difficultyLevel,
    };
  }
}
