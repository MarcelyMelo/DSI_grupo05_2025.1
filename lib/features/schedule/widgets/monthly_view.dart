import 'package:flutter/material.dart';

class MonthlyView extends StatelessWidget {
  const MonthlyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Visualização Mensal',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}