# Scenario Management - Quick Reference

## API Endpoints

### Create Scenario (POST)
```
URL: {{small_talk}}core/scenarios/
Method: POST
Auth: Bearer Token

Request Body:
{
    "scenario_title": "Trip on Nepal update",
    "description": "Talk naturally with someone sitting next to you.",
    "difficulty_level": "hard",
    "conversation_length": "long"
}

Response:
{
    "id": 5,
    "scenario_title": "Trip on Nepal update",
    "description": "Talk naturally with someone sitting next to you.",
    "difficulty_level": "hard"
}
```

### Get User Scenarios (GET)
```
URL: {{small_talk}}core/scenarios/
Method: GET
Auth: Bearer Token

Response:
[
    {
        "id": 1,
        "scenario_title": "Trip on Nepal",
        "description": "Talk naturally with someone sitting next to you.",
        "difficulty_level": "hard"
    },
    {
        "id": 2,
        "scenario_title": "Job Interview",
        "description": "Practice interview questions.",
        "difficulty_level": "medium"
    }
]
```

## Models

### CreateScenarioRequestModel
- `scenario_title` (String)
- `description` (String)
- `difficulty_level` (String): beginner | medium | hard
- `conversation_length` (String): short | medium | long

### CreateScenarioResponseModel / ScenarioModel
- `id` (int)
- `scenario_title` (String)
- `description` (String)
- `difficulty_level` (String)

## Controllers

### CreateScenarioController
**Method**: `startScenario(BuildContext context)`
- Validates input
- Creates scenario via API
- Refreshes history controller
- Navigates to history screen

### HistoryController
**Method**: `fetchUserScenarios()`
- Fetches user scenarios from API
- Updates `userScenarios` list
- Called automatically on screen load

## UI Components

### History Screen
**Location**: Below "New Scenario" divider

**Displays**:
- Loading indicator
- Empty state message
- List of scenario cards

**Scenario Card**:
- Icon (left)
- Title (bold)
- Description (2 lines max)
- Difficulty badge (right, color-coded)

## Data Flow

```
1. Create Scenario
   ┌─────────────────────────┐
   │ CreateScenarioScreen    │
   │ Fill form & Submit      │
   └──────────┬──────────────┘
              │
              ↓
   ┌─────────────────────────┐
   │ POST /core/scenarios/   │
   │ Create new scenario     │
   └──────────┬──────────────┘
              │
              ↓
   ┌─────────────────────────┐
   │ Refresh History         │
   │ Navigate to History     │
   └─────────────────────────┘

2. View Scenarios
   ┌─────────────────────────┐
   │ HistoryScreen opened    │
   └──────────┬──────────────┘
              │
              ↓
   ┌─────────────────────────┐
   │ GET /core/scenarios/    │
   │ Fetch user scenarios    │
   └──────────┬──────────────┘
              │
              ↓
   ┌─────────────────────────┐
   │ Display scenario list   │
   └─────────────────────────┘
```

## Key Files

### Models
- `lib/service/auth/models/create_scenario_request_model.dart`
- `lib/service/auth/models/create_scenario_response_model.dart`
- `lib/service/auth/models/scenario_model.dart`

### API
- `lib/service/auth/api_constant/api_constant.dart`
- `lib/service/auth/api_service/api_services.dart`

### Controllers
- `lib/pages/home/create_scenario/create_scenario_controller.dart`
- `lib/pages/history/history_controller.dart`

### UI
- `lib/pages/home/create_scenario/create_scenario.dart`
- `lib/pages/history/history.dart`

## Testing Checklist

- [ ] Login to app
- [ ] Navigate to Create Scenario
- [ ] Fill all fields (title, description, difficulty, length)
- [ ] Click "Start Scenario"
- [ ] Verify success toast
- [ ] Verify navigation to History screen
- [ ] Verify new scenario appears in list
- [ ] Verify difficulty badge color
- [ ] Verify description truncation
- [ ] Test with no scenarios (empty state)
- [ ] Test with multiple scenarios
- [ ] Test error handling (invalid token)

## Common Issues

### Scenario not appearing
- Check if access token is valid
- Check console logs for API errors
- Verify API endpoint is correct
- Ensure HistoryController is initialized

### Loading forever
- Check network connection
- Verify API is responding
- Check console for errors

### Navigation not working
- Verify AppPath.history is correct
- Ensure context.mounted check
- Check GoRouter configuration
