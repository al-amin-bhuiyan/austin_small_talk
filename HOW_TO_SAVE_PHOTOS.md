# 📸 How to Save Photos in Flutter Emulator Storage

## ✅ Complete Setup Guide

### 1. Install Dependencies

Run this command in your terminal:
```bash
flutter pub get
```

This will install the newly added packages:
- `image_gallery_saver: ^2.0.3` - For saving images to gallery
- `path_provider: ^2.1.2` - For accessing device directories

### 2. Permissions Setup

#### Android Permissions (Already Added ✅)
The following permissions have been added to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

#### iOS Permissions (If needed)
Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save photos to your gallery</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photos</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera</string>
```

### 3. Import the ImageSaver Utility

In any file where you want to save images:
```dart
import '../../../helper/image_saver/image_saver.dart';
```

## 🚀 Quick Start Examples

### Example 1: Save Image from File
```dart
import 'dart:io';
import '../../../helper/image_saver/image_saver.dart';

Future<void> saveImage(File imageFile) async {
  await ImageSaver.saveImageFromFile(imageFile);
}
```

### Example 2: Save with Custom Name
```dart
Future<void> saveWithName(File imageFile) async {
  await ImageSaver.saveImageFromFile(
    imageFile,
    fileName: 'my_photo',
  );
}
```

### Example 3: Save to Downloads Folder
```dart
Future<void> saveToDownloads(File imageFile) async {
  final path = await ImageSaver.saveImageToDownloads(
    imageFile,
    fileName: 'my_download.jpg',
  );
  print('Saved to: $path');
}
```

### Example 4: Complete Widget with Image Picker
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../helper/image_saver/image_saver.dart';

class SavePhotoWidget extends StatefulWidget {
  @override
  _SavePhotoWidgetState createState() => _SavePhotoWidgetState();
}

class _SavePhotoWidgetState extends State<SavePhotoWidget> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndSave() async {
    // Pick image
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      
      // Save to gallery
      await ImageSaver.saveImageFromFile(_image!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_image != null)
          Image.file(_image!, width: 200, height: 200),
        
        ElevatedButton(
          onPressed: _pickAndSave,
          child: Text('Pick & Save Image'),
        ),
      ],
    );
  }
}
```

## 🧪 Testing on Emulator

### 1. Start Your Emulator
```bash
flutter emulators --launch <emulator_id>
```

### 2. Run Your App
```bash
flutter run
```

### 3. Test Saving Images

**Option A: Use the Example Screen**
Navigate to `ImageSaveExampleScreen` (created in `lib/pages/home/widgets/image_save_example.dart`)

**Option B: Quick Test**
1. Pick an image from gallery or take a photo
2. Call `ImageSaver.saveImageFromFile(imageFile)`
3. Check the emulator gallery app to see saved image

### 4. Verify Saved Images in Emulator

**Method 1: Using Gallery App**
- Open the "Photos" or "Gallery" app on the emulator
- You should see your saved images

**Method 2: Using Device File Explorer**
1. In Android Studio: View → Tool Windows → Device File Explorer
2. Navigate to:
   - Gallery: `/storage/emulated/0/Pictures`
   - Downloads: `/storage/emulated/0/Download`

**Method 3: Using ADB**
```bash
adb shell ls /storage/emulated/0/Pictures
adb shell ls /storage/emulated/0/Download
```

## 📁 File Locations

### Android Emulator
- **Gallery**: `/storage/emulated/0/Pictures/`
- **Downloads**: `/storage/emulated/0/Download/`
- **App Documents**: `/data/data/com.yourapp/app_flutter/documents/`

### iOS Simulator
- **Photo Library**: Managed by iOS Photos app
- **App Documents**: Container-specific path

## 🔧 Troubleshooting

### Problem: Permission Denied
**Solution**:
1. Make sure permissions are in AndroidManifest.xml
2. Uninstall and reinstall the app
3. Grant permissions manually in emulator settings:
   - Settings → Apps → Your App → Permissions → Storage

### Problem: Image Not Showing in Gallery
**Solution**:
1. Wait a few seconds and refresh the gallery
2. Restart the gallery app
3. Check if file exists using Device File Explorer

### Problem: "Storage permission denied" toast
**Solution**:
```dart
// Open app settings to manually grant permission
await ImageSaver.openAppSettings();
```

### Problem: Package not found errors
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

## 🎯 Integration with Your App

### Add to Home Screen
In `lib/pages/home/home.dart`, add a button to test:
```dart
// Add this import at top
import 'widgets/image_save_example.dart';

// Add this button somewhere in your UI
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageSaveExampleScreen(),
      ),
    );
  },
  child: Text('Test Save Image'),
)
```

### Save Profile Photo
```dart
import '../../../helper/image_saver/image_saver.dart';

Future<void> saveProfilePhoto(File photo) async {
  await ImageSaver.saveImageToDocuments(
    photo,
    fileName: 'profile_photo.jpg',
    subDirectory: 'profile',
  );
}
```

### Save AI Generated Image
```dart
import 'dart:typed_data';
import '../../../helper/image_saver/image_saver.dart';

Future<void> saveAIImage(Uint8List imageBytes) async {
  await ImageSaver.saveImageFromBytes(
    imageBytes,
    fileName: 'ai_generated_${DateTime.now().millisecondsSinceEpoch}',
    quality: 100,
  );
}
```

## 📚 Full Documentation

For complete usage examples and advanced features, see:
- `lib/helper/image_saver/IMAGE_SAVER_USAGE.md`
- `lib/helper/image_saver/image_saver.dart`

## ✨ Features

✅ Automatic permission handling
✅ Multiple save locations (gallery, downloads, documents)
✅ Custom file naming
✅ Quality control
✅ Toast notifications
✅ Support for Android 13+ and older versions
✅ iOS support
✅ Error handling

## 🎉 You're All Set!

Run this command and start saving images:
```bash
flutter pub get
flutter run
```

The utility is ready to use in your emulator! 📱✨
