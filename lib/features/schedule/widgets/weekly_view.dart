import 'package:flutter/material.dart';

class WeeklyView extends StatelessWidget {
  const WeeklyView({super.key});

  final List<String> weekDays = const [
    'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabeçalho com os dias da semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekDays
              .map((day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),

        // Blocos de horário (simples por enquanto)
        Expanded(
          child: ListView.builder(
            itemCount: 12, // Ex: 12 blocos horários (ex: das 8h às 20h)
            itemBuilder: (context, hourIndex) {
              return Row(
                children: List.generate(7, (dayIndex) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      height: 60,
                      color: Colors.grey[200],
                      child: Center(
                        child: Text('${8 + hourIndex}:00'),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }
}