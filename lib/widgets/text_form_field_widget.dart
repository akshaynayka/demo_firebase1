import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget({
    // this.hintText,
    this.readOnly = false,
    this.obscureText = false,
    this.onTap,
    this.icon,
    this.iconColor,
    this.onSaved,
    this.initialValue,
    this.textInputAction,
    this.lableText,
    this.labelColor,
    this.controller,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofocus = false,
    Key? key,
  }) : super(key: key);

  // final String? hintText;
  final String? lableText;

  final IconData? icon;
  final Color? iconColor;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool? obscureText;
  final bool readOnly;
  final void Function()? onTap;
  final Color? labelColor;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;
  final bool? autofocus;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      // shape:  BorderRadius.circular(25.0),
      borderRadius: BorderRadius.circular(25.0),
      // borderRadius: BorderRadiusGeometry.lerp(a, b, t) BorderRadius.circular(25.0),
      shadowColor: Colors.grey,
      child: TextFormField(
        style: const TextStyle(
          color: Colors.grey,
        ),
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
          labelText: lableText,
          // hintText: hintText,

          labelStyle: TextStyle(
            color: labelColor ?? Colors.grey,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              icon,
              size: 25,
              color: iconColor ?? Colors.grey,
            ),
          ),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 0.1,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey,
              width: 0.1,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          // errorBorder: OutlineInputBorder(
          //   borderSide: const BorderSide(
          //     color: Colors.red,
          //     width: 1.5,
          //   ),
          //   borderRadius: BorderRadius.circular(25.0),
          // ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 0.1,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        onSaved: onSaved,
        obscureText: obscureText!,
        initialValue: initialValue,
        validator: validator,
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        autofocus: autofocus!,
      ),
    );
  }
}
