import '../widgets/circular_loader_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StreamCounterTextWidget extends StatelessWidget {
  const StreamCounterTextWidget({required this.stream, this.style, Key? key})
      : super(key: key);
  final Stream<QuerySnapshot<Map<String, dynamic>>>? stream;

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        final listLength = snapshot.data?.docs.length;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularLoaderWidget();
        }
        return Text(
          listLength.toString(),
          style: style,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
