import 'package:flutter/material.dart';

import '../data/database.dart';
import '../data/routine_store.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS Goals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const GoalsScreen(),
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

  // Acentos de Rendimiento Deportivo
  static const Color orangeElectric = Color(0xFFFF6B1A);
  static const Color violetElectric = Color(0xFF8B5CF6);
  static const Color textMuted = Color(0xFF374151);
}

// ==========================================
// PANTALLA PRINCIPAL: MIS OBJETIVOS
// ==========================================
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final List<Map<String, dynamic>> _milestones = [
    {'title': '90 kg Press banca', 'category': 'FUERZA', 'completed': true},
    {'title': '100 kg Press banca', 'category': 'FUERZA', 'completed': false},
    {'title': '150 kg Sentadilla', 'category': 'FUERZA', 'completed': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    final saved = await GymDatabase.instance.readCollection('milestones');
    if (!mounted || saved.isEmpty) return;
    setState(() {
      _milestones
        ..clear()
        ..addAll(saved);
    });
  }

  Future<void> _saveMilestones() =>
      GymDatabase.instance.writeCollection('milestones', _milestones);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoutineStore.instance,
      builder: (context, _) => Scaffold(
        backgroundColor: GymOSTheme.bgMain,
        appBar: AppBar(
          backgroundColor: GymOSTheme.bgMain,
          elevation: 0,
          title: const Text(
            'MIS OBJETIVOS',
            style: TextStyle(
              color: GymOSTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          leading: Navigator.canPop(context)
              ? const BackButton(color: GymOSTheme.textPrimary)
              : null,
          actions: [
            IconButton(
              tooltip: 'Añadir objetivo',
              onPressed: _addGoal,
              icon: const Icon(Icons.add, color: GymOSTheme.orangeElectric),
            ),
          ],
        ),
        body: SafeArea(
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

                // 1. OBJETIVO DE FUERZA
                if (finalGoals.isEmpty)
                  const Text(
                    'No tienes objetivos todavía. Usa + para crear uno.',
                    style: TextStyle(color: GymOSTheme.textSecondary),
                  )
                else
                  ...finalGoals.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _buildGoalCard(
                        category: goal['category'] as String,
                        title: goal['title'] as String,
                        targetText: goal['target'] as String,
                        currentText: goal['current'] as String,
                        progressValue: goal['progress'] as double,
                        percentageText: goal['percentage'] as String,
                        accentColor: goal['color'] as Color,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // ROADMAP / PRÓXIMOS OBJETIVOS
                const Text(
                  'PRÓXIMOS OBJETIVOS',
                  style: TextStyle(
                    color: GymOSTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Lista de hitos (Incluye demostración de Hito Completado)
                ..._milestones.asMap().entries.map(
                  (entry) => _buildUpcomingGoalTile(
                    title: entry.value['title'] as String,
                    category: entry.value['category'] as String,
                    isCompleted: entry.value['completed'] as bool,
                    isCurrentTarget: entry.key == 1,
                    onTap: () {
                      setState(
                        () => entry.value['completed'] =
                            !(entry.value['completed'] as bool),
                      );
                      _saveMilestones();
                    },
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> get finalGoals {
    final store = RoutineStore.instance;
    final result = <Map<String, dynamic>>[];
    for (final goal in store.goals) {
      final type = goal['type']?.toString() ?? 'strength';
      final target = (goal['target'] as num?)?.toDouble() ?? 1;
      final current = _currentValue(type, goal['exercise']?.toString());
      final progress = type == 'weight'
          ? (current <= target ? 1 : (target / current).clamp(0.0, 1.0))
          : (current / target).clamp(0.0, 1.0);
      result.add({
        'category': _goalCategory(type),
        'title': goal['title']?.toString() ?? 'Objetivo',
        'target': 'Meta: ${target.toStringAsFixed(0)} ${_goalUnit(type)}',
        'current':
            '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} ${_goalUnit(type)}',
        'progress': progress,
        'percentage': '${(progress * 100).round()}%',
        'color': type == 'strength'
            ? GymOSTheme.orangeElectric
            : GymOSTheme.violetElectric,
      });
    }
    if (result.isEmpty) {
      result.addAll([
        _goalView(
          'CONSISTENCIA',
          'Entrenamientos semanales',
          _currentValue('consistency', null),
          4,
          'sesiones',
        ),
        _goalView(
          'VOLUMEN',
          'Volumen mensual',
          _currentValue('volume', null),
          10000,
          'kg',
        ),
      ]);
    }
    return result;
  }

  Map<String, dynamic> _goalView(
    String category,
    String title,
    double current,
    double target,
    String unit,
  ) {
    final progress = (current / target).clamp(0.0, 1.0);
    return {
      'category': category,
      'title': title,
      'target': 'Meta: ${target.toStringAsFixed(0)} $unit',
      'current':
          '${current.toStringAsFixed(1)} / ${target.toStringAsFixed(0)} $unit',
      'progress': progress,
      'percentage': '${(progress * 100).round()}%',
      'color': category == 'VOLUMEN'
          ? GymOSTheme.violetElectric
          : GymOSTheme.orangeElectric,
    };
  }

  double _currentValue(String type, String? exercise) {
    final history = RoutineStore.instance.workoutHistory;
    if (type == 'consistency') {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      return history
          .where((session) {
            final date = DateTime.tryParse(session['date']?.toString() ?? '');
            return date != null && date.isAfter(cutoff);
          })
          .length
          .toDouble();
    }
    if (type == 'volume') {
      return history
          .where((session) {
            final date = DateTime.tryParse(session['date']?.toString() ?? '');
            return date != null &&
                date.isAfter(DateTime.now().subtract(const Duration(days: 30)));
          })
          .fold<double>(
            0,
            (sum, session) =>
                sum + ((session['volume'] as num?)?.toDouble() ?? 0),
          );
    }
    if (type == 'weight') {
      return (RoutineStore.instance.bodyLogs.isEmpty
              ? 0
              : (RoutineStore.instance.bodyLogs.first['weight'] as num?)
                    ?.toDouble()) ??
          0;
    }
    return history
        .expand((session) => (session['exerciseStats'] as List?) ?? const [])
        .where((stat) => exercise == null || stat['name'] == exercise)
        .fold<double>(0, (max, stat) {
          final weight = (stat['weight'] as num?)?.toDouble() ?? 0;
          return weight > max ? weight : max;
        });
  }

  String _goalCategory(String type) => switch (type) {
    'weight' => 'PESO CORPORAL',
    'volume' => 'VOLUMEN',
    'consistency' => 'CONSISTENCIA',
    _ => 'FUERZA',
  };

  String _goalUnit(String type) => switch (type) {
    'consistency' => 'sesiones',
    'volume' => 'kg',
    _ => 'kg',
  };

  void _addGoal() {
    final controller = TextEditingController();
    final targetController = TextEditingController();
    String type = 'strength';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: GymOSTheme.surfaceElevated,
          title: const Text('Nueva meta medible'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la meta',
                ),
              ),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor objetivo'),
              ),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(
                    value: 'strength',
                    child: Text('Fuerza / kg'),
                  ),
                  DropdownMenuItem(
                    value: 'volume',
                    child: Text('Volumen mensual'),
                  ),
                  DropdownMenuItem(
                    value: 'consistency',
                    child: Text('Sesiones semanales'),
                  ),
                  DropdownMenuItem(
                    value: 'weight',
                    child: Text('Peso corporal'),
                  ),
                ],
                onChanged: (value) =>
                    setDialogState(() => type = value ?? type),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () {
                final target = double.tryParse(targetController.text);
                if (controller.text.trim().isEmpty ||
                    target == null ||
                    target <= 0) {
                  return;
                }
                RoutineStore.instance.addGoal({
                  'title': controller.text.trim(),
                  'type': type,
                  'target': target,
                  'exercise': type == 'strength'
                      ? controller.text.trim()
                      : null,
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('GUARDAR'),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta contenedora de objetivo activo
  Widget _buildGoalCard({
    required String category,
    required String title,
    required String targetText,
    required String currentText,
    required double progressValue,
    required String percentageText,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                targetText,
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
            title,
            style: const TextStyle(
              color: GymOSTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentText,
                style: const TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'PROGRESO: $percentageText',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              backgroundColor: GymOSTheme.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }

  // Elemento de próximo objetivo (con estado completado premium)
  Widget _buildUpcomingGoalTile({
    required String title,
    required String category,
    required bool isCompleted,
    bool isCurrentTarget = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isCompleted
              ? GymOSTheme.orangeElectric.withValues(alpha: 0.08)
              : GymOSTheme.surfaceBase,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCompleted
                ? GymOSTheme.orangeElectric.withValues(alpha: 0.4)
                : (isCurrentTarget
                      ? GymOSTheme.violetElectric.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.03)),
            width: isCompleted ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? GymOSTheme.orangeElectric
                        : GymOSTheme.surfaceElevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : Icons.outlined_flag_rounded,
                    size: 14,
                    color: isCompleted
                        ? GymOSTheme.bgMain
                        : GymOSTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isCompleted
                            ? GymOSTheme.orangeElectric
                            : GymOSTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: GymOSTheme.orangeElectric,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category,
                      style: const TextStyle(
                        color: GymOSTheme.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted
                    ? GymOSTheme.orangeElectric.withValues(alpha: 0.15)
                    : GymOSTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isCompleted
                    ? 'LOGRADO'
                    : (isCurrentTarget ? 'EN CURSO' : 'PENDIENTE'),
                style: TextStyle(
                  color: isCompleted
                      ? GymOSTheme.orangeElectric
                      : (isCurrentTarget
                            ? GymOSTheme.violetElectric
                            : GymOSTheme.textSecondary),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
