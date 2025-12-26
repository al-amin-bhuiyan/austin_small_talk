import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/app_colors/app_colors.dart';
import '../../utils/app_fonts/app_fonts.dart';

/// Reusable text field used across the app.
///
/// Features:
/// - Optional label and hint
/// - Controller and validator support
/// - Prefix/suffix widgets
/// - Obscure text (for passwords) with built-in toggle
/// - Customizable keyboardType, maxLines, readOnly, and textInputAction
/// - Built-in errorText display and focused/enabled border styling
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? textColor;
  final bool enabled;
  final String? errorText;

  const CustomTextField({
    Key? key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
    this.textInputAction,
    this.contentPadding,
    this.fillColor,
    this.textColor,
    this.enabled = true,
    this.errorText,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _errorText = widget.errorText;
  }

  void _toggleObscure() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  InputBorder _buildBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: color, width: 1.w),
      );

  @override
  Widget build(BuildContext context) {
    final fill = widget.fillColor ?? Colors.white;
    final txtColor = widget.textColor ?? Colors.black;

    // convert common opacity values to alpha ints
    const int alpha90 = 230; // ~0.9 * 255
    const int alpha12 = 31;  // ~0.12 * 255

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppFonts.poppinsSemiBold(
              fontSize: 14,
              color: AppColors.whiteColor.withAlpha(alpha90),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscure,
          maxLines: widget.maxLines,
          readOnly: widget.readOnly,
          onChanged: (v) {
            if (widget.validator != null) {
              final res = widget.validator!(v);
              setState(() {
                _errorText = res;
              });
            }
            if (widget.onChanged != null) widget.onChanged!(v);
          },
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          style: AppFonts.poppinsRegular(
            fontSize: 16,
            color: txtColor,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            filled: true,
            fillColor: fill,
            hintText: widget.hintText,
            hintStyle: AppFonts.poppinsRegular(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            prefixIcon: widget.prefix,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: _toggleObscure,
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      size: 18.sp,
                      color: AppColors.whiteColor.withAlpha(alpha90),
                    ),
                  )
                : widget.suffix,
            enabledBorder: _buildBorder(AppColors.whiteColor.withAlpha(alpha12)),
            focusedBorder: _buildBorder(AppColors.primaryColor),
            errorBorder: _buildBorder(Colors.redAccent),
            focusedErrorBorder: _buildBorder(Colors.redAccent),
            errorText: _errorText,
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}