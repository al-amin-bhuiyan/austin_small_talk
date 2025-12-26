import 'package:get/get.dart';

class FAQsController extends GetxController {
  int? expandedIndex;

  final List<Map<String, String>> faqList = [
    {
      'question': 'What is this app for?',
      'answer':
      'This app helps you practice real-life conversations using AI-generated scenarios like airplane small talk, social events, workplace communication, and custom situations.',
    },
    {
      'question': 'How does the conversation practice work?',
      'answer':
      'Choose a scenario, start a session, and talk naturally. The AI responds in real time, simulating a realistic person with context-based replies.',
    },
    {
      'question': 'Will the conversations be the same every time?',
      'answer':
      'No, the conversations will change every day based on your search and interests.',
    },
    {
      'question': 'What is the "Create Your Own Scenario" feature?',
      'answer':
      'The "Create Your Own Scenario" feature is a segment where you can talk with the AI based on the scenario you choose, allowing for a more customized and personalized conversation.',
    },
  ];

  void toggleExpansion(int index) {
    if (expandedIndex == index) {
      expandedIndex = null;
    } else {
      expandedIndex = index;
    }
    update();
  }
}
