# Daily Scenarios API Implementation

## Overview
This document describes the implementation of the Daily Scenarios API integration in the Austin Small Talk app. The feature dynamically fetches and displays conversation scenarios from the backend API.

## API Details

### Endpoint
```
GET {{small_talk}}core/chat/daily-scenarios/
```

### Request Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
Accept: application/json
```

### Response Structure
```json
{
    "status": "success",
    "scenarios": [
        {
            "scenario_id": "scenario_19751c5d",
            "emoji": "😊",
            "title": "Weather Chat",
            "description": "Discussing the weather and how it affects plans.",
            "difficulty": "Easy"
        },
        {
            "scenario_id": "scenario_3b036b58",
            "emoji": "👨‍💼",
            "title": "Job Introduction",
            "description": "Introducing yourself and talking about your job or studies.",
            "difficulty": "Medium"
        }
    ]
}
```

## Files Created/Modified

### 1. New Model - `daily_scenario_model.dart`
**Location:** `lib/service/auth/models/daily_scenario_model.dart`

Created two model classes:
- `DailyScenarioModel` - Represents a single scenario
- `DailyScenariosResponseModel` - Represents the API response

**Properties:**
- `scenarioId`: Unique identifier for the scenario
- `emoji`: Emoji icon for the scenario
- `title`: Scenario title
- `description`: Scenario description
- `difficulty`: Difficulty level (Easy/Medium/Hard)

### 2. API Constant - `api_constant.dart`
**Location:** `lib/service/auth/api_constant/api_constant.dart`

**Added:**
```dart
static const String dailyScenarios = '${smallTalk}core/chat/daily-scenarios/';
```

### 3. API Service - `api_services.dart`
**Location:** `lib/service/auth/api_service/api_services.dart`

**Added Method:**
```dart
Future<DailyScenariosResponseModel> getDailyScenarios({
  required String accessToken,
})
```

**Features:**
- Bearer token authentication
- Comprehensive error handling
- Response parsing and validation
- Debug logging

### 4. Home Controller - `home_controller.dart`
**Location:** `lib/pages/home/home_controller.dart`

**Added:**
- `dailyScenarios` - Observable list of scenarios
- `isLoading` - Loading state
- `fetchDailyScenarios()` - Method to fetch scenarios from API
- Auto-fetch on controller initialization

**Key Features:**
- Fetches scenarios when screen loads
- Uses SharedPreferencesUtil for token retrieval
- Shows error toast on failure
- Updates UI reactively with Obx

### 5. Home Screen - `home.dart`
**Location:** `lib/pages/home/home.dart`

**Modified:**
- `_buildScenarioGrid()` - Now dynamically renders scenarios from API
- `_buildScenarioCard()` - Supports both emoji and SVG icons

**Features:**
- Loading indicator while fetching
- Empty state when no scenarios available
- Dynamic grid layout (2x2 scenarios)
- Emoji support for scenario icons

## Implementation Flow

```
1. User opens Home Screen
   ↓
2. HomeController.onInit() called
   ↓
3. fetchDailyScenarios() executed
   ↓
4. Get access token from SharedPreferencesUtil
   ↓
5. Call ApiServices.getDailyScenarios()
   ↓
6. API returns scenarios data
   ↓
7. Parse response into DailyScenarioModel objects
   ↓
8. Update dailyScenarios observable list
   ↓
9. UI automatically updates via Obx()
   ↓
10. Display scenarios in grid layout
```

## UI States

### 1. Loading State
```dart
if (controller.isLoading.value && controller.dailyScenarios.isEmpty) {
  // Show CircularProgressIndicator
}
```

### 2. Empty State
```dart
if (scenarios.isEmpty) {
  // Show "No scenarios available" message
}
```

### 3. Success State
```dart
// Display scenarios in 2x2 grid with emoji icons
```

## Error Handling

### Token Missing
- Logs error to console
- Sets loading to false
- Returns early without API call

### API Error
- Catches exception
- Logs error to console
- Shows error toast to user
- Sets loading to false

### Network Error
- Handled by try-catch block
- User-friendly error message displayed

## Code Style Consistency

This implementation follows your project's established patterns:

✅ **GetX State Management**
- Observable variables with `.obs`
- Reactive UI updates with `Obx()`

✅ **Service Layer Pattern**
- API calls in `ApiServices` class
- Token management via `SharedPreferencesUtil`

✅ **Error Handling**
- Try-catch blocks
- User-friendly error messages via `ToastMessage`

✅ **Naming Conventions**
- camelCase for methods
- PascalCase for classes
- Descriptive variable names

✅ **UI Patterns**
- Private `_build*` methods
- ScreenUtil for responsive sizing
- Consistent spacing and styling

## Testing the Implementation

1. **Ensure user is logged in** (access token available)
2. **Navigate to Home Screen**
3. **Verify scenarios load** from API
4. **Check loading indicator** appears briefly
5. **Confirm scenarios display** in 2x2 grid
6. **Test tap functionality** on scenario cards
7. **Verify emoji icons** render correctly

## Future Enhancements

- Pull-to-refresh functionality
- Cache scenarios locally
- Offline mode support
- Scenario favorites/bookmarks
- Filter by difficulty level
- Search scenarios

## Dependencies

- `http` - HTTP requests
- `get` - State management
- `shared_preferences` - Local storage
- `flutter_screenutil` - Responsive sizing
- `flutter_svg` - SVG icon support

## Notes

- Scenarios are fetched automatically on screen load
- API requires valid Bearer token
- Maximum 4 scenarios displayed in grid
- Emoji icons render at 24sp size
- Loading state prevents multiple simultaneous API calls
