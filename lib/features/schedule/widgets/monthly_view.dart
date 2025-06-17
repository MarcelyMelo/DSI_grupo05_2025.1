import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyView extends StatelessWidget {
  const MonthlyView({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final int daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final int startWeekday = firstDayOfMonth.weekday; // 1 = Monday

    // Criar uma lista de todos os dias do mês com offset antes do primeiro dia
    final List<DateTime?> calendarDays = List.generate(
      startWeekday - 1 + daysInMonth,
      (index) {
        if (index < startWeekday - 1) return null; // espaços vazios
        return DateTime(now.year, now.month, index - startWeekday + 2);
      },
    );

    return Column(
      children: [
        // Cabeçalho com os dias da semana
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'
          ].map((day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),

        // Grade do calendário
        Expanded(
          child: GridView.builder(
            itemCount: calendarDays.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final date = calendarDays[index];
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    date != null ? DateFormat.d().format(date) : '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
