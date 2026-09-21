import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../data/progress_analytics.dart';
import '../data/routine_store.dart';
import 'gymos_achievements.dart';
import 'gymos_body_evolution.dart';
import 'gymos_workout_history.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS Progress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const ProgressScreen(),
    );
  }
}

// ==========================================
// TOKENS DE DISEÑO - GYMOS DESIGN SYSTEM
// ==========================================
abstract class GymOSTheme {
  static const Color bgMain = Color(0xFF070A12);
  static const Color surfaceBase = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF182235);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFAAB4C5);

  // Paleta estricta de color
  static const Color orangeElectric = Color(0xFFFF7A1A);
  static const Color violetElectric = Color(0xFF9B7CFF);
  static const Color cyanElectric = Color(0xFF39D9FF);
  static const Color textMuted = Color(0xFF536176);
}

// ==========================================
// PANTALLA PRINCIPAL DE PROGRESO
// ==========================================
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String _selectedTimeframe = 'Mes';
  final List<String> _timeframes = ['Semana', 'Mes', '3 meses', 'Año', 'Todo'];

  Widget _buildPerformanceAnalysis(
    List<Map<String, dynamic>> history,
    Map<String, double> volumeByMuscle,
  ) {
    final records = ProgressAnalytics.personalRecords(history);
    final consistency = ProgressAnalytics.consistency(history);
    final average = ProgressAnalytics.movingAverage(history);
    final insights = ProgressAnalytics.balanceInsights(volumeByMuscle);
    final currentVolume = history
        .where((session) {
          final date = ProgressAnalytics.dateOf(session);
          return date != null &&
              date.isAfter(DateTime.now().subtract(const Duration(days: 30)));
        })
        .fold<double>(
          0,
          (sum, session) =>
              sum + ((session['volume'] as num?)?.toDouble() ?? 0),
        );
    final previousVolume = history
        .where((session) {
          final date = ProgressAnalytics.dateOf(session);
          final now = DateTime.now();
          return date != null &&
              date.isBefore(now.subtract(const Duration(days: 30))) &&
              date.isAfter(now.subtract(const Duration(days: 60)));
        })
        .fold<double>(
          0,
          (sum, session) =>
              sum + ((session['volume'] as num?)?.toDouble() ?? 0),
        );
    final change = previousVolume == 0
        ? 0
        : ((currentVolume - previousVolume) / previousVolume) * 100;
    final bodyWeight = RoutineStore.instance.bodyLogs.isEmpty
        ? null
        : (RoutineStore.instance.bodyLogs.first['weight'] as num?)?.toDouble();
    final best = records.isEmpty ? null : records.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ANÁLISIS DE RENDIMIENTO',
          style: TextStyle(
            color: GymOSTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GymOSTheme.surfaceBase,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GymOSTheme.cyanElectric.withValues(alpha: .2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AnalysisMetric(
                      label: 'MEJOR 1RM',
                      value: best == null
                          ? '--'
                          : '${(best['oneRm'] as double).toStringAsFixed(1)} kg',
                      caption: best?['name'] as String? ?? 'Sin registros',
                      color: GymOSTheme.orangeElectric,
                    ),
                  ),
                  Expanded(
                    child: _AnalysisMetric(
                      label: 'MEDIA 7 DÍAS',
                      value: '${average.toStringAsFixed(0)} kg',
                      caption: 'volumen diario',
                      color: GymOSTheme.cyanElectric,
                    ),
                  ),
                ],
              ),
              const Divider(height: 26, color: GymOSTheme.surfaceElevated),
              Row(
                children: [
                  Expanded(
                    child: _AnalysisMetric(
                      label: 'CAMBIO MENSUAL',
                      value:
                          '${change >= 0 ? '+' : ''}${change.toStringAsFixed(0)}%',
                      caption: 'volumen vs. mes anterior',
                      color: change >= 0
                          ? const Color(0xFF36D399)
                          : const Color(0xFFFF7A8A),
                    ),
                  ),
                  Expanded(
                    child: _AnalysisMetric(
                      label: 'PESO CORPORAL',
                      value: bodyWeight == null
                          ? '--'
                          : '${bodyWeight.toStringAsFixed(1)} kg',
                      caption: 'último registro',
                      color: GymOSTheme.violetElectric,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _AnalysisAlert(
                icon: consistency['low'] as bool
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_rounded,
                color: consistency['low'] as bool
                    ? const Color(0xFFFFB347)
                    : const Color(0xFF36D399),
                text: consistency['low'] as bool
                    ? 'Baja consistencia: llevas ${consistency['daysSince']} días sin una sesión reciente.'
                    : '${consistency['completed']} de 7 días activos esta semana. Mantén el ritmo.',
              ),
              const SizedBox(height: 10),
              ...insights.map(
                (insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: _AnalysisAlert(
                    icon: Icons.balance_rounded,
                    color: GymOSTheme.violetElectric,
                    text: insight,
                  ),
                ),
              ),
              if (records.isEmpty)
                const _AnalysisAlert(
                  icon: Icons.info_outline_rounded,
                  color: GymOSTheme.textSecondary,
                  text: 'Completa series con peso para calcular récords y 1RM.',
                )
              else if (records.length == 1)
                const _AnalysisAlert(
                  icon: Icons.trending_flat_rounded,
                  color: GymOSTheme.cyanElectric,
                  text:
                      'Aún hay pocos datos para detectar estancamientos con precisión.',
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildMuscleVolumeCard(volumeByMuscle),
        if (records.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildRecordsCard(records),
        ],
      ],
    );
  }

  Widget _buildMuscleVolumeCard(Map<String, double> volume) {
    final entries = volume.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return _analysisCard(
      title: 'VOLUMEN POR MÚSCULO',
      child: entries.isEmpty
          ? const Text(
              'Todavía no hay volumen distribuido por músculo.',
              style: TextStyle(color: GymOSTheme.textSecondary, fontSize: 12),
            )
          : Column(
              children: entries.take(6).map((entry) {
                final max = entries.first.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 78,
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            color: GymOSTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: max == 0 ? 0 : entry.value / max,
                            minHeight: 7,
                            backgroundColor: GymOSTheme.surfaceElevated,
                            valueColor: const AlwaysStoppedAnimation(
                              GymOSTheme.violetElectric,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        '${entry.value.toStringAsFixed(0)} kg',
                        style: const TextStyle(
                          color: GymOSTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildRecordsCard(List<Map<String, dynamic>> records) {
    return _analysisCard(
      title: 'RÉCORDS PERSONALES · 1RM ESTIMADO',
      child: Column(
        children: records.take(5).map((record) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: GymOSTheme.orangeElectric,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '${record['name']} · ${record['weight']} kg × ${record['reps']}',
                    style: const TextStyle(
                      color: GymOSTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${(record['oneRm'] as double).toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    color: GymOSTheme.orangeElectric,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _analysisCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildProgressHero(int sessions, int minutes, int sets) {
    final completion = (sessions / 5).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B1A), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: GymOSTheme.orangeElectric.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'TU RENDIMIENTO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              const Spacer(),
              Text(
                _selectedTimeframe.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            sessions == 0
                ? 'Tu progreso comienza hoy'
                : '$sessions sesiones completadas',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sessions == 0
                ? 'Completa tu primer entrenamiento para empezar a ver tendencias.'
                : '$minutes minutos · $sets series registradas',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completion,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(completion * 100).round()}% de tu meta semanal',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(int sessions, int minutes) {
    final message = sessions == 0
        ? 'Completa una sesión para que GymOS pueda analizar tu rendimiento.'
        : minutes >= 180
        ? 'Excelente volumen de entrenamiento. No olvides priorizar la recuperación.'
        : 'Vas construyendo consistencia. Intenta completar otra sesión esta semana.';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D2540), GymOSTheme.surfaceElevated],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GymOSTheme.violetElectric.withValues(alpha: 0.38),
        ),
        boxShadow: [
          BoxShadow(
            color: GymOSTheme.violetElectric.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: GymOSTheme.violetElectric,
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INSIGHT DE GYMOS',
                  style: TextStyle(
                    color: GymOSTheme.violetElectric,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(
                    color: GymOSTheme.textPrimary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(List<Map<String, dynamic>> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SESIONES RECIENTES',
              style: TextStyle(
                color: GymOSTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
              ),
              child: const Text(
                'Ver todo',
                style: TextStyle(color: GymOSTheme.orangeElectric),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GymOSTheme.surfaceBase,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Aún no hay sesiones registradas.',
              style: TextStyle(color: GymOSTheme.textSecondary),
            ),
          )
        else
          ...history.take(3).map((session) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: GymOSTheme.surfaceBase,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: GymOSTheme.orangeElectric,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      session['title'] as String? ?? 'Rutina',
                      style: const TextStyle(
                        color: GymOSTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${session['duration'] ?? 0} min',
                    style: const TextStyle(
                      color: GymOSTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildMuscleProgress(
    Map<String, int> muscleCounts,
    int maxMuscleCount,
  ) {
    const groups = [
      'Pecho',
      'Espalda',
      'Piernas',
      'Hombros',
      'Bíceps',
      'Tríceps',
      'Glúteos',
      'Core',
      'Antebrazo',
      'Pantorrillas',
    ];
    final sorted = [...groups]
      ..sort((a, b) => (muscleCounts[b] ?? 0).compareTo(muscleCounts[a] ?? 0));
    final topGroup = sorted.firstWhere(
      (group) => (muscleCounts[group] ?? 0) > 0,
      orElse: () => '',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'PROGRESO POR GRUPO MUSCULAR',
              style: TextStyle(
                color: GymOSTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Sesiones',
              style: TextStyle(
                color: GymOSTheme.orangeElectric,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: GymOSTheme.surfaceBase,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GymOSTheme.cyanElectric.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              if (topGroup.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: GymOSTheme.textSecondary,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Completa una rutina para comenzar a medir qué grupos trabajas más.',
                          style: TextStyle(
                            color: GymOSTheme.textSecondary,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: GymOSTheme.orangeElectric,
                        size: 19,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Más trabajado: $topGroup',
                        style: const TextStyle(
                          color: GymOSTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ...sorted.map(
                (group) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _MuscleProgressRow(
                    label: group,
                    sessions: muscleCounts[group] ?? 0,
                    percentage: maxMuscleCount == 0
                        ? 0
                        : (muscleCounts[group] ?? 0) / maxMuscleCount,
                    color: _muscleColor(group),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _muscleColor(String group) {
    const upper = [
      'Pecho',
      'Espalda',
      'Hombros',
      'Bíceps',
      'Tríceps',
      'Antebrazo',
    ];
    return upper.contains(group)
        ? GymOSTheme.orangeElectric
        : GymOSTheme.violetElectric;
  }

  @override
  Widget build(BuildContext context) {
    final history = RoutineStore.instance.workoutHistory;
    final sessions = history.length;
    final minutes = history.fold<int>(
      0,
      (total, item) => total + ((item['duration'] as int?) ?? 0),
    );
    final totalSets = history.fold<int>(
      0,
      (total, item) => total + ((item['sets'] as int?) ?? 0),
    );
    final volume = history.fold<double>(
      0,
      (total, item) => total + ((item['volume'] as num?)?.toDouble() ?? 0),
    );
    final chartValues = history.isEmpty
        ? [0.0, 0.0, 0.0, 0.0]
        : history.reversed
              .take(7)
              .map((item) => ((item['duration'] as int?) ?? 0).toDouble())
              .toList();
    final muscleCounts = <String, int>{};
    for (final session in history) {
      for (final muscle
          in (session['muscleGroups'] as List<dynamic>? ?? const [])) {
        final key = muscle.toString();
        muscleCounts[key] = (muscleCounts[key] ?? 0) + 1;
      }
    }
    final maxMuscleCount = muscleCounts.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final volumeByMuscle = ProgressAnalytics.volumeByMuscle(history);

    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Progreso',
          style: TextStyle(
            color: GymOSTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar progreso',
            onPressed: () => setState(() {}),
            icon: const Icon(
              Icons.refresh_rounded,
              color: GymOSTheme.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [GymOSTheme.bgMain, Color(0xFF0B1020)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.paddingOf(context).bottom + 42,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                _buildProgressHero(sessions, minutes, totalSets),
                const SizedBox(height: 18),

                // Selector de Temporalidad
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: _timeframes.map((tf) {
                      final isSel = _selectedTimeframe == tf;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(tf),
                          selected: isSel,
                          selectedColor: GymOSTheme.orangeElectric,
                          backgroundColor: GymOSTheme.surfaceElevated,
                          side: BorderSide(
                            color: isSel
                                ? GymOSTheme.orangeElectric
                                : Colors.white.withValues(alpha: 0.06),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelStyle: TextStyle(
                            color: isSel
                                ? GymOSTheme.bgMain
                                : GymOSTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedTimeframe = tf),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 28),
                _buildInsightCard(sessions, minutes),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressShortcut(
                        icon: Icons.history_rounded,
                        title: 'Historial',
                        subtitle: 'Sesiones',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkoutHistoryScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProgressShortcut(
                        icon: Icons.emoji_events_rounded,
                        title: 'Logros',
                        subtitle: 'Desbloquea',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AchievementsScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ProgressShortcut(
                        icon: Icons.photo_library_outlined,
                        title: 'Fotos',
                        subtitle: 'Evolución',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BodyEvolutionScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. GRÁFICA DE PESO CORPORAL (Principal - Naranja)
                _buildChartCard(
                  title: 'ACTIVIDAD REGISTRADA',
                  value: sessions == 0 ? '--' : '$sessions sesiones',
                  accentColor: GymOSTheme.orangeElectric,
                  icon: Icons.show_chart_rounded,
                  chart: _buildLineChart(
                    GymOSTheme.orangeElectric,
                    chartValues,
                  ),
                ),

                const SizedBox(height: 16),

                // 2. GRÁFICA DE VOLUMEN (Principal - Naranja)
                _buildChartCard(
                  title: 'VOLUMEN DE ENTRENAMIENTO',
                  value: volume == 0 ? '--' : '${volume.toStringAsFixed(0)} kg',
                  accentColor: GymOSTheme.orangeElectric,
                  icon: Icons.bar_chart_rounded,
                  chart: _buildBarChart(
                    GymOSTheme.orangeElectric,
                    chartValues.map((value) => value * 100).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. GRÁFICA DE 1RM (Secundario - Violeta)
                _buildChartCard(
                  title: '1RM ESTIMADO — PRESS BANCA',
                  value: minutes == 0 ? '--' : '$minutes min',
                  accentColor: GymOSTheme.violetElectric,
                  icon: Icons.timer_rounded,
                  chart: _buildLineChart(
                    GymOSTheme.violetElectric,
                    chartValues,
                  ),
                ),

                const SizedBox(height: 28),

                // ESTADÍSTICAS GENERALES (Cuadrícula 2x2)
                const Text(
                  'ESTADÍSTICAS GLOBALES',
                  style: TextStyle(
                    color: GymOSTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _StatTile(
                      label: 'Entrenamientos',
                      value: '$sessions',
                      icon: Icons.fitness_center_rounded,
                    ),
                    _StatTile(
                      label: 'Volumen Total',
                      value: volume == 0
                          ? '--'
                          : '${volume.toStringAsFixed(0)} kg',
                      icon: Icons.scale_rounded,
                    ),
                    _StatTile(
                      label: 'Tiempo Invertido',
                      value: '${(minutes / 60).toStringAsFixed(1)} h',
                      icon: Icons.timer_rounded,
                    ),
                    _StatTile(
                      label: 'Récords (PRs)',
                      value: '$totalSets',
                      icon: Icons.emoji_events_rounded,
                      isHighlight: true,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _buildMuscleProgress(muscleCounts, maxMuscleCount),

                const SizedBox(height: 24),
                _buildPerformanceAnalysis(history, volumeByMuscle),

                const SizedBox(height: 24),
                _buildRecentSessions(history),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tarjeta contenedora de Gráfica
  Widget _buildChartCard({
    required String title,
    required String value,
    required Color accentColor,
    required IconData icon,
    required Widget chart,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GymOSTheme.surfaceElevated,
            GymOSTheme.surfaceBase.withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: GymOSTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Icon(
                Icons.more_horiz_rounded,
                color: GymOSTheme.textMuted,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 112, child: chart),
        ],
      ),
    );
  }

  // Gráfica de Línea Minimalista (LineChart)
  Widget _buildLineChart(Color lineColor, List<double> spots) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }

  // Gráfica de Barras Minimalista (BarChart)
  Widget _buildBarChart(Color barColor, List<double> values) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: values.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                color: barColor,
                width: 14,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 10000,
                  color: GymOSTheme.surfaceElevated,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ==========================================
// COMPONENTES AUXILIARES
// ==========================================
class _AnalysisMetric extends StatelessWidget {
  const _AnalysisMetric({
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  final String label;
  final String value;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: GymOSTheme.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: .8,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        caption,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: GymOSTheme.textSecondary, fontSize: 10),
      ),
    ],
  );
}

class _AnalysisAlert extends StatelessWidget {
  const _AnalysisAlert({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: color, size: 17),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: GymOSTheme.textSecondary,
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ),
    ],
  );
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isHighlight;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isHighlight
              ? GymOSTheme.orangeElectric.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isHighlight
                    ? GymOSTheme.orangeElectric
                    : GymOSTheme.textSecondary,
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
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: isHighlight
                  ? GymOSTheme.orangeElectric
                  : GymOSTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleProgressRow extends StatelessWidget {
  final String label;
  final int sessions;
  final double percentage;
  final Color color;

  const _MuscleProgressRow({
    required this.label,
    required this.sessions,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: GymOSTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$sessions ${sessions == 1 ? 'sesión' : 'sesiones'}',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: GymOSTheme.surfaceElevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _ProgressShortcut extends StatelessWidget {
  const _ProgressShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        decoration: BoxDecoration(
          color: GymOSTheme.surfaceBase,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: GymOSTheme.orangeElectric, size: 23),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: GymOSTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: GymOSTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//
