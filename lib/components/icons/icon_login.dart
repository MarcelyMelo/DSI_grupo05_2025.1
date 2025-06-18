import 'package:flutter/material.dart';

class FocaIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const FocaIcon({
    super.key,
    this.size = 300.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/images/focado_icon.png',
      width: size,
      height: size,
      color: color,
      fit: BoxFit.contain,
    );
  }
}
