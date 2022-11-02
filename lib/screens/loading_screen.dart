import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({this.flag, Key? key}) : super(key: key);
  final String? flag;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      body: Center(
          child:
              // Text(
              //   'Loading... ${flag ?? ''}',
              //   style: const TextStyle(
              //     color: Colors.white,
              //     fontSize: 25,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
              Image.asset('assets/images/loading_image.png')),
    );
  }
}
