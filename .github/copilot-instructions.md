# Austin Small Talk - AI Agent Instructions

## Architecture Overview

This is a **Flutter GetX + GoRouter** social app focused on AI-powered voice conversations. The app features real-time WebSocket voice chat, scenario-based conversations, and comprehensive user management.

### Core Technologies
- **State Management**: GetX (controllers with reactive variables)
- **Navigation**: GoRouter with centralized route definitions
- **Voice/Audio**: WebSocket-based voice streaming with flutter_sound, TTS
- **Networking**: Custom API service layer with error handling
- **UI**: Custom snackbars via toastification package

## Key Architectural Patterns

### 1. GetX Controller Pattern
Controllers use **lazy loading with fenix** for memory efficiency:
```dart
// In dependency.dart
Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

// In controllers - observable state pattern
final RxBool isLoading = false.obs;
final RxString userName = 'Sophia Adams'.obs;
final RxList<DailyScenarioModel> dailyScenarios = <DailyScenarioModel>[].obs;
```

**Critical**: Always use `Get.lazyPut(() => Controller(), fenix: true)` in `lib/core/dependency/dependency.dart` for new controllers. The `fenix: true` enables auto-recreation after disposal.

### 2. Voice Chat Architecture 
The voice chat system uses a **layered WebSocket architecture**:

- **VoiceChatController**: UI state and user interactions
- **VoiceChatManager**: Singleton WebSocket connection manager
- **ConversationController**: Real-time audio streaming orchestration  
- **Specialized services**: MicStreamer, TTSPlayer, VoiceActivityDetector

**Key WebSocket URLs**:
- Main API: `http://10.10.7.74:8001/`
- Voice Chat: `ws://10.10.7.114:8000/ws/chat` (different server!)

### 3. Navigation with GoRouter
Routes defined in `lib/core/app_route/route_path.dart` with `AppPath` constants:
```dart
// Navigate using context.push()
void navigateToVoiceChat(BuildContext context) {
  context.push(AppPath.voiceChat);
}
```

### 4. Error Handling & User Feedback
**Always use CustomSnackbar** (not Get.snackbar) for user messages:
```dart
import '../../utils/custom_snackbar/custom_snackbar.dart';

CustomSnackbar.error(
  context: context,
  title: 'Error Title', 
  message: 'Detailed error message'
);
```

API errors support multiple formats - the service automatically extracts from:
- `{"errors": {"non_field_errors": ["message"]}}`
- `{"message": "error text"}`
- Field-specific errors

## Development Workflows

### Adding New Features
1. Create controller in appropriate `pages/` subdirectory
2. Register in `lib/core/dependency/dependency.dart` with `lazyPut` + `fenix: true`
3. Add route to `lib/core/app_route/route_path.dart`
4. Use CustomSnackbar for user feedback
5. Follow the observable state pattern with `.obs` variables

### API Integration Pattern
```dart
class ExampleController extends GetxController {
  final ApiServices _apiServices = ApiServices();
  final RxBool isLoading = false.obs;
  
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      final data = await _apiServices.getData();
      items.value = data;
    } catch (e) {
      CustomSnackbar.error(
        context: context,
        title: 'Error',
        message: 'Failed to load data'
      );
    } finally {
      isLoading.value = false;
    }
  }
}
```

### WebSocket Voice Chat Development
For voice features, always:
- Use `ApiConstant.voiceChatWs` for WebSocket URL (points to voice server)
- Generate unique session IDs with `Uuid().v4()`
- Handle connection lifecycle properly via VoiceChatManager
- Clean up audio resources in onClose()

## Project Conventions

### File Organization
```
lib/
├── core/          # App routes, dependencies, shared widgets
├── data/          # Shared preferences, global state
├── pages/         # Feature-specific UI and controllers  
├── service/       # API services and models
├── utils/         # Custom snackbars, toast messages, helpers
└── global/        # Global controllers (splash, etc.)
```

### Naming Patterns
- Controllers: `FeatureNameController` 
- Models: `FeatureNameModel` / `FeatureNameResponseModel`
- Screens: `FeatureName` (widget class)
- Routes: `AppPath.featureName` constants

### Code Quality Standards
- Use ScreenUtil for responsive sizing: `310.w`, `310.h`
- Wrap expensive widgets with RepaintBoundary for performance
- Use targeted GetBuilder updates: `update(['specificId'])`
- Always handle null safety properly
- Add comprehensive error logging for debugging

## Critical Integration Points

### Authentication Flow
- Tokens stored in SharedPreferences via `SharedPreferencesUtil`
- Access token key: `'access'`, refresh token key: `'refresh'`
- Auto-logout via VoiceChatManager on authentication failures

### Scenario System
Global scenario data stored in `data/global/scenario_data.dart`. Controllers access via:
```dart
final scenarioData = GlobalScenarioData.currentScenario;
```

### Performance Optimizations
- Use `Get.lazyPut` for controllers (not `Get.put`)
- Implement instant animation starts: call `update(['targetId'])` before Timer.periodic
- Use RepaintBoundary for complex animations (WaveBlob, SiriWave)
- Target specific widgets with GetBuilder IDs to minimize rebuilds

## Debugging Helpers

- Voice chat includes extensive console logging for WebSocket flows
- API services log all requests/responses for debugging  
- Breakpoints commonly set in voice_chat_controller.dart (see .idea/workspace.xml)
- Use `flutter run --verbose` for detailed build output

The extensive markdown documentation in the root provides detailed implementation examples for each major feature area.