class CreateScenarioRequestModel {
  final String scenarioTitle;
  final String description;
  final String difficultyLevel;
  final String conversationLength;

  CreateScenarioRequestModel({
    required this.scenarioTitle,
    required this.description,
    required this.difficultyLevel,
    required this.conversationLength,
  });

  Map<String, dynamic> toJson() {
    return {
      'scenario_title': scenarioTitle,
      'description': description,
      'difficulty_level': difficultyLevel,
      'conversation_length': conversationLength,
    };
  }
}
