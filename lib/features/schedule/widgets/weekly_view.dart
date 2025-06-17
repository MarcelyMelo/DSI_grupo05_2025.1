import 'package:flutter/material.dart';

class WeeklyView extends StatelessWidget {
  const WeeklyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Visualização Semanal',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}