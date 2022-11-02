import 'package:flutter/material.dart';

class CircularLoaderWidget extends StatelessWidget {
  const CircularLoaderWidget({this.color, Key? key}) : super(key: key);
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: color ?? Theme.of(context).primaryColor,
      ),
    );
  }
}
