import '../widgets/counter_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TileWidget extends StatelessWidget {
  final String text;
  final int count;
  final double size;
  const TileWidget({
    required this.size,
    required this.text,
    required this.count,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: size,
      animation: true,
      animationDuration: 1000,
      lineWidth: 10.0,
      percent: 1,
      header: Text(
        text,
        style: const TextStyle(fontSize: 25.0),
      ),
      center: CounterAnimationWidget(
        begin: 0,
        end: count,
        duration: 1,
        curve: Curves.easeOut,
        textStyle: const TextStyle(
          fontSize: 30.0,
          fontWeight: FontWeight.w600,
        ),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Theme.of(context).primaryColor,
    );
  }
}
