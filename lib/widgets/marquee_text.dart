import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

/// Wrapper around the `marquee` package so the rest of the app
/// can keep using `MarqueeText`.
class MarqueeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double gap;
  final Duration duration;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.gap = 32,
    this.duration = const Duration(seconds: 15),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (style?.fontSize ?? DefaultTextStyle.of(context).style.fontSize ?? 14) * 1.6,
      width: double.infinity,
      child: Marquee(
        text: text,
        style: style,
        scrollAxis: Axis.horizontal,
        blankSpace: gap,
        velocity: (MediaQuery.of(context).size.width + text.length * (style?.fontSize ?? 14) / 2) /
            duration.inSeconds,
        startPadding: 0,
        pauseAfterRound: Duration.zero,
      ),
    );
  }
}
