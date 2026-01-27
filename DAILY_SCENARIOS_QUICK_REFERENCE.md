# Daily Scenarios Quick Reference Guide

## 🎯 What Was Implemented

The home screen now dynamically fetches and displays conversation scenarios from the API instead of using hardcoded values.

## 📋 Quick Summary

**Before:** 4 hardcoded scenarios (On a Plane, Social Event, Workplace, Daily Topic)

**After:** Dynamic scenarios from API with:
- Real-time data fetching
- Emoji icons (😊, 👨‍💼, 🍽️, 🎉, etc.)
- Difficulty levels
- Unique scenario IDs

## 🔧 Files Modified

1. ✅ `lib/service/auth/models/daily_scenario_model.dart` - NEW
2. ✅ `lib/service/auth/api_constant/api_constant.dart` - UPDATED
3. ✅ `lib/service/auth/api_service/api_services.dart` - UPDATED
4. ✅ `lib/pages/home/home_controller.dart` - UPDATED
5. ✅ `lib/pages/home/home.dart` - UPDATED

## 🚀 How It Works

### Automatic Fetching
```dart
// Scenarios are fetched automatically when HomeController initializes
@override
void onInit() {
  super.onInit();
  fetchDailyScenarios(); // Automatic fetch
}
```

### Manual Refresh (Future Enhancement)
```dart
// Can be called to refresh scenarios
controller.fetchDailyScenarios();
```

### Display Logic
```dart
// In home.dart
Obx(() {
  if (controller.isLoading.value) {
    return CircularProgressIndicator();
  }
  
  if (controller.dailyScenarios.isEmpty) {
    return Text('No scenarios available');
  }
  
  return _buildScenarioGrid(); // Display scenarios
})
```

## 📊 API Endpoint

```
GET http://10.10.7.74:8001/core/chat/daily-scenarios/

Headers:
- Authorization: Bearer {access_token}
- Content-Type: application/json
```

## 🎨 UI Features

### Loading State
- Shows white circular progress indicator
- Only appears during initial load

### Empty State
- Shows "No scenarios available" message
- Displayed when API returns empty array

### Success State
- Displays up to 4 scenarios in 2x2 grid
- Emoji icons instead of SVG assets
- Responsive sizing with ScreenUtil

## 🔍 Debugging

### Check Console Logs

**Success:**
```
📡 Fetching daily scenarios...
📥 Response status: 200
✅ Fetched 4 daily scenarios
```

**No Token:**
```
❌ No access token found
```

**API Error:**
```
❌ Error fetching daily scenarios: Exception: Network error
```

### Common Issues

**1. Empty scenarios list**
- Check if user is logged in
- Verify access token exists
- Check API endpoint URL

**2. Loading never stops**
- Check network connectivity
- Verify API is running
- Check token validity

**3. Scenarios not displaying**
- Check `controller.dailyScenarios` is not empty
- Verify `Obx()` is wrapping the grid
- Check console for errors

## 📱 User Experience

1. **User opens Home Screen**
2. Loading indicator appears briefly
3. Scenarios fade in from API
4. User can tap any scenario to start conversation
5. Emoji icons make scenarios more engaging

## 🔐 Authentication

The API requires a valid Bearer token:

```dart
// Token retrieved from SharedPreferencesUtil
final accessToken = SharedPreferencesUtil.getAccessToken();

// Sent in request header
'Authorization': 'Bearer $accessToken'
```

## 🎯 Data Flow

```
HomeScreen
   ↓
HomeController.onInit()
   ↓
fetchDailyScenarios()
   ↓
SharedPreferencesUtil.getAccessToken()
   ↓
ApiServices.getDailyScenarios(accessToken)
   ↓
HTTP GET /core/chat/daily-scenarios/
   ↓
DailyScenariosResponseModel
   ↓
controller.dailyScenarios.value = scenarios
   ↓
Obx() triggers UI rebuild
   ↓
_buildScenarioGrid() displays scenarios
```

## 💡 Code Examples

### Access Scenarios in Controller
```dart
// Get all scenarios
final scenarios = controller.dailyScenarios;

// Get specific scenario
final firstScenario = controller.dailyScenarios[0];
print(firstScenario.title); // "Weather Chat"
print(firstScenario.emoji); // "😊"
```

### Handle Scenario Tap
```dart
onTap: () => controller.onScenarioTap(
  context,
  scenario.scenarioId,      // "scenario_19751c5d"
  scenario.emoji,           // "😊"
  scenario.title,           // "Weather Chat"
)
```

### Refresh Scenarios
```dart
// In UI (e.g., pull-to-refresh)
await controller.fetchDailyScenarios();
```

## ⚙️ Configuration

### Change Number of Displayed Scenarios
Currently shows first 4 scenarios. To show more:

```dart
// In _buildScenarioGrid(), add more rows
if (scenarios.length > 4) {
  // Third row
  Row(
    children: [
      // Scenario 5
      // Scenario 6
    ],
  ),
}
```

### Change Grid Layout
Current: 2x2 grid
Alternative: Single column list

```dart
ListView.builder(
  itemCount: controller.dailyScenarios.length,
  itemBuilder: (context, index) {
    final scenario = controller.dailyScenarios[index];
    return _buildScenarioCard(...);
  },
)
```

## 🧪 Testing Checklist

- [ ] Scenarios load on app start
- [ ] Loading indicator appears
- [ ] Emoji icons display correctly
- [ ] Tap on scenario works
- [ ] Error handling works (network off)
- [ ] Empty state displays when API returns []
- [ ] No console errors
- [ ] Token authentication works

## 🎉 Benefits

✅ Dynamic content - scenarios can be updated server-side
✅ No app updates needed to change scenarios
✅ Better user engagement with varied content
✅ Emoji icons are more visually appealing
✅ Difficulty levels help users choose
✅ Scalable architecture for future features

## 📞 Support

If scenarios don't load:
1. Check user is logged in
2. Verify API endpoint is correct
3. Check access token is valid
4. Review console logs for errors
5. Test API with Postman/curl

## 🔮 Future Enhancements

- Pull-to-refresh gesture
- Scenario caching
- Offline mode
- Scenario categories/filters
- Favorite scenarios
- Share scenarios
- Daily scenario rotation
- Push notifications for new scenarios
