import 'package:flutter/material.dart';

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
  final List<Map<String, dynamic>> _goals = [
    {
      'category': 'FUERZA',
      'title': 'Press banca',
      'target': 'Objetivo: 100 kg',
      'current': '82.5 / 100 kg',
      'progress': .82,
      'percentage': '82%',
      'color': GymOSTheme.orangeElectric,
    },
    {
      'category': 'CONSISTENCIA',
      'title': '4 entrenamientos / semana',
      'target': 'Meta semanal',
      'current': '3 / 4 completados',
      'progress': .75,
      'percentage': '75%',
      'color': GymOSTheme.violetElectric,
    },
    {
      'category': 'PESO CORPORAL',
      'title': 'Objetivo: 85 kg',
      'target': 'Meta final',
      'current': '91.3 → 85 kg',
      'progress': .40,
      'percentage': '40%',
      'color': GymOSTheme.orangeElectric,
    },
  ];
  final List<Map<String, dynamic>> _milestones = [
    {'title': '90 kg Press banca', 'category': 'FUERZA', 'completed': true},
    {'title': '100 kg Press banca', 'category': 'FUERZA', 'completed': false},
    {'title': '150 kg Sentadilla', 'category': 'FUERZA', 'completed': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              if (_goals.isEmpty)
                const Text(
                  'No tienes objetivos todavía. Usa + para crear uno.',
                  style: TextStyle(color: GymOSTheme.textSecondary),
                )
              else
                ..._goals.map(
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
                  onTap: () => setState(
                    () => entry.value['completed'] =
                        !(entry.value['completed'] as bool),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _addGoal() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GymOSTheme.surfaceElevated,
        title: const Text('Nuevo objetivo'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Describe tu objetivo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(
                  () => _milestones.add({
                    'title': controller.text.trim(),
                    'category': 'PERSONAL',
                    'completed': false,
                  }),
                );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('AÑADIR'),
          ),
        ],
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
