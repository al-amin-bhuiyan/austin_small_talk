# Quick Usage Guide: Custom Snackbar

## Import
```dart
import '../../utils/custom_snackbar/custom_snackbar.dart';
```

## Success Message
```dart
CustomSnackbar.success(
  title: 'Success',
  message: 'Your operation completed successfully',
);
```

## Error Message
```dart
CustomSnackbar.error(
  title: 'Error',
  message: 'Something went wrong',
);
```

## Warning Message
```dart
CustomSnackbar.warning(
  title: 'Warning',
  message: 'Please complete all fields',
);
```

## Info Message
```dart
CustomSnackbar.info(
  title: 'Info',
  message: 'This feature is coming soon',
);
```

## Custom Duration
```dart
CustomSnackbar.success(
  title: 'Saved',
  message: 'Changes saved successfully',
  duration: Duration(seconds: 5), // Show for 5 seconds
);
```

## Real Examples from Project

### Registration Success
```dart
CustomSnackbar.success(
  title: 'Success',
  message: response.message,
);
```

### Email Already Exists
```dart
CustomSnackbar.error(
  title: 'Email Already Registered',
  message: 'User with this email already exists and is active.',
);
```

### Invalid OTP
```dart
CustomSnackbar.error(
  title: 'Invalid OTP',
  message: 'The OTP you entered is incorrect',
);
```

### Selection Required
```dart
CustomSnackbar.warning(
  title: 'Selection Required',
  message: 'Please select your preferred AI voice',
);
```

## Features
✅ Appears at TOP of screen
✅ Floating style with shadow
✅ Auto-dismisses after 3 seconds
✅ Can be swiped away horizontally
✅ White text on colored background
✅ Icon on the left side
✅ Bold title, regular message

## Colors
- **Green** = Success
- **Red** = Error
- **Orange** = Warning
- **Blue** = Info

## That's it! 🎉
Super simple to use anywhere in your app!
