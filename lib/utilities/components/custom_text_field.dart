import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Widget? prefixIcon;
  final IconButton? suffixIcon;
  final bool isObscure;
  final double? corner;
  final Function(String)? onChange;
  final FormFieldSetter<String>? onSaved;
  final Function()? onTap;
  final bool? readOnly;
  final bool? hasBG;
  final int? maxLine;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    required this.isObscure,
    this.onChange,
    this.onTap,
    this.readOnly,
    this.corner,
    this.focusNode,
    this.maxLine,
    this.onSaved,
    this.validator, this.hasBG,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      onChanged: onChange,
      focusNode: focusNode,
      maxLines: maxLine ?? 1,
      keyboardType: keyboardType ?? TextInputType.text,
      onTap: onTap,
      cursorColor: Colors.grey,
      onSaved: onSaved,
      readOnly: readOnly ?? false,
      validator: validator,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(corner ?? 10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.circular(corner ?? 10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(corner ?? 10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        fillColor: Colors.grey.withOpacity(0.08),
        filled: hasBG ?? true,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.only(left: 15, right: 5),
      ),
    );
  }
}