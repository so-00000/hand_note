import 'package:flutter/material.dart';

class StatusColorCircle extends StatelessWidget {
  final Color color;

  const StatusColorCircle({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
