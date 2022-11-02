import '../widgets/circular_loader_widget.dart';

import '../values/colors.dart';
import 'package:flutter/material.dart';

class RoundButtonWidget extends StatelessWidget {
  const RoundButtonWidget({
    required this.label,
    this.width,
    this.height,
    required this.onPressed,
    this.isProccess = false,
    Key? key,
  }) : super(key: key);
  final String label;
  final void Function()? onPressed;
  final double? width;
  final double? height;
  final bool isProccess;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: <Color>[
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor,
            // appColorSecondGradient,
          ],
        ),
      ),
      height: height ?? 50.0,
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
        ),
        onPressed: !isProccess ? onPressed : null,
        child: !isProccess
            ? Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                ),
              )
            : const CircularLoaderWidget(color: buttonTextColor),
      ),
    );
  }
}
