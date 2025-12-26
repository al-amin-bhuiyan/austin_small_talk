import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Project-wide font styles using Poppins and Inter fonts.
///
/// Usage:
/// - Text('Hello', style: AppFonts.poppinsBold(fontSize: 24, color: Colors.black))
/// - Text('World', style: AppFonts.interRegular(fontSize: 14))
///
/// All methods use ScreenUtil (.sp) for responsive sizing.
class AppFonts {
  AppFonts._();

  // ==================== POPPINS FONT FAMILY ====================

  /// Poppins Thin (weight: 100)
  static TextStyle poppinsThin({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w100,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Poppins ExtraLight (weight: 200)
  static TextStyle poppinsExtraLight({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w200,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Poppins Light (weight: 300)
  static TextStyle poppinsLight({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w300,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Poppins Regular (weight: 400)
  static TextStyle poppinsRegular({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Poppins Medium (weight: 500)
  static TextStyle poppinsMedium({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w500,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Poppins SemiBold (weight: 600)
  static TextStyle poppinsSemiBold({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w600,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Poppins Bold (weight: 700)
  static TextStyle poppinsBold({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Poppins ExtraBold (weight: 800)
  static TextStyle poppinsExtraBold({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w800,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Poppins Black (weight: 900)
  static TextStyle poppinsBlack({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.poppins(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w900,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  // ==================== INTER FONT FAMILY ====================

  /// Inter Thin (weight: 100)
  static TextStyle interThin({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w100,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Inter ExtraLight (weight: 200)
  static TextStyle interExtraLight({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w200,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Inter Light (weight: 300)
  static TextStyle interLight({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w300,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Inter Regular (weight: 400)
  static TextStyle interRegular({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Inter Medium (weight: 500)
  static TextStyle interMedium({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w500,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Inter SemiBold (weight: 600)
  static TextStyle interSemiBold({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w600,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Inter Bold (weight: 700)
  static TextStyle interBold({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Inter ExtraBold (weight: 800)
  static TextStyle interExtraBold({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w800,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  /// Inter Black (weight: 900)
  static TextStyle interBlack({
    double fontSize = 14,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w900,
        color: color,
        height: height,
        fontStyle: fontStyle,
        decoration: decoration,
        letterSpacing: letterSpacing,
      );

  // ==================== CONVENIENCE METHODS ====================

  /// Get Poppins TextTheme for the entire app
  static TextTheme poppinsTextTheme() => GoogleFonts.poppinsTextTheme();

  /// Get Inter TextTheme for the entire app
  static TextTheme interTextTheme() => GoogleFonts.interTextTheme();
}
