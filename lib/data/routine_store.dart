import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'database.dart';
import 'exercise_catalog.dart';

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
  final List<Map<String, dynamic>> goals = [];
  final Set<String> favoriteExercises = <String>{};
  final List<String> exerciseHistory = <String>[];
  bool _loaded = false;

  Future<void> initialize() async {
    if (_loaded) return;
    final savedRoutines = await GymDatabase.instance.readCollection('routines');
    final savedHistory = await GymDatabase.instance.readCollection('workouts');
    final savedBodyLogs = await GymDatabase.instance.readCollection(
      'body_logs',
    );
    final savedGoals = await GymDatabase.instance.readCollection('goals');
    final savedFavorites = await GymDatabase.instance.readCollection(
      'favorites',
    );
    final savedExerciseHistory = await GymDatabase.instance.readCollection(
      'exercise_history',
    );
    if (savedRoutines.isNotEmpty) {
      routines
        ..clear()
        ..addAll(savedRoutines);
    }
    workoutHistory.addAll(savedHistory);
    bodyLogs.addAll(
      savedBodyLogs.map((log) {
        final image = log['imageBytes'];
        if (image is String) {
          return {...log, 'imageBytes': base64Decode(image)};
        }
        return log;
      }),
    );
    goals.addAll(savedGoals);
    favoriteExercises.addAll(
      savedFavorites.map((item) => item['name'] as String),
    );
    exerciseHistory.addAll(
      savedExerciseHistory.map((item) => item['name'] as String),
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> addWorkoutHistory(Map<String, dynamic> session) async {
    workoutHistory.insert(0, session);
    await _save('workouts', workoutHistory);
    notifyListeners();
  }

  Future<void> addBodyLog(Map<String, dynamic> log) async {
    bodyLogs.insert(0, log);
    await _save('body_logs', bodyLogs);
    notifyListeners();
  }

  Future<void> addGoal(Map<String, dynamic> goal) async {
    goals.insert(0, goal);
    await _save('goals', goals);
    notifyListeners();
  }

  Future<void> updateGoal(
    Map<String, dynamic> goal,
    Map<String, dynamic> updated,
  ) async {
    final index = goals.indexOf(goal);
    if (index < 0) return;
    goals[index] = updated;
    await _save('goals', goals);
    notifyListeners();
  }

  Future<void> resetGeneratedPlan() async {
    routines.clear();
    await _save('routines', routines);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    routines.clear();
    workoutHistory.clear();
    bodyLogs.clear();
    goals.clear();
    favoriteExercises.clear();
    exerciseHistory.clear();
    for (final key in [
      'routines',
      'workouts',
      'body_logs',
      'goals',
      'favorites',
      'exercise_history',
      'milestones',
      'planner',
      'cardio',
    ]) {
      await _save(key, const []);
    }
    notifyListeners();
  }

  Future<void> add(Map<String, dynamic> routine) async {
    routines.add(routine);
    await _save('routines', routines);
    notifyListeners();
  }

  Future<void> update(
    Map<String, dynamic> current,
    Map<String, dynamic> updated,
  ) async {
    final index = routines.indexOf(current);
    if (index < 0) return;
    routines[index] = updated;
    await _save('routines', routines);
    notifyListeners();
  }

  Future<void> remove(Map<String, dynamic> routine) async {
    routines.remove(routine);
    await _save('routines', routines);
    notifyListeners();
  }

  Future<void> toggleFavorite(String exercise) async {
    if (!favoriteExercises.add(exercise)) {
      favoriteExercises.remove(exercise);
    }
    await _save(
      'favorites',
      favoriteExercises.map((name) => {'name': name}).toList(),
    );
    notifyListeners();
  }

  Future<void> recordExerciseUse(String exercise) async {
    exerciseHistory.remove(exercise);
    exerciseHistory.insert(0, exercise);
    if (exerciseHistory.length > 30) {
      exerciseHistory.removeRange(30, exerciseHistory.length);
    }
    await _save(
      'exercise_history',
      exerciseHistory.map((name) => {'name': name}).toList(),
    );
    notifyListeners();
  }

  Future<void> _save(String key, List<Map<String, dynamic>> values) =>
      GymDatabase.instance.writeCollection(
        key,
        values.map(_encodeValue).toList(),
      );

  Map<String, dynamic> _encodeValue(Map<String, dynamic> value) {
    return value.map((key, item) {
      if (item is Uint8List) {
        return MapEntry(key, base64Encode(item));
      }
      if (item is DateTime) {
        return MapEntry(key, item.toIso8601String());
      }
      if (item is List<Uint8List>) {
        return MapEntry(key, item.map(base64Encode).toList());
      }
      return MapEntry(key, item);
    });
  }

  void applyOnboardingPlan({
    required String goal,
    required String equipment,
    required List<String> days,
    required List<String> muscles,
    required String experience,
    required int age,
    required double weight,
    required double height,
  }) {
    if (days.isEmpty || muscles.isEmpty) return;

    final available = ExerciseCatalog.all.where(
      (exercise) => _equipmentAllowed(exercise['equipment']!, equipment),
    );
    final selectedExercises = <Map<String, String>>[];
    for (final muscle in muscles) {
      final matches = available.where((exercise) {
        return exercise['muscle'] == muscle ||
            (muscle == 'Brazos' &&
                (exercise['muscle'] == 'Bíceps' ||
                    exercise['muscle'] == 'Tríceps'));
      });
      selectedExercises.addAll(matches.take(_exerciseCount(experience)));
    }
    if (selectedExercises.isEmpty) {
      selectedExercises.addAll(available.take(6));
    }

    final focus = muscles.take(2).join(' + ');
    final planName = switch (goal) {
      'Ganar músculo' => 'Hipertrofia',
      'Ganar fuerza' => 'Fuerza',
      'Perder grasa' => 'Quema activa',
      'Recomposición' => 'Recomposición',
      _ => 'Rendimiento',
    };
    final setsPerExercise = _setsPerExercise(
      goal: goal,
      experience: experience,
      age: age,
    );
    final reps = _repRange(goal);
    final restSeconds = _restSeconds(goal);
    final fatigueScore = _recentFatigueScore();
    final safeSetCount = fatigueScore >= 7
        ? (setsPerExercise - 1).clamp(2, 6)
        : setsPerExercise;
    final duration = goal == 'Perder grasa'
        ? '35 min'
        : '${40 + muscles.length * 5} min';
    final generated = days.indexed.map((entry) {
      final index = entry.$1;
      final day = entry.$2;
      final dayExercises = selectedExercises
          .skip(index % selectedExercises.length)
          .take(_exerciseCount(experience) + 1)
          .toList();
      return <String, dynamic>{
        'title': '$planName · $focus',
        'sets': safeSetCount * dayExercises.length,
        'exercises': dayExercises.length,
        'duration': duration,
        'status': 'Activas',
        'equipment': equipment,
        'muscleGroups': List<String>.from(muscles),
        'days': [day],
        'exerciseNames': dayExercises.map((item) => item['name']).toList(),
        'exerciseSettings': {
          for (final exercise in dayExercises)
            exercise['name']: {
              'sets': '$safeSetCount',
              'reps': reps,
              'weight': '0',
            },
        },
        'setsPerExercise': safeSetCount,
        'repRange': reps,
        'restSeconds': restSeconds,
        'recommendedWeight': _startingLoad(
          goal: goal,
          experience: experience,
          weight: weight,
          height: height,
        ),
        'progression': _progression(goal, experience),
        'recoveryDays': 7 - days.length,
        'fatigueScore': fatigueScore,
      };
    }).toList();

    routines
      ..clear()
      ..addAll(generated);
    _save('routines', routines);
    notifyListeners();
  }

  bool _equipmentAllowed(String exerciseEquipment, String selected) {
    if (selected == 'Gimnasio completo' || selected == 'Personalizado') {
      return true;
    }
    if (selected == 'Peso corporal') {
      return exerciseEquipment == 'Peso corporal';
    }
    if (selected == 'Casa') {
      return exerciseEquipment == 'Peso corporal' ||
          exerciseEquipment == 'Mancuernas' ||
          exerciseEquipment == 'Accesorio';
    }
    return exerciseEquipment != 'Máquina';
  }

  int _exerciseCount(String experience) => switch (experience) {
    'Principiante (< 1 año)' => 2,
    'Avanzado (> 3 años)' || 'Atleta de Élite' => 4,
    _ => 3,
  };

  int _setsPerExercise({
    required String goal,
    required String experience,
    required int age,
  }) {
    var sets = switch (goal) {
      'Ganar fuerza' => 4,
      'Ganar músculo' => 3,
      'Perder grasa' => 3,
      _ => 3,
    };
    if (experience == 'Principiante (< 1 año)') sets--;
    if (experience == 'Avanzado (> 3 años)' ||
        experience == 'Atleta de Élite') {
      sets++;
    }
    if (age >= 55) sets--;
    return sets.clamp(2, 5);
  }

  String _repRange(String goal) => switch (goal) {
    'Ganar fuerza' => '4-6',
    'Ganar músculo' => '8-12',
    'Perder grasa' => '10-15',
    _ => '8-12',
  };

  int _restSeconds(String goal) => goal == 'Ganar fuerza' ? 150 : 90;

  String _progression(String goal, String experience) {
    if (goal == 'Ganar fuerza') {
      return 'Aumenta 2.5 kg al completar todas las series';
    }
    if (experience == 'Principiante (< 1 año)') {
      return 'Aumenta 1-2 repeticiones antes de subir carga';
    }
    return 'Sube 2-5% cuando completes el rango superior';
  }

  String _startingLoad({
    required String goal,
    required String experience,
    required double weight,
    required double height,
  }) {
    final bodyIndex = weight / ((height / 100) * (height / 100));
    final factor = experience == 'Principiante (< 1 año)' ? .25 : .35;
    final modifier = bodyIndex > 30
        ? .9
        : bodyIndex < 18.5
        ? .85
        : 1.0;
    return '${(weight * factor * modifier).clamp(5, 60).toStringAsFixed(1)} kg iniciales orientativos';
  }

  int _recentFatigueScore() {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = workoutHistory.where((session) {
      final date = DateTime.tryParse(session['date']?.toString() ?? '');
      return date != null && date.isAfter(cutoff);
    });
    return recent
        .fold<int>(
          0,
          (total, session) =>
              total + ((session['sets'] as int?) ?? 0).clamp(0, 5),
        )
        .clamp(0, 10);
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
