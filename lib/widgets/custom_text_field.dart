import 'package:flutter/material.dart';
import 'package:leadmanagementsystem/constants/constants.dart';

class CustomTextField extends StatefulWidget {
  String? hint;
  IconData? prefixIcon;
  IconData? suffix;

  bool isRequiredField;
  Color? prefixColor;
  bool? obscureText;
  TextEditingController? controller;
  Function(String)? onChanged;
  String? Function(String?)? onValidate;
  Function()? suffixOnTap;
  TextInputType? inputType;
  int? maxLines;
  bool? isEnabled;
  final List<String>? autofillHints;
  double? allSidesPadding;

  CustomTextField(
      {super.key,
      this.hint,
      this.prefixIcon,
      this.suffix,
      this.onChanged,
      this.isRequiredField = false,
      this.controller,
      this.suffixOnTap,
      this.maxLines,
      this.isEnabled,
      this.prefixColor,
      this.onValidate,
      this.inputType = TextInputType.text,
      this.autofillHints,
      this.allSidesPadding,
      this.obscureText = false});

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  initState() {
    super.initState();
    widget.maxLines ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(widget.allSidesPadding ?? 8),
          child: TextFormField(
            autofillHints: widget.autofillHints,
            enabled: widget.isEnabled,
            keyboardType: widget.inputType,
            maxLines: widget.maxLines ?? 1,
            minLines: widget.maxLines ?? 1,
            onChanged: widget.onChanged,
            controller: widget.controller,
            obscureText: widget.obscureText!,
            validator: widget.onValidate,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.isEnabled == false
                  ? const Color(0xFFF3F4F6)
                  : Colors.white,
              suffixIconColor: widget.controller != null &&
                      widget.controller!.text.isNotEmpty
                  ? appColor
                  : const Color(0xFF9CA3AF),
              prefixIconColor: widget.controller != null &&
                      widget.controller!.text.isNotEmpty
                  ? appColor
                  : const Color(0xFF9CA3AF),
              suffixIcon: widget.suffix == null
                  ? null
                  : InkWell(
                      onTap: widget.suffixOnTap,
                      child: Icon(widget.suffix)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: appColor, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: widget.prefixColor,
                    ),
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          ),
        ),
        widget.isRequiredField == true
            ? const Positioned(
                right: 0,
                top: 0,
                child: Text('*',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
              )
            : const SizedBox.shrink()
      ],
    );
  }
}
