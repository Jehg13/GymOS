class ProgressAnalytics {
  const ProgressAnalytics._();

  static DateTime? dateOf(Map<String, dynamic> session) {
    final value = session['date'];
    if (value is DateTime) return value;
    final text = value?.toString() ?? '';
    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;
    final legacy = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(text);
    if (legacy == null) return null;
    return DateTime(
      int.parse(legacy.group(3)!),
      int.parse(legacy.group(2)!),
      int.parse(legacy.group(1)!),
    );
  }

  static List<Map<String, dynamic>> personalRecords(
    List<Map<String, dynamic>> history,
  ) {
    final records = <String, Map<String, dynamic>>{};
    for (final session in history) {
      final stats = session['exerciseStats'];
      if (stats is! List) continue;
      for (final raw in stats) {
        if (raw is! Map) continue;
        final name = raw['name']?.toString();
        final weight = (raw['weight'] as num?)?.toDouble() ?? 0;
        final reps = (raw['reps'] as num?)?.toInt() ?? 0;
        if (name == null || weight <= 0 || reps <= 0) continue;
        final oneRm = weight * (1 + reps / 30);
        final previous = records[name];
        if (previous == null || oneRm > (previous['oneRm'] as double)) {
          records[name] = {
            'name': name,
            'weight': weight,
            'reps': reps,
            'oneRm': oneRm,
          };
        }
      }
    }
    return records.values.toList()
      ..sort((a, b) => (b['oneRm'] as double).compareTo(a['oneRm'] as double));
  }

  static Map<String, double> volumeByMuscle(
    List<Map<String, dynamic>> history,
  ) {
    final result = <String, double>{};
    for (final session in history) {
      final volume = (session['volume'] as num?)?.toDouble() ?? 0;
      final groups = (session['muscleGroups'] as List<dynamic>? ?? const []);
      for (final group in groups) {
        final key = group.toString();
        result[key] = (result[key] ?? 0) + volume;
      }
    }
    return result;
  }

  static double movingAverage(
    List<Map<String, dynamic>> history, {
    int days = 7,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final recent = history.where((session) {
      final date = dateOf(session);
      return date != null && date.isAfter(cutoff);
    }).toList();
    if (recent.isEmpty) return 0;
    return recent.fold<double>(
          0,
          (sum, session) =>
              sum + ((session['volume'] as num?)?.toDouble() ?? 0),
        ) /
        days;
  }

  static Map<String, dynamic> consistency(List<Map<String, dynamic>> history) {
    final now = DateTime.now();
    final trainedDays = <String>{};
    for (final session in history) {
      final date = dateOf(session);
      if (date == null) continue;
      trainedDays.add('${date.year}-${date.month}-${date.day}');
    }
    final lastSeven = List.generate(
      7,
      (index) => '${now.year}-${now.month}-${now.day - index}',
    );
    final completed = lastSeven.where(trainedDays.contains).length;
    final lastDate = history.map(dateOf).whereType<DateTime>().fold<DateTime?>(
      null,
      (latest, date) {
        if (latest == null || date.isAfter(latest)) return date;
        return latest;
      },
    );
    final daysSince = lastDate == null ? 999 : now.difference(lastDate).inDays;
    return {
      'completed': completed,
      'percentage': completed / 7,
      'low': completed < 2 || daysSince > 7,
      'daysSince': daysSince,
    };
  }

  static List<String> balanceInsights(Map<String, double> volume) {
    if (volume.isEmpty) {
      return ['Completa sesiones para analizar tu equilibrio muscular.'];
    }
    final sorted = volume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final strongest = sorted.first;
    final weakest = sorted.last;
    if (strongest.value > weakest.value * 2.5) {
      return [
        '${strongest.key} concentra la mayor carga semanal.',
        'Añade trabajo progresivo de ${weakest.key} para equilibrar tu plan.',
      ];
    }
    return ['Tu distribución de volumen se mantiene equilibrada.'];
  }
}
