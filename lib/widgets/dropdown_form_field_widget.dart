import 'package:flutter/material.dart';

class DropdownButtonFormFieldWidget extends StatelessWidget {
  const DropdownButtonFormFieldWidget({
    this.lableText,
    this.labelColor,
    this.icon,
    this.iconColor,
    required this.items,
    required this.onChanged,
    this.onSaved,
    this.onTap,
    this.value,
    this.validator,
    this.readOnly = false,
    Key? key,
  }) : super(key: key);

  // final String? hintText;
  final String? lableText;
  final Color? labelColor;
  final IconData? icon;
  final Color? iconColor;
  final List<DropdownMenuItem<String>>? items;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final String? value;
  final String? Function(String?)? validator;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      // shape:  BorderRadius.circular(25.0),
      borderRadius: BorderRadius.circular(25.0),
      // borderRadius: BorderRadiusGeometry.lerp(a, b, t) BorderRadius.circular(25.0),
      shadowColor: Colors.grey,
      child: DropdownButtonFormField(
        iconEnabledColor: Theme.of(context).primaryColor,
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
        value: value,
        items: items,
        onChanged: readOnly ? null : onChanged,
        onSaved: readOnly ? null : onSaved,
        validator: readOnly ? null : validator,
        onTap: onTap,
      ),
    );
  }
}
