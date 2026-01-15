# Red Screen Error - Troubleshooting Guide

## Issue
Red error screen appearing in the app (likely in History screen).

## Changes Made to Fix

### 1. History Controller (`history_controller.dart`)
**Problem**: API call might fail if user is not logged in or API is unreachable

**Fixes Applied**:
- ✅ Added null/empty check for access token before making API call
- ✅ Added stack trace logging for better error debugging
- ✅ Clear scenarios list on error
- ✅ Use `Future.delayed` to avoid blocking UI initialization
- ✅ Only fetch scenarios if access token exists

**Before**:
```dart
@override
void onInit() {
  super.onInit();
  fetchUserScenarios(); // Immediate call, could fail
}
```

**After**:
```dart
@override
void onInit() {
  super.onInit();
  Future.delayed(Duration.zero, () {
    if (SharedPreferencesUtil.getAccessToken() != null) {
      fetchUserScenarios();
    }
  });
}
```

### 2. History Screen (`history.dart`)
**Problem**: Type safety issue with scenario items

**Fixes Applied**:
- ✅ Added `ScenarioModel` import
- ✅ Changed `_buildScenarioItem` parameter from `dynamic` to `ScenarioModel`
- ✅ Better type safety to prevent runtime errors

## How to Debug Further

### Step 1: Hot Restart
```bash
# In terminal
r  # Hot reload
R  # Hot restart (full restart)
```

### Step 2: Check Console Logs
Look for these debug messages:
- `📡 Fetching user scenarios...`
- `❌ No access token found, skipping scenarios fetch`
- `✅ Access token found`
- `✅ Fetched X scenarios`
- `❌ Error fetching scenarios: [error message]`

### Step 3: Check if User is Logged In
The scenarios will only load if:
1. User is logged in
2. Access token exists in SharedPreferences
3. API is reachable

### Step 4: Test Without Scenarios
If error persists:
1. Comment out the scenarios fetching temporarily
2. Navigate to History screen
3. If screen loads, the issue is with API call
4. If screen still crashes, issue is elsewhere

## Common Causes of Red Screen

### 1. Null Safety Issues
- ✅ FIXED: Added proper null checks
- ✅ FIXED: Type safety with ScenarioModel

### 2. API Call Failures
- ✅ FIXED: Wrapped in try-catch
- ✅ FIXED: Only call if logged in
- ✅ FIXED: Clear list on error

### 3. Widget Build Errors
- ✅ FIXED: Proper type for scenario items
- ✅ FIXED: Obx wrapper for reactive updates

### 4. Initialization Issues
- ✅ FIXED: Delayed API call to avoid blocking initialization

## Testing Checklist

After hot restart, verify:
- [ ] History screen loads without red error
- [ ] "No scenarios created yet" shows when no scenarios exist
- [ ] Loading indicator appears briefly
- [ ] Created scenarios display properly
- [ ] No console errors

## If Issue Persists

### Temporary Workaround
Comment out the scenario fetching in `onInit`:

```dart
@override
void onInit() {
  super.onInit();
  // TEMPORARILY DISABLED FOR DEBUGGING
  // Future.delayed(Duration.zero, () {
  //   if (SharedPreferencesUtil.getAccessToken() != null) {
  //     fetchUserScenarios();
  //   }
  // });
}
```

### Check Other Possibilities
1. **Check if error is in different screen**: Navigate directly to other screens
2. **Check device logs**: Look for stack trace with actual line number
3. **Check API endpoint**: Verify base URL is correct
4. **Check network**: Ensure device/emulator has internet

## Error Log Format to Look For

When red screen appears, Flutter shows:
```
════════ Exception caught by widgets library ═════════
The following [ErrorType] was thrown building [WidgetName]:
[Error message]
[Stack trace]
════════════════════════════════════════════════════
```

Look for:
- Widget that threw the error
- Actual error message
- Line number in stack trace

## Quick Fix Commands

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Or hot restart
Press 'R' in terminal where flutter run is active
```

## Contact Points

If you see the error screen again:
1. Take a screenshot of the full error message
2. Copy the console output with error details
3. Note which screen/action triggers it
4. Check if it happens on login or navigation

## Summary

The most likely cause was the API call being made immediately when History screen loads, even if user is not logged in or API is not reachable. The fixes ensure:
- Safe initialization
- Proper error handling
- Type safety
- Graceful degradation (empty state)
