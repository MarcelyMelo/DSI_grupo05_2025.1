import 'package:flutter/material.dart';

class FocaIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const FocaIcon({
    Key? key,
    this.size = 300.0,
    this.color,
  }) : super(key: key);

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
