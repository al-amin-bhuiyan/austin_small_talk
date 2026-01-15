# Create Scenario API Implementation

## Summary
Successfully implemented API integration for creating custom scenarios in the app.

## Implementation Details

### 1. API Endpoint
- **URL**: `{{small_talk}}core/scenarios/`
- **Method**: POST
- **Authentication**: Bearer Token

### 2. Request Model
**File**: `lib/service/auth/models/create_scenario_request_model.dart`

**Fields**:
- `scenario_title` (String): Title of the scenario
- `description` (String): Description of the scenario
- `difficulty_level` (String): One of "beginner", "medium", "hard"
- `conversation_length` (String): One of "short", "medium", "long"

### 3. Response Model
**File**: `lib/service/auth/models/create_scenario_response_model.dart`

**Fields**:
- `id` (int): Unique scenario ID
- `scenario_title` (String): Title of the scenario
- `description` (String): Description of the scenario
- `difficulty_level` (String): Difficulty level

### 4. API Constant
**File**: `lib/service/auth/api_constant/api_constant.dart`

Added:
```dart
static const String createScenario = '${smallTalk}core/scenarios/';
```

### 5. API Service Method
**File**: `lib/service/auth/api_service/api_services.dart`

**Method**: `createScenario()`
- Takes `CreateScenarioRequestModel` and access token
- Returns `CreateScenarioResponseModel`
- Handles error responses with proper error messages
- Includes debug logging

### 6. Controller Integration
**File**: `lib/pages/home/create_scenario/create_scenario_controller.dart`

**Updates**:
- Added `isLoading` state management
- Implemented `startScenario()` method with API call
- Validates input fields before API call
- Gets access token from SharedPreferences
- Maps UI values to API format:
  - Difficulty: "Beginner" → "beginner", "Medium" → "medium", "Hard" → "hard"
  - Conversation Length: 0.0-0.33 → "short", 0.34-0.66 → "medium", 0.67-1.0 → "long"
- Shows success/error messages using ToastMessage
- Navigates to voice chat screen on success

### 7. UI Updates
**File**: `lib/pages/home/create_scenario/create_scenario.dart`

**Updates**:
- Added loading indicator to "Start Scenario" button
- Button disabled during API call
- Shows CircularProgressIndicator while loading

## User Flow

1. User fills in scenario details:
   - Scenario Title (text field)
   - Description (text field)
   - Difficulty Level (dropdown: Beginner/Medium/Hard)
   - Conversation Length (slider: Start to End)

2. User clicks "Start Scenario" button

3. App validates input fields

4. App gets access token from SharedPreferences

5. App makes POST request to create scenario API

6. On success:
   - Shows success toast message
   - Navigates to voice chat screen

7. On error:
   - Shows error toast message
   - User remains on create scenario screen

## Error Handling

The implementation handles:
- Missing input fields (shows validation error)
- Missing access token (requires login)
- Network errors
- API error responses with detailed messages
- Field-specific errors from API

## Testing

To test the implementation:
1. Login to the app
2. Navigate to Create Scenario screen
3. Fill in all fields
4. Click "Start Scenario"
5. Verify API call in console logs
6. Check success navigation or error message

## Console Logs

The implementation includes debug logs:
- 🔷 Starting scenario creation
- ✅ Access token found
- 📝 Scenario details (title, description, difficulty, length)
- 📡 Creating scenario
- 📥 Response status and body
- ✅ Scenario created successfully with ID
- ❌ Error messages if any

## Notes

- Access token is retrieved from SharedPreferences
- Navigation uses GoRouter (context.go())
- Toast messages use custom ToastMessage utility
- Loading state prevents multiple submissions
- All API communication includes proper headers and authentication
