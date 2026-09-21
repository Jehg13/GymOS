import 'package:flutter_test/flutter_test.dart';
import 'package:gym_os/data/progress_analytics.dart';

void main() {
  test('calcula récords personales y 1RM estimado', () {
    final records = ProgressAnalytics.personalRecords([
      {
        'date': '2026-09-20T08:00:00.000',
        'exerciseStats': [
          {'name': 'Press banca', 'weight': 80, 'reps': 8},
          {'name': 'Press banca', 'weight': 82.5, 'reps': 6},
        ],
      },
    ]);

    expect(records, hasLength(1));
    expect(records.single['name'], 'Press banca');
    expect(records.single['oneRm'], closeTo(101.3, .1));
  });

  test('distribuye volumen por músculo y detecta desequilibrio', () {
    final history = [
      {
        'volume': 1000,
        'muscleGroups': ['Pecho', 'Tríceps'],
      },
      {
        'volume': 200,
        'muscleGroups': ['Piernas'],
      },
    ];

    final volume = ProgressAnalytics.volumeByMuscle(history);
    expect(volume['Pecho'], 1000);
    expect(volume['Tríceps'], 1000);
    expect(volume['Piernas'], 200);
    expect(
      ProgressAnalytics.balanceInsights(volume),
      contains('Pecho concentra la mayor carga semanal.'),
    );
  });

  test('acepta fechas históricas en formato local', () {
    final date = ProgressAnalytics.dateOf({'date': '21/09/2026'});

    expect(date, DateTime(2026, 9, 21));
  });
}
