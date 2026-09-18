import 'package:flutter/material.dart';

import '../data/routine_store.dart';
import 'gymos_strength_level.dart';

class MuscleStrengthRangesScreen extends StatelessWidget {
  const MuscleStrengthRangesScreen({super.key});

  static const _references = <String, double>{
    'Pecho': 80,
    'Espalda': 100,
    'Piernas': 120,
    'Hombros': 45,
    'Bíceps': 22,
    'Tríceps': 30,
    'Glúteos': 100,
    'Core': 35,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoutineStore.instance,
      builder: (context, _) {
        final levels = _muscleLevels();
        return Scaffold(
          backgroundColor: GymOSTheme.bgMain,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Volver',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            ),
            title: const Text(
              'Nivel por músculo',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.paddingOf(context).bottom + 30,
            ),
            children: [
              _introCard(),
              const SizedBox(height: 22),
              const Text(
                'RANGOS DE FUERZA',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              ...levels.map(_rangeCard),
              const SizedBox(height: 18),
              _disclaimer(),
            ],
          ),
        );
      },
    );
  }

  List<_MuscleLevel> _muscleLevels() {
    final best = <String, double>{};
    for (final routine in RoutineStore.instance.routines) {
      final groups = (routine['muscleGroups'] as List<dynamic>? ?? const [])
          .map((value) => value.toString());
      final settings = routine['exerciseSettings'] as Map<dynamic, dynamic>?;
      if (settings == null) continue;
      var routineWeight = 0.0;
      for (final value in settings.values) {
        final map = value as Map<dynamic, dynamic>;
        routineWeight =
            routineWeight > (double.tryParse('${map['weight']}') ?? 0)
            ? routineWeight
            : (double.tryParse('${map['weight']}') ?? 0);
      }
      for (final group in groups) {
        best[group] = (best[group] ?? 0) > routineWeight
            ? best[group]!
            : routineWeight;
      }
    }
    return _references.keys
        .map(
          (muscle) => _MuscleLevel(
            muscle: muscle,
            weight: best[muscle] ?? 0,
            reference: _references[muscle]!,
          ),
        )
        .toList();
  }

  Widget _introCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF122B3A), Color(0xFF151820)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFF39D9FF).withValues(alpha: .3)),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.analytics_rounded, color: Color(0xFF39D9FF), size: 30),
        SizedBox(height: 14),
        Text(
          'Conoce dónde estás fuerte',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'Comparamos tu mejor peso configurado con referencias generales por grupo muscular.',
          style: TextStyle(color: Color(0xFFAAB4C5), height: 1.4),
        ),
      ],
    ),
  );

  Widget _rangeCard(_MuscleLevel item) {
    final hasData = item.weight > 0;
    final ratio = hasData
        ? (item.weight / item.reference).clamp(0.0, 1.0)
        : 0.0;
    final level = !hasData
        ? 'Sin registro'
        : ratio < .4
        ? 'Inicial'
        : ratio < .7
        ? 'Base'
        : ratio < 1
        ? 'Intermedio'
        : 'Avanzado';
    final color = !hasData
        ? GymOSTheme.textMuted
        : ratio >= 1
        ? const Color(0xFFFFB84D)
        : const Color(0xFF39D9FF);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center_rounded, color: color, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.muscle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                hasData ? '${item.weight.toStringAsFixed(1)} kg' : '--',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              Text(
                level,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.white.withValues(alpha: .07),
            valueColor: AlwaysStoppedAnimation(color),
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              hasData
                  ? 'Referencia orientativa: ${item.reference.toStringAsFixed(0)} kg'
                  : 'Añade peso en una rutina para analizarlo',
              style: const TextStyle(
                color: GymOSTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _disclaimer() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF9B7CFF).withValues(alpha: .1),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFF9B7CFF).withValues(alpha: .25)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, color: Color(0xFF9B7CFF), size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Estos rangos son referencias educativas y dependen del ejercicio, técnica, repeticiones, sexo, peso corporal y experiencia. No son una clasificación médica ni sustituyen la evaluación de un entrenador.',
            style: TextStyle(
              color: Color(0xFFAAB4C5),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

class _MuscleLevel {
  const _MuscleLevel({
    required this.muscle,
    required this.weight,
    required this.reference,
  });

  final String muscle;
  final double weight;
  final double reference;
}
