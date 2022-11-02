import '../widgets/stream_counter_text_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StreamCounterBadgeWidget extends StatelessWidget {
  const StreamCounterBadgeWidget({required this.stream,Key? key}) : super(key: key);
  final Stream<QuerySnapshot<Map<String, dynamic>>>? stream;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  const EdgeInsets.all(1),
      decoration:   BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      constraints: const BoxConstraints(
        minWidth: 12,
        minHeight: 12,
      ),
      child: StreamCounterTextWidget(
        stream: stream,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
        ),
      ),
    );
  }
}
