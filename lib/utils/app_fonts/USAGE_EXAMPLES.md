# AppFonts Usage Guide

## Overview
The `AppFonts` class provides easy access to **Poppins** and **Inter** font families throughout your project. All methods use ScreenUtil for responsive sizing.

---

## Quick Start

### Import
```dart
import 'package:austin_small_talk/utils/app_fonts/app_fonts.dart';
```

---

## Usage Examples

### 1. Basic Text Styles

#### Poppins Font
```dart
// Poppins Regular
Text(
  'Hello World',
  style: AppFonts.poppinsRegular(fontSize: 16),
)

// Poppins Bold
Text(
  'Bold Title',
  style: AppFonts.poppinsBold(fontSize: 24, color: Colors.black),
)

// Poppins SemiBold
Text(
  'Subtitle',
  style: AppFonts.poppinsSemiBold(fontSize: 18, color: Colors.grey),
)

// Poppins Light
Text(
  'Light text',
  style: AppFonts.poppinsLight(fontSize: 14),
)
```

#### Inter Font
```dart
// Inter Regular
Text(
  'Body text',
  style: AppFonts.interRegular(fontSize: 14),
)

// Inter Bold
Text(
  'Bold heading',
  style: AppFonts.interBold(fontSize: 20, color: Colors.black),
)

// Inter Medium
Text(
  'Medium text',
  style: AppFonts.interMedium(fontSize: 16),
)
```

---

### 2. Advanced Parameters

```dart
// With custom color, height, and letter spacing
Text(
  'Styled text',
  style: AppFonts.poppinsSemiBold(
    fontSize: 18,
    color: Colors.blue,
    height: 1.5,
    letterSpacing: 0.5,
  ),
)

// With decoration (underline)
Text(
  'Underlined link',
  style: AppFonts.interRegular(
    fontSize: 14,
    color: Colors.blue,
    decoration: TextDecoration.underline,
  ),
)

// With italic style
Text(
  'Italic text',
  style: AppFonts.poppinsLight(
    fontSize: 14,
    fontStyle: FontStyle.italic,
  ),
)
```

---

### 3. All Available Font Weights

#### Poppins Weights
- `AppFonts.poppinsThin()` - Weight: 100
- `AppFonts.poppinsExtraLight()` - Weight: 200
- `AppFonts.poppinsLight()` - Weight: 300
- `AppFonts.poppinsRegular()` - Weight: 400 (default)
- `AppFonts.poppinsMedium()` - Weight: 500
- `AppFonts.poppinsSemiBold()` - Weight: 600
- `AppFonts.poppinsBold()` - Weight: 700
- `AppFonts.poppinsExtraBold()` - Weight: 800
- `AppFonts.poppinsBlack()` - Weight: 900

#### Inter Weights
- `AppFonts.interThin()` - Weight: 100
- `AppFonts.interExtraLight()` - Weight: 200
- `AppFonts.interLight()` - Weight: 300
- `AppFonts.interRegular()` - Weight: 400 (default)
- `AppFonts.interMedium()` - Weight: 500
- `AppFonts.interSemiBold()` - Weight: 600
- `AppFonts.interBold()` - Weight: 700
- `AppFonts.interExtraBold()` - Weight: 800
- `AppFonts.interBlack()` - Weight: 900

---

### 4. Using in Custom Widgets

#### In CustomButton
```dart
CustomButton(
  label: 'Continue',
  textStyle: AppFonts.poppinsBold(fontSize: 16, color: Colors.white),
  onPressed: () {},
)
```

#### In CustomTextField
```dart
CustomTextField(
  label: 'Email',
  hintText: 'name@example.com',
  // Label uses AppFonts.poppinsSemiBold by default
  // Input text uses AppFonts.poppinsRegular by default
)
```

#### In AppBar
```dart
AppBar(
  title: Text(
    'Screen Title',
    style: AppFonts.poppinsSemiBold(fontSize: 18, color: Colors.white),
  ),
)
```

---

### 5. Setting as Default App Font

The app already uses **Poppins** as the default font family (configured in `main.dart`):

```dart
ThemeData get _lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.poppinsTextTheme(), // Default: Poppins
);
```

To switch to **Inter** as default:
```dart
textTheme: GoogleFonts.interTextTheme(), // Default: Inter
```

---

### 6. Common UI Patterns

#### Heading + Body
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Welcome Back',
      style: AppFonts.poppinsBold(fontSize: 28, color: Colors.black),
    ),
    SizedBox(height: 8),
    Text(
      'Sign in to continue',
      style: AppFonts.poppinsRegular(fontSize: 14, color: Colors.grey),
    ),
  ],
)
```

#### Card with Title + Description
```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Title',
          style: AppFonts.poppinsSemiBold(fontSize: 18),
        ),
        SizedBox(height: 8),
        Text(
          'Card description goes here...',
          style: AppFonts.interRegular(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    ),
  ),
)
```

---

## Parameters Reference

All font methods accept these optional parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `fontSize` | `double` | `14` | Font size (will be converted to `.sp` automatically) |
| `color` | `Color?` | `null` | Text color |
| `height` | `double?` | `null` | Line height multiplier |
| `fontStyle` | `FontStyle?` | `null` | Italic or normal |
| `decoration` | `TextDecoration?` | `null` | Underline, lineThrough, etc. |
| `letterSpacing` | `double?` | `null` | Space between letters |

---

## Best Practices

1. **Use Poppins for UI elements** (buttons, headings, labels)
2. **Use Inter for body text** (paragraphs, descriptions)
3. **Prefer named weights** over numeric weights for clarity
4. **Let ScreenUtil handle sizing** - just pass the logical size
5. **Set defaults in theme** to minimize repetitive styling

---

## Notes

- All font sizes use **ScreenUtil** (`.sp`) for responsive sizing
- Fonts are loaded via **google_fonts** package (no manual font files needed)
- The app requires an internet connection on first launch to download fonts (cached afterward)
- Default font is set to **Poppins** in `main.dart`

---

## Support

For issues or questions, refer to:
- [Google Fonts Package](https://pub.dev/packages/google_fonts)
- [Flutter ScreenUtil](https://pub.dev/packages/flutter_screenutil)
