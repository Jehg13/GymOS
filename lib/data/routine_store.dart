import 'package:flutter/foundation.dart';

class RoutineStore extends ChangeNotifier {
  RoutineStore._();

  static final RoutineStore instance = RoutineStore._();

  final List<Map<String, dynamic>> routines = [
    {
      'title': 'Pecho + Tríceps',
      'sets': 18,
      'exercises': 5,
      'duration': '45 min',
      'status': 'Activas',
      'days': ['Lun'],
    },
    {
      'title': 'Espalda + Bíceps',
      'sets': 20,
      'exercises': 6,
      'duration': '52 min',
      'status': 'Activas',
      'days': ['Mié'],
    },
    {
      'title': 'Piernas',
      'sets': 22,
      'exercises': 6,
      'duration': '65 min',
      'status': 'Activas',
      'days': ['Vie'],
    },
  ];

  final List<Map<String, dynamic>> workoutHistory = [];
  final List<Map<String, dynamic>> bodyLogs = [];

  void addWorkoutHistory(Map<String, dynamic> session) {
    workoutHistory.insert(0, session);
    notifyListeners();
  }

  void addBodyLog(Map<String, dynamic> log) {
    bodyLogs.insert(0, log);
    notifyListeners();
  }

  void add(Map<String, dynamic> routine) {
    routines.add(routine);
    notifyListeners();
  }

  void update(Map<String, dynamic> current, Map<String, dynamic> updated) {
    final index = routines.indexOf(current);
    if (index < 0) return;
    routines[index] = updated;
    notifyListeners();
  }

  void remove(Map<String, dynamic> routine) {
    routines.remove(routine);
    notifyListeners();
  }

  void applyOnboardingPlan({
    required String goal,
    required String equipment,
    required List<String> days,
    required List<String> muscles,
  }) {
    if (days.isEmpty || muscles.isEmpty) return;

    final focus = muscles.take(2).join(' + ');
    final planName = switch (goal) {
      'Ganar músculo' => 'Hipertrofia',
      'Ganar fuerza' => 'Fuerza',
      'Perder grasa' => 'Quema activa',
      'Recomposición' => 'Recomposición',
      _ => 'Rendimiento',
    };
    final duration = goal == 'Perder grasa' ? '35 min' : '45 min';
    final generated = days.indexed.map((entry) {
      final index = entry.$1;
      final day = entry.$2;
      return <String, dynamic>{
        'title': '$planName · $focus',
        'sets': 12 + (index * 2),
        'exercises': muscles.length.clamp(3, 6),
        'duration': duration,
        'status': 'Activas',
        'equipment': equipment,
        'muscleGroups': List<String>.from(muscles),
        'days': [day],
      };
    }).toList();

    routines
      ..clear()
      ..addAll(generated);
    notifyListeners();
  }

  List<Map<String, dynamic>> forDay(String day) {
    return routines
        .where(
          (routine) =>
              (routine['days'] as List<dynamic>? ?? const []).contains(day),
        )
        .toList();
  }
}
