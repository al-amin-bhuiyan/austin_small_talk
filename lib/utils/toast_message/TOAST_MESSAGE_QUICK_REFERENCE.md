# ToastMessage Quick Reference Guide

## Import
```dart
import '../../utils/toast_message/toast_message.dart';
// Adjust path based on your file location
```

## Basic Usage

### Success Message
```dart
ToastMessage.success('Operation completed!');
```

### Error Message
```dart
ToastMessage.error('Something went wrong!');
```

### Info Message
```dart
ToastMessage.info('This is an information message');
```

### Warning Message
```dart
ToastMessage.warning('Please be careful!');
```

## With Custom Title

### Success with Title
```dart
ToastMessage.success('Profile updated successfully!', title: 'Success');
```

### Error with Title
```dart
ToastMessage.error('Failed to save changes', title: 'Error');
```

### Info with Title
```dart
ToastMessage.info('Navigate to settings', title: 'Info');
```

## With Custom Duration

```dart
ToastMessage.success(
  'Changes saved!',
  duration: Duration(seconds: 5),
);
```

## Advanced Usage

### Custom Toast
```dart
ToastMessage.show(
  title: 'Custom Title',
  message: 'Custom message here',
  type: ToastType.success,
  duration: Duration(seconds: 4),
  position: SnackPosition.TOP,
  backgroundColor: Colors.purple,
  textColor: Colors.white,
);
```

## Common Scenarios

### Form Validation Error
```dart
if (email.isEmpty) {
  ToastMessage.error('Please enter your email');
  return;
}
```

### API Success
```dart
try {
  await apiService.updateProfile();
  ToastMessage.success('Profile updated successfully!');
} catch (e) {
  ToastMessage.error('Failed to update profile');
}
```

### Navigation Info
```dart
void navigateToSettings() {
  ToastMessage.info('Opening settings...', title: 'Settings');
  // navigation code
}
```

### Delete Confirmation
```dart
onConfirm: () {
  Get.back();
  ToastMessage.error('Account deleted', title: 'Account Deleted');
}
```

## Message Types & Colors

| Type | Color | Icon | Usage |
|------|-------|------|-------|
| Success | Green | ✓ | Successful operations |
| Error | Red | ✗ | Errors, failures |
| Info | Blue | ℹ | Information, navigation |
| Warning | Orange | ⚠ | Warnings, cautions |

## Best Practices

1. **Use appropriate types**:
   - Success: For completed actions
   - Error: For failures and validation errors
   - Info: For general information
   - Warning: For cautionary messages

2. **Keep messages concise**:
   ```dart
   // ✓ Good
   ToastMessage.success('Profile updated!');
   
   // ✗ Too long
   ToastMessage.success('Your profile has been successfully updated with all the new information you provided.');
   ```

3. **Use titles when needed**:
   ```dart
   // ✓ Good - title adds context
   ToastMessage.error('Invalid email format', title: 'Validation Error');
   
   // ✗ Unnecessary title
   ToastMessage.success('Success', title: 'Success');
   ```

4. **Don't overuse toasts**:
   - Use for important feedback only
   - Avoid for every minor action
   - Consider alternatives for critical errors (dialogs)

## Migration from Get.snackbar

### Before
```dart
Get.snackbar(
  'Success',
  'Operation completed!',
  snackPosition: SnackPosition.BOTTOM,
  backgroundColor: Colors.green,
  colorText: Colors.white,
);
```

### After
```dart
ToastMessage.success('Operation completed!');
```

## Examples by Feature

### Authentication
```dart
// Login success
ToastMessage.success('Welcome back!');

// Login error
ToastMessage.error('Invalid credentials');

// Logout
ToastMessage.info('You have been logged out', title: 'Logout');
```

### Profile Management
```dart
// Profile update
ToastMessage.success('Profile updated successfully!');

// Avatar upload
ToastMessage.success('Avatar uploaded!');

// Validation error
ToastMessage.error('Please fill all required fields');
```

### Subscription
```dart
// Trial started
ToastMessage.success('Free trial started successfully!');

// Subscription failed
ToastMessage.error('Failed to start subscription');

// Plan changed
ToastMessage.info('Plan changed to Premium', title: 'Subscription');
```

### Settings
```dart
// Settings saved
ToastMessage.success('Settings saved successfully!');

// Notification enabled
ToastMessage.info('Notifications enabled');

// Security updated
ToastMessage.success('Security settings updated!');
```

## Troubleshooting

### Toast not showing?
- Ensure ToastMessage is imported
- Check if Get is initialized in main.dart
- Verify the context is valid

### Wrong colors?
- Use correct message type (success/error/info/warning)
- Or override with custom backgroundColor

### Toast duration too short?
```dart
ToastMessage.success(
  'Message here',
  duration: Duration(seconds: 5), // Custom duration
);
```

## Related Files
- Implementation: `lib/utils/toast_message/toast_message.dart`
- Usage examples: See controller files in `lib/pages/`
- Full documentation: `TOAST_MESSAGE_MIGRATION.md`
