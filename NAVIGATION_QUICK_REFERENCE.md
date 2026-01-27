# Quick Reference: IndexedStack Navigation

## What Changed?

### Before (Had White Screen Flicker)
```dart
// NavBar clicked → context.go() → Full page rebuild → White flash
NavBarController.changeIndex(index, context)
  → context.go(AppPath.home)
  → Full navigation stack change
  → Page rebuild
  → WHITE SCREEN FLICKER ❌
```

### After (No Flicker)
```dart
// NavBar clicked → Index change → Instant switch
NavBarController.changeIndex(index)
  → selectedIndex.value = index
  → IndexedStack shows page at index
  → NO REBUILD, NO FLICKER ✅
```

## Key Concepts

### IndexedStack
- Keeps all child widgets (pages) in memory
- Only displays the child at the current index
- Other children are hidden (not destroyed)
- Switching = changing visibility, not rebuilding

### Why This Works
1. **All pages stay alive** in memory
2. **Switching tabs** = just showing/hiding
3. **No navigation** = no white screen
4. **Instant** = better UX

## Usage

### Navigate from Code
```dart
// From any screen, navigate to a tab:
context.go(AppPath.history);
// MainNavigation will automatically show the History tab
```

### Navigate from NavBar
```dart
// User clicks tab → automatic
controller.changeIndex(2); // Shows AI Talk
```

### Get Current Tab
```dart
final controller = Get.find<NavBarController>();
int currentTab = controller.selectedIndex.value;
// 0=Home, 1=History, 2=AI Talk, 3=Profile
```

### Set Tab Programmatically
```dart
controller.setTab(1); // Go to History tab
```

## Important Notes

⚠️ **State Preservation**
- All 4 main tabs keep their state when switching
- ScrollController positions are preserved
- Form data stays intact
- Perfect for tabs that shouldn't reset

⚠️ **Memory Usage**
- All 4 pages loaded in memory at once
- Acceptable trade-off for smooth UX
- Only 4 pages, so minimal impact

⚠️ **External Navigation**
- Other pages (message_screen, voice_chat, etc.) still use normal GoRouter
- Only the 4 main tabs use IndexedStack
- Best of both worlds

## Testing Checklist

- [x] Home → History (smooth?)
- [x] History → AI Talk (smooth?)
- [x] AI Talk → Profile (smooth?)
- [x] Profile → Home (smooth?)
- [x] Rapid switching (no flicker?)
- [x] External navigation to tabs works?
- [x] Tab states preserved?

## Architecture

```
MainNavigation (IndexedStack container)
├── HomeScreen (index 0)
├── HistoryScreen (index 1)
├── AiTalkScreen (index 2)
└── ProfileScreen (index 3)
     ↑
     └── NavBarController.selectedIndex (reactive)
              ↑
              └── CustomNavBar (updates index on tap)
```

---

**Result:** Smooth, native-like tab navigation with zero flicker! 🎉
