import 'package:flutter/material.dart';
import '../values/colors.dart';

class CounterCardWidget extends StatelessWidget {
  const CounterCardWidget({
    required this.titleText,
    required this.counterText,
    required this.icon,
    this.ontap,
    Key? key,
  }) : super(key: key);
  final String titleText;
  final int counterText;
  final IconData icon;

  final void Function()? ontap;

  String getInitials({required String string, int? limit}) {
    if (string.isNotEmpty) {
      final trim = string.trim();
      final split = trim.split(RegExp(' +'));
      final splitLength = split.length;
      final iterableList = split.map((data) {
        return data[0];
      });
      final result = iterableList.take(limit ?? splitLength).join();
      return result;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TooltipState> tooltipKey = GlobalKey<TooltipState>();

    final deviceSize = MediaQuery.of(context).size;
    final isWeb = deviceSize.width > 600;
    return LayoutBuilder(builder: (context, boxConstraints) {
      return InkWell(
        onTap: ontap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CounterAnimation(
                    begin: 0,
                    end: counterText,
                    curve: Curves.easeOut,
                    duration: 1,
                    textStyle: TextStyle(
                      fontSize: boxConstraints.maxHeight * 0.25,
                      fontWeight: FontWeight.w600,
                      color: appColorPrimarySwatch,
                    ),
                  ),
                  Icon(
                    icon,
                    size: boxConstraints.maxHeight * 0.38,
                  ),
                ],
              ),
              // const SizedBox(
              //   height: 10,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    getInitials(string: titleText),
                    // (boxConstraints.maxHeight * 0.112).toString(),

                    style: TextStyle(
                      color: appColorGreyDark,
                      fontWeight: FontWeight.w500,
                      fontSize: isWeb
                          ? boxConstraints.maxHeight * 0.10
                          : boxConstraints.maxHeight * 0.18,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Tooltip(
                    key: tooltipKey,
                    // height: 20,
                    message: titleText,

                    child: GestureDetector(
                      child: const Icon(
                        Icons.info_outline,
                      ),
                      // onLongPress: () {
                      //   tooltipKey.currentState?.ensureTooltipVisible();
                      // },
                      onTap: () {
                        tooltipKey.currentState?.ensureTooltipVisible();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class CounterAnimation extends StatefulWidget {
  const CounterAnimation({
    required this.begin,
    required this.end,
    required this.curve,
    required this.duration,
    required this.textStyle,
    Key? key,
  }) : super(key: key);
  final int begin; // The beginning of the int animation.
  final int end; // The the end of the int animation (result).
  final int duration; // The duration of the animation.
  final Curve curve; // The curve of the animation (recommended: easeOut).
  final TextStyle textStyle; // The TextStyle.

  @override
  State<CounterAnimation> createState() => _CounterAnimationState();
}

class _CounterAnimationState extends State<CounterAnimation>
    with SingleTickerProviderStateMixin {
  Animation? _animation;
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        duration: Duration(seconds: widget.duration), vsync: this);
    _animation = IntTween(begin: widget.begin, end: widget.end).animate(
        CurvedAnimation(parent: _animationController!, curve: widget.curve));
    _animationController!.forward();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CounterAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animation = IntTween(begin: widget.begin, end: widget.end).animate(
        CurvedAnimation(parent: _animationController!, curve: widget.curve));
    _animationController!.reset();
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController!,
        builder: (_, __) {
          return Text(_animation!.value.toString(), style: widget.textStyle);
        });
  }
}
