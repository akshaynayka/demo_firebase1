import 'dart:async';

import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({
    required this.clockInTime,
    Key? key,
  }) : super(key: key);
  final String clockInTime;

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Duration _duration = const Duration();
  Timer? _timer;

  @override
  void initState() {
    final now = DateTime.now();
    final difference =
        now.difference(DateTime.parse(widget.clockInTime)).inSeconds;
    _duration = Duration(seconds: difference);
    _startTimer();

    super.initState();
  }

  Widget _showTimer() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_duration.inHours);
    final minutes = twoDigits(_duration.inMinutes.remainder(60));
    final seconds = twoDigits(_duration.inSeconds.remainder(60));
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        '$hours : $minutes : $seconds',
        style: const TextStyle(
          fontSize: 20.0,
        ),
      ),
    );
  }

  void _startTimer() {
    // _reset();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _addTime());
  }

  // void _reset() {
  //   setState(() {
  //     _duration = const Duration();
  //   });
  // }

  void _addTime() {
    const addSecond = 1;

    setState(() {
      final seconds = _duration.inSeconds + addSecond;

      if (seconds < 0) {
        _timer?.cancel();
      } else {
        _duration = Duration(seconds: seconds);
      }
    });
  }

  void _stopTimer() {
    setState(() {
      _timer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _stopTimer();

          return true;
        },
        child: _showTimer());
  }
}
