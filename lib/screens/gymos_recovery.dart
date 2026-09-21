import 'package:flutter/material.dart';
import '../data/routine_store.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS Recovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const RecoveryScreen(),
    );
  }
}

// ==========================================
// TOKENS DE DISEÑO - GYMOS DESIGN SYSTEM
// ==========================================
abstract class GymOSTheme {
  static const Color bgMain = Color(0xFF08090C);
  static const Color surfaceBase = Color(0xFF151820);
  static const Color surfaceElevated = Color(0xFF1B1F28);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9B9FA8);

  // Paleta de Estado Analítico (Sin Verde)
  static const Color statusReciente = Color(0xFFFF6B1A); // Naranja Eléctrico
  static const Color statusNormal = Color(0xFF8B5CF6); // Violeta Eléctrico
  static const Color statusDescanso = Color(0xFF4B5563); // Gris Acero / Reposo
  static const Color textMuted = Color(0xFF374151);
}

// ==========================================
// PANTALLA PRINCIPAL: RECUPERACIÓN
// ==========================================
class RecoveryScreen extends StatelessWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      appBar: AppBar(
        backgroundColor: GymOSTheme.bgMain,
        elevation: 0,
        title: const Text(
          'Análisis de Recuperación',
          style: TextStyle(
            color: GymOSTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        leading: Navigator.canPop(context)
            ? const BackButton(color: GymOSTheme.textPrimary)
            : null,
      ),
      body: AnimatedBuilder(
        animation: RoutineStore.instance,
        builder: (context, _) => SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              24 + MediaQuery.of(context).viewPadding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // TARJETA DE PRÓXIMO DÍA DE DESCANSO
                _buildRestDayCard(),

                const SizedBox(height: 24),

                // LEYENDA DE ESTADOS DE RECUPERACIÓN
                const Text(
                  'ESTADO DE CARGA MUSCULAR',
                  style: TextStyle(
                    color: GymOSTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusLegend(),

                const SizedBox(height: 16),

                // MAPA ANALÍTICO DE GRUPOS MUSCULARES
                _buildMuscleMapList(),

                const SizedBox(height: 28),

                // CALENDARIO DE RECUPERACIÓN Y FATIGA
                const Text(
                  'CALENDARIO DE RECUPERACIÓN',
                  style: TextStyle(
                    color: GymOSTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecoveryCalendar(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestDayCard() {
    final history = RoutineStore.instance.workoutHistory;
    final recentSessions = history.where((session) {
      final date = DateTime.tryParse(session['date']?.toString() ?? '');
      return date != null &&
          date.isAfter(DateTime.now().subtract(const Duration(days: 7)));
    }).length;
    final shouldRest = recentSessions >= 4;
    final day = DateTime.now().add(Duration(days: shouldRest ? 1 : 2));
    const weekdays = [
      'LUNES',
      'MARTES',
      'MIÉRCOLES',
      'JUEVES',
      'VIERNES',
      'SÁBADO',
      'DOMINGO',
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GymOSTheme.statusNormal.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PRÓXIMO DÍA DE DESCANSO',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                weekdays[day.weekday - 1],
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: GymOSTheme.statusNormal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              shouldRest ? 'DESCANSO SUGERIDO' : 'RECUPERACIÓN ACTIVA',
              style: TextStyle(
                color: GymOSTheme.statusNormal,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Row(
      children: const [
        _LegendItem(color: GymOSTheme.statusReciente, label: 'Reciente'),
        SizedBox(width: 16),
        _LegendItem(color: GymOSTheme.statusNormal, label: 'Normal'),
        SizedBox(width: 16),
        _LegendItem(color: GymOSTheme.statusDescanso, label: 'Descanso'),
      ],
    );
  }

  Widget _buildMuscleMapList() {
    if (RoutineStore.instance.workoutHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: GymOSTheme.surfaceBase,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'Registra un entrenamiento para comenzar a analizar tu recuperación.',
          style: TextStyle(color: GymOSTheme.textSecondary),
        ),
      );
    }
    final latestByMuscle = <String, DateTime>{};
    for (final session in RoutineStore.instance.workoutHistory) {
      final date = DateTime.tryParse(session['date']?.toString() ?? '');
      if (date == null) continue;
      for (final group in (session['muscleGroups'] as List? ?? const [])) {
        final muscle = group.toString().toUpperCase();
        if (!latestByMuscle.containsKey(muscle) ||
            date.isAfter(latestByMuscle[muscle]!)) {
          latestByMuscle[muscle] = date;
        }
      }
    }
    final muscleMap = latestByMuscle.entries.map((entry) {
      final days = DateTime.now().difference(entry.value).inDays;
      final status = days <= 1
          ? 'Reciente'
          : days <= 3
          ? 'Normal'
          : 'Descanso';
      return {
        'muscle': entry.key,
        'lastTrained': '${entry.value.day}/${entry.value.month}',
        'status': status,
        'color': status == 'Reciente'
            ? GymOSTheme.statusReciente
            : status == 'Normal'
            ? GymOSTheme.statusNormal
            : GymOSTheme.statusDescanso,
      };
    }).toList();

    return Column(
      children: muscleMap.map((item) {
        final statusColor = item['color'] as Color;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GymOSTheme.surfaceBase,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['muscle'].toString(),
                        style: const TextStyle(
                          color: GymOSTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Último entrenamiento: ${item['lastTrained']}',
                        style: const TextStyle(
                          color: GymOSTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item['status'].toString().toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecoveryCalendar() {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final today = DateTime.now();
    final days = List.generate(7, (index) {
      final date = today.subtract(Duration(days: 6 - index));
      final trained = RoutineStore.instance.workoutHistory.any((session) {
        final sessionDate = DateTime.tryParse(
          session['date']?.toString() ?? '',
        );
        return sessionDate != null &&
            sessionDate.year == date.year &&
            sessionDate.month == date.month &&
            sessionDate.day == date.day;
      });
      return {
        'day': labels[date.weekday - 1],
        'date': '${date.day}',
        'color': trained
            ? GymOSTheme.statusReciente
            : GymOSTheme.statusDescanso,
      };
    });

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days.map((d) {
          final color = d['color'] as Color;
          return Column(
            children: [
              Text(
                d['day'].toString(),
                style: const TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: GymOSTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    d['date']!.toString(),
                    style: TextStyle(
                      color: color == GymOSTheme.statusDescanso
                          ? GymOSTheme.textSecondary
                          : GymOSTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: GymOSTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
