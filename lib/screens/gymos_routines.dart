import 'package:flutter/material.dart';

import '../data/exercise_catalog.dart';
import '../data/routine_store.dart';

void main() {
  runApp(const GymOSApp());
}

class _MuscleIconPainter extends CustomPainter {
  const _MuscleIconPainter({required this.muscle, required this.color});

  final String muscle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()
      ..color = GymOSTheme.textSecondary.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final active = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final center = size.width / 2;

    canvas.drawCircle(Offset(center, 5), 3.5, base);
    canvas.drawLine(Offset(center, 9), Offset(center, 18), base);
    canvas.drawLine(Offset(center, 11), Offset(center - 7, 16), base);
    canvas.drawLine(Offset(center, 11), Offset(center + 7, 16), base);
    canvas.drawLine(Offset(center, 18), Offset(center - 6, 26), base);
    canvas.drawLine(Offset(center, 18), Offset(center + 6, 26), base);

    if (muscle.contains('Pecho')) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center, 13), width: 11, height: 6),
        active,
      );
    } else if (muscle.contains('Espalda')) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center, 14), width: 13, height: 9),
        active,
      );
    } else if (muscle.contains('Piernas') || muscle.contains('Glúteos')) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center - 3.5, 21), width: 5, height: 10),
        active,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center + 3.5, 21), width: 5, height: 10),
        active,
      );
    } else if (muscle.contains('Bíceps') || muscle.contains('Tríceps')) {
      canvas.drawCircle(Offset(center - 7, 16), 3.5, active);
      canvas.drawCircle(Offset(center + 7, 16), 3.5, active);
    } else if (muscle.contains('Hombros')) {
      canvas.drawCircle(Offset(center - 7, 11), 3.5, active);
      canvas.drawCircle(Offset(center + 7, 11), 3.5, active);
    } else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center, 16), width: 7, height: 9),
        active,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MuscleIconPainter oldDelegate) =>
      oldDelegate.muscle != muscle || oldDelegate.color != color;
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS Routines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const RoutinesMainScreen(),
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
  static const Color orangeElectric = Color(0xFFFF6B1A);
  static const Color violetElectric = Color(0xFF8B5CF6);
  static const Color textMuted = Color(0xFF4B5563);
}

// ==========================================
// PANTALLA PRINCIPAL: MIS RUTINAS
// ==========================================
class RoutinesMainScreen extends StatefulWidget {
  const RoutinesMainScreen({super.key});

  @override
  State<RoutinesMainScreen> createState() => _RoutinesMainScreenState();
}

class _RoutinesMainScreenState extends State<RoutinesMainScreen> {
  String _activeFilter = 'Todas';

  @override
  Widget build(BuildContext context) {
    final allRoutines = RoutineStore.instance.routines;
    final filteredRoutines = _activeFilter == 'Todas'
        ? allRoutines
        : allRoutines.where((r) => r['status'] == _activeFilter).toList();

    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      appBar: AppBar(
        backgroundColor: GymOSTheme.bgMain,
        elevation: 0,
        title: const Text(
          'Mis rutinas',
          style: TextStyle(
            color: GymOSTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Filtros (Todas, Activas, Archivadas)
              Row(
                children: ['Todas', 'Activas', 'Archivadas'].map((filter) {
                  final isSel = _activeFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSel,
                      selectedColor: GymOSTheme.orangeElectric,
                      backgroundColor: GymOSTheme.surfaceBase,
                      labelStyle: TextStyle(
                        color: isSel
                            ? GymOSTheme.bgMain
                            : GymOSTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _activeFilter = filter),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Lista de Rutinas
              Expanded(
                child: ListView.builder(
                  itemCount: filteredRoutines.length,
                  itemBuilder: (context, index) {
                    final routine = filteredRoutines[index];
                    return _RoutineCard(
                      routine: routine,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RoutineDetailScreen(routine: routine),
                          ),
                        );
                      },
                      onEdit: () => _editRoutine(routine),
                      onDelete: () => _deleteRoutine(routine),
                    );
                  },
                ),
              ),

              // Botón flotante/fijo de Crear Rutina
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GymOSTheme.orangeElectric,
                    foregroundColor: GymOSTheme.bgMain,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _showCreateRoutine,
                  icon: const Icon(Icons.add_rounded, size: 22),
                  label: const Text(
                    'CREAR RUTINA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateRoutine() async {
    final routine = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GymOSTheme.bgMain,
      builder: (_) => const _CreateRoutineSheet(),
    );
    if (routine == null) return;
    RoutineStore.instance.add(routine);
    setState(() {});
  }

  Future<void> _editRoutine(Map<String, dynamic> routine) async {
    final updated = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: GymOSTheme.bgMain,
      builder: (_) => _CreateRoutineSheet(initialRoutine: routine),
    );
    if (updated == null || !mounted) return;
    RoutineStore.instance.update(routine, updated);
    setState(() {});
  }

  Future<void> _deleteRoutine(Map<String, dynamic> routine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GymOSTheme.surfaceElevated,
        title: const Text(
          'Eliminar rutina',
          style: TextStyle(color: GymOSTheme.textPrimary),
        ),
        content: Text(
          '¿Quieres eliminar “${routine['title']}”? Esta acción no se puede deshacer.',
          style: const TextStyle(color: GymOSTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    RoutineStore.instance.remove(routine);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Rutina eliminada')));
    setState(() {});
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> routine;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final days = (routine['days'] as List<dynamic>? ?? const []).join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [GymOSTheme.surfaceElevated, GymOSTheme.surfaceBase],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: GymOSTheme.orangeElectric.withValues(
                          alpha: 0.14,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: GymOSTheme.orangeElectric,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            routine['title'] as String? ?? 'Rutina',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: GymOSTheme.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${routine['goal'] ?? 'Fuerza'} · ${days.isEmpty ? 'Sin días asignados' : days}',
                            style: const TextStyle(
                              color: GymOSTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: GymOSTheme.surfaceElevated,
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: GymOSTheme.textSecondary,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_rounded),
                            title: Text('Editar'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            title: Text(
                              'Eliminar',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _metricPill(
                      Icons.layers_outlined,
                      '${routine['sets'] ?? 0} series',
                    ),
                    _metricPill(
                      Icons.fitness_center_outlined,
                      '${routine['exercises'] ?? 0} ejercicios',
                    ),
                    _metricPill(
                      Icons.timer_outlined,
                      routine['duration'] as String? ?? '45 min',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Text(
                      'Ver detalles',
                      style: TextStyle(
                        color: GymOSTheme.orangeElectric,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: GymOSTheme.orangeElectric,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: GymOSTheme.textSecondary, size: 14),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateRoutineSheet extends StatefulWidget {
  const _CreateRoutineSheet({this.initialRoutine});

  final Map<String, dynamic>? initialRoutine;

  @override
  State<_CreateRoutineSheet> createState() => _CreateRoutineSheetState();
}

class _CreateRoutineSheetState extends State<_CreateRoutineSheet> {
  final _nameController = TextEditingController();
  String _routineName = '';
  String _goal = 'Fuerza';
  String _muscleFilter = 'Todos';
  final Set<String> _selectedDays = {'Lun'};
  final Set<String> _selectedExercises = {'Press banca'};
  final Map<String, Map<String, String>> _exerciseSettings = {
    'Press banca': {'sets': '4', 'reps': '5', 'weight': '40'},
  };

  static const _exercises = [
    _ExerciseGuide(
      name: 'Press banca',
      muscle: 'Pecho',
      equipment: 'Barra',
      difficulty: 'Intermedio',
      explanation:
          'Empuja la barra desde el pecho para desarrollar fuerza y masa en el tren superior.',
      steps: [
        'Apoya espalda, cabeza y pies en el banco.',
        'Baja la barra al centro del pecho con control.',
        'Empuja hacia arriba sin bloquear los codos.',
      ],
      tips: 'Mantén los omóplatos juntos y no rebotes la barra.',
      icon: Icons.fitness_center_rounded,
    ),
    _ExerciseGuide(
      name: 'Sentadilla con barra',
      muscle: 'Piernas',
      equipment: 'Barra',
      difficulty: 'Intermedio',
      explanation:
          'Movimiento compuesto para fortalecer cuádriceps, glúteos y core.',
      steps: [
        'Coloca la barra sobre la parte alta de la espalda.',
        'Baja llevando la cadera hacia atrás y flexionando rodillas.',
        'Sube empujando el suelo y mantén el pecho firme.',
      ],
      tips: 'Las rodillas deben seguir la dirección de los pies.',
      icon: Icons.accessibility_new_rounded,
    ),
    _ExerciseGuide(
      name: 'Jalón al pecho',
      muscle: 'Espalda',
      equipment: 'Polea',
      difficulty: 'Principiante',
      explanation:
          'Ejercicio guiado para aprender a activar dorsales y mejorar la tracción.',
      steps: [
        'Siéntate con los muslos firmes bajo el soporte.',
        'Lleva la barra hacia la parte alta del pecho.',
        'Regresa lentamente sin perder tensión.',
      ],
      tips:
          'Piensa en llevar los codos hacia abajo, no en tirar con las manos.',
      icon: Icons.vertical_align_bottom_rounded,
    ),
    _ExerciseGuide(
      name: 'Press militar',
      muscle: 'Hombros',
      equipment: 'Mancuernas',
      difficulty: 'Principiante',
      explanation:
          'Press vertical para desarrollar hombros y estabilidad del tronco.',
      steps: [
        'Sostén las mancuernas a la altura de los hombros.',
        'Empuja verticalmente manteniendo las muñecas neutras.',
        'Baja con control hasta la posición inicial.',
      ],
      tips:
          'Evita arquear la espalda; activa el abdomen durante todo el movimiento.',
      icon: Icons.north_rounded,
    ),
    _ExerciseGuide(
      name: 'Peso muerto',
      muscle: 'Espalda / Piernas',
      equipment: 'Barra',
      difficulty: 'Avanzado',
      explanation: 'Movimiento global para fuerza de cadena posterior y core.',
      steps: [
        'Barra cerca de las tibias.',
        'Cadera atrás y espalda neutra.',
        'Empuja el suelo y termina erguido.',
      ],
      tips: 'No redondees la espalda ni tires con los brazos.',
      icon: Icons.swap_vert_rounded,
    ),
    _ExerciseGuide(
      name: 'Remo con mancuerna',
      muscle: 'Espalda',
      equipment: 'Mancuerna',
      difficulty: 'Principiante',
      explanation: 'Fortalece dorsales y mejora la estabilidad escapular.',
      steps: [
        'Apoya una mano en el banco.',
        'Lleva el codo hacia la cadera.',
        'Baja la mancuerna lentamente.',
      ],
      tips: 'Evita girar el torso para levantar más peso.',
      icon: Icons.rowing_rounded,
    ),
    _ExerciseGuide(
      name: 'Curl de bíceps',
      muscle: 'Bíceps',
      equipment: 'Mancuernas',
      difficulty: 'Principiante',
      explanation:
          'Aislamiento sencillo para flexores del codo y control del brazo.',
      steps: [
        'Codos pegados al cuerpo.',
        'Flexiona sin balancearte.',
        'Desciende controlando el peso.',
      ],
      tips: 'La fase de bajada también cuenta: hazla lenta.',
      icon: Icons.fitness_center_rounded,
    ),
    _ExerciseGuide(
      name: 'Extensión de tríceps',
      muscle: 'Tríceps',
      equipment: 'Polea',
      difficulty: 'Principiante',
      explanation:
          'Trabaja la extensión del codo para desarrollar la parte posterior del brazo.',
      steps: [
        'Codos junto al torso.',
        'Empuja la cuerda hacia abajo.',
        'Regresa sin abrir los codos.',
      ],
      tips: 'No uses impulso de hombros.',
      icon: Icons.vertical_align_bottom_rounded,
    ),
    _ExerciseGuide(
      name: 'Hip thrust',
      muscle: 'Glúteos',
      equipment: 'Barra',
      difficulty: 'Intermedio',
      explanation: 'Ejercicio específico para fuerza y potencia de glúteos.',
      steps: [
        'Apoya la espalda alta en un banco.',
        'Eleva la cadera contrayendo glúteos.',
        'Baja sin perder tensión.',
      ],
      tips: 'Mete ligeramente la barbilla y evita hiperextender la espalda.',
      icon: Icons.arrow_upward_rounded,
    ),
    _ExerciseGuide(
      name: 'Plancha',
      muscle: 'Core',
      equipment: 'Peso corporal',
      difficulty: 'Principiante',
      explanation: 'Trabajo isométrico para estabilidad abdominal y lumbar.',
      steps: [
        'Codos debajo de hombros.',
        'Forma una línea recta.',
        'Respira sin dejar caer la cadera.',
      ],
      tips: 'Prioriza la postura antes que aguantar más segundos.',
      icon: Icons.horizontal_rule_rounded,
    ),
    _ExerciseGuide(
      name: 'Zancadas',
      muscle: 'Piernas',
      equipment: 'Mancuernas',
      difficulty: 'Principiante',
      explanation:
          'Movimiento unilateral para piernas, equilibrio y coordinación.',
      steps: [
        'Da un paso largo.',
        'Baja ambas rodillas con control.',
        'Empuja con el pie delantero.',
      ],
      tips: 'Mantén la rodilla alineada con los dedos del pie.',
      icon: Icons.directions_walk_rounded,
    ),
    _ExerciseGuide(
      name: 'Press inclinado',
      muscle: 'Pecho',
      equipment: 'Mancuernas',
      difficulty: 'Intermedio',
      explanation:
          'Enfatiza la parte superior del pecho y el control del hombro.',
      steps: [
        'Ajusta el banco con inclinación moderada.',
        'Baja las mancuernas al nivel del pecho.',
        'Empuja manteniendo las muñecas firmes.',
      ],
      tips: 'No juntes las mancuernas con un golpe al final.',
      icon: Icons.fitness_center_rounded,
    ),
    _ExerciseGuide(
      name: 'Aperturas con mancuernas',
      muscle: 'Pecho',
      equipment: 'Mancuernas',
      difficulty: 'Principiante',
      explanation:
          'Aislamiento del pecho con énfasis en el estiramiento controlado.',
      steps: [
        'Abre los brazos con codos ligeramente flexionados.',
        'Baja hasta sentir un estiramiento cómodo.',
        'Cierra los brazos sobre el pecho.',
      ],
      tips: 'Usa poco peso y prioriza el control.',
      icon: Icons.open_in_full_rounded,
    ),
    _ExerciseGuide(
      name: 'Remo con barra',
      muscle: 'Espalda',
      equipment: 'Barra',
      difficulty: 'Intermedio',
      explanation: 'Ejercicio compuesto para dorsales, romboides y trapecio.',
      steps: [
        'Inclina el torso con espalda neutra.',
        'Lleva la barra hacia el abdomen.',
        'Baja lentamente sin perder postura.',
      ],
      tips: 'No conviertas el movimiento en un balanceo.',
      icon: Icons.rowing_rounded,
    ),
    _ExerciseGuide(
      name: 'Elevaciones laterales',
      muscle: 'Hombros',
      equipment: 'Mancuernas',
      difficulty: 'Principiante',
      explanation:
          'Aislamiento del deltoides lateral para dar amplitud al hombro.',
      steps: [
        'Mancuernas a los lados.',
        'Eleva hasta la línea de los hombros.',
        'Desciende con control.',
      ],
      tips: 'No subas los hombros hacia las orejas.',
      icon: Icons.unfold_more_rounded,
    ),
    _ExerciseGuide(
      name: 'Face pull',
      muscle: 'Hombros / Espalda',
      equipment: 'Polea',
      difficulty: 'Principiante',
      explanation:
          'Fortalece deltoides posteriores y musculatura estabilizadora.',
      steps: [
        'Agarra la cuerda a la altura de la cara.',
        'Tira separando las manos.',
        'Regresa manteniendo tensión.',
      ],
      tips: 'Mantén los codos altos y evita arquear la espalda.',
      icon: Icons.compare_arrows_rounded,
    ),
    _ExerciseGuide(
      name: 'Prensa de piernas',
      muscle: 'Piernas',
      equipment: 'Máquina',
      difficulty: 'Principiante',
      explanation:
          'Permite entrenar piernas con soporte para espalda y tronco.',
      steps: [
        'Coloca los pies al ancho de cadera.',
        'Baja la plataforma con control.',
        'Empuja sin bloquear las rodillas.',
      ],
      tips: 'No despegues la cadera del respaldo.',
      icon: Icons.airline_seat_legroom_extra_rounded,
    ),
    _ExerciseGuide(
      name: 'Elevación de pantorrillas',
      muscle: 'Pantorrillas',
      equipment: 'Máquina',
      difficulty: 'Principiante',
      explanation: 'Trabajo directo del tríceps sural y control del tobillo.',
      steps: [
        'Apoya la parte delantera del pie.',
        'Eleva los talones al máximo.',
        'Baja hasta un estiramiento cómodo.',
      ],
      tips: 'Haz una pausa arriba para evitar rebotes.',
      icon: Icons.height_rounded,
    ),
    _ExerciseGuide(
      name: 'Crunch abdominal',
      muscle: 'Core',
      equipment: 'Peso corporal',
      difficulty: 'Principiante',
      explanation: 'Flexión controlada del tronco para activar el abdomen.',
      steps: [
        'Apoya la zona lumbar.',
        'Eleva los hombros sin tirar del cuello.',
        'Baja lentamente.',
      ],
      tips: 'Mira hacia arriba y mantén el cuello relajado.',
      icon: Icons.self_improvement_rounded,
    ),
    _ExerciseGuide(
      name: 'Fondos en paralelas',
      muscle: 'Tríceps / Pecho',
      equipment: 'Paralelas',
      difficulty: 'Avanzado',
      explanation: 'Movimiento de empuje para tríceps y pecho inferior.',
      steps: [
        'Sujeta las paralelas con brazos extendidos.',
        'Baja flexionando los codos.',
        'Empuja hasta volver arriba.',
      ],
      tips: 'Detén el descenso si sientes molestia en el hombro.',
      icon: Icons.vertical_align_top_rounded,
    ),
  ];

  List<_ExerciseGuide> get _allExercises => [
    ..._exercises,
    ...ExerciseCatalog.all
        .where(
          (item) =>
              !_exercises.any((exercise) => exercise.name == item['name']),
        )
        .map(
          (item) => _ExerciseGuide(
            name: item['name']!,
            muscle: item['muscle']!,
            equipment: item['equipment']!,
            difficulty: item['difficulty']!,
            explanation:
                'Ejercicio de ${item['muscle']!.toLowerCase()} para complementar tu plan.',
            steps: const [
              'Adopta una postura estable y prepara el movimiento.',
              'Ejecuta cada repetición con control y rango cómodo.',
              'Regresa lentamente y mantén una respiración constante.',
            ],
            tips: 'Prioriza la técnica y aumenta la carga gradualmente.',
            icon: Icons.fitness_center_rounded,
          ),
        ),
  ];

  @override
  void initState() {
    super.initState();
    final routine = widget.initialRoutine;
    if (routine == null) return;

    _routineName = routine['title'] as String? ?? '';
    _nameController.text = _routineName;
    _goal = routine['goal'] as String? ?? _goal;
    _selectedDays
      ..clear()
      ..addAll((routine['days'] as List<dynamic>? ?? const []).cast<String>());

    final savedSettings = routine['exerciseSettings'];
    if (savedSettings is Map) {
      _selectedExercises
        ..clear()
        ..addAll(savedSettings.keys.cast<String>());
      _exerciseSettings
        ..clear()
        ..addAll(
          savedSettings.map(
            (key, value) => MapEntry(
              key.toString(),
              Map<String, String>.from(value as Map),
            ),
          ),
        );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: GymOSTheme.textMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nueva rutina',
              style: TextStyle(
                color: GymOSTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Crea una sesión a tu medida y aprende la técnica de cada ejercicio.',
              style: TextStyle(color: GymOSTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 22),
            _fieldLabel('NOMBRE DE LA RUTINA'),
            TextField(
              controller: _nameController,
              onChanged: (value) => setState(() => _routineName = value),
              style: const TextStyle(color: GymOSTheme.textPrimary),
              decoration: _inputDecoration('Ej. Full body inicial'),
            ),
            const SizedBox(height: 18),
            _fieldLabel('DÍAS DE ENTRENAMIENTO'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
                  .map(
                    (day) => FilterChip(
                      label: Text(day),
                      selected: _selectedDays.contains(day),
                      selectedColor: GymOSTheme.orangeElectric,
                      backgroundColor: GymOSTheme.surfaceBase,
                      labelStyle: TextStyle(
                        color: _selectedDays.contains(day)
                            ? GymOSTheme.bgMain
                            : GymOSTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                      onSelected: (selected) => setState(() {
                        selected
                            ? _selectedDays.add(day)
                            : _selectedDays.remove(day);
                      }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            _fieldLabel('OBJETIVO'),
            Wrap(
              spacing: 8,
              children: ['Fuerza', 'Hipertrofia', 'Movilidad'].map((goal) {
                final selected = _goal == goal;
                return ChoiceChip(
                  label: Text(goal),
                  selected: selected,
                  selectedColor: GymOSTheme.orangeElectric,
                  backgroundColor: GymOSTheme.surfaceBase,
                  labelStyle: TextStyle(
                    color: selected
                        ? GymOSTheme.bgMain
                        : GymOSTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) => setState(() => _goal = goal),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _goal == 'Fuerza'
                  ? 'Sugerencia: 3–5 series de 3–6 repeticiones, con descansos largos.'
                  : _goal == 'Hipertrofia'
                  ? 'Sugerencia: 3–4 series de 8–12 repeticiones, buscando control.'
                  : 'Sugerencia: 2–3 series de 10–15 repeticiones, sin forzar el rango.',
              style: const TextStyle(
                color: GymOSTheme.violetElectric,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    [
                      'Todos',
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
                    ].map((muscle) {
                      final selected = _muscleFilter == muscle;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(muscle),
                          selected: selected,
                          selectedColor: GymOSTheme.orangeElectric,
                          backgroundColor: GymOSTheme.surfaceBase,
                          labelStyle: TextStyle(
                            color: selected
                                ? GymOSTheme.bgMain
                                : GymOSTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) =>
                              setState(() => _muscleFilter = muscle),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _fieldLabel('EJERCICIOS'),
                Text(
                  '${_selectedExercises.length} seleccionados',
                  style: const TextStyle(
                    color: GymOSTheme.orangeElectric,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._allExercises
                .where(
                  (exercise) =>
                      _muscleFilter == 'Todos' ||
                      exercise.muscle.contains(_muscleFilter),
                )
                .expand(
                  (exercise) => [
                    _exerciseTile(exercise),
                    _settingsCard(exercise),
                  ],
                ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed:
                    _selectedExercises.isEmpty || _routineName.trim().isEmpty
                    ? null
                    : () => Navigator.pop(context, {
                        'title': _routineName.trim(),
                        'sets': _selectedExercises.fold<int>(
                          0,
                          (total, name) =>
                              total +
                              (int.tryParse(
                                    _exerciseSettings[name]?['sets'] ?? '3',
                                  ) ??
                                  3),
                        ),
                        'exercises': _selectedExercises.length,
                        'duration': '${_selectedExercises.length * 10} min',
                        'status': 'Activas',
                        'goal': _goal,
                        'days': _selectedDays.toList(),
                        'muscleGroups': _selectedExercises
                            .map(
                              (name) => _exercises
                                  .firstWhere(
                                    (exercise) => exercise.name == name,
                                  )
                                  .muscle,
                            )
                            .toSet()
                            .toList(),
                        'exerciseSettings':
                            Map<String, Map<String, String>>.from(
                              _exerciseSettings,
                            ),
                      }),
                icon: const Icon(Icons.check_rounded),
                label: const Text('GUARDAR RUTINA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymOSTheme.orangeElectric,
                  foregroundColor: GymOSTheme.bgMain,
                  disabledBackgroundColor: GymOSTheme.surfaceElevated,
                  disabledForegroundColor: GymOSTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseTile(_ExerciseGuide exercise) {
    final selected = _selectedExercises.contains(exercise.name);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: selected
            ? GymOSTheme.orangeElectric.withValues(alpha: 0.10)
            : GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? GymOSTheme.orangeElectric.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          onTap: () => setState(() {
            if (selected) {
              _selectedExercises.remove(exercise.name);
            } else {
              _selectedExercises.add(exercise.name);
              _exerciseSettings[exercise.name] = _defaultsFor(_goal);
            }
          }),
          leading: CircleAvatar(
            backgroundColor: GymOSTheme.surfaceElevated,
            child: CustomPaint(
              size: const Size(28, 28),
              painter: _MuscleIconPainter(
                muscle: exercise.muscle,
                color: GymOSTheme.orangeElectric,
              ),
            ),
          ),
          title: Text(
            exercise.name,
            style: const TextStyle(
              color: GymOSTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${exercise.muscle} · ${exercise.difficulty}',
            style: const TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Aprender ejercicio',
                onPressed: () => _showExerciseGuide(exercise),
                icon: const Icon(
                  Icons.menu_book_rounded,
                  color: GymOSTheme.violetElectric,
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? GymOSTheme.orangeElectric
                    : GymOSTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _defaultsFor(String goal) {
    switch (goal) {
      case 'Hipertrofia':
        return {'sets': '4', 'reps': '10', 'weight': '20'};
      case 'Movilidad':
        return {'sets': '3', 'reps': '12', 'weight': '0'};
      default:
        return {'sets': '4', 'reps': '5', 'weight': '40'};
    }
  }

  Widget _settingsCard(_ExerciseGuide exercise) {
    if (!_selectedExercises.contains(exercise.name)) return const SizedBox();
    final values = _exerciseSettings[exercise.name] ??= _defaultsFor(_goal);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: GymOSTheme.bgMain,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: _numberField('Series', values, 'sets')),
            const SizedBox(width: 8),
            Expanded(child: _numberField('Reps', values, 'reps')),
            const SizedBox(width: 8),
            Expanded(child: _numberField('Kg', values, 'weight')),
          ],
        ),
      ),
    );
  }

  Widget _numberField(String label, Map<String, String> values, String key) {
    return TextFormField(
      initialValue: values[key],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: GymOSTheme.textPrimary, fontSize: 13),
      onChanged: (value) => values[key] = value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: GymOSTheme.textSecondary,
          fontSize: 11,
        ),
        filled: true,
        fillColor: GymOSTheme.surfaceBase,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showExerciseGuide(_ExerciseGuide exercise) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: GymOSTheme.bgMain,
      isScrollControlled: true,
      builder: (_) => _ExerciseGuideSheet(exercise: exercise),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      color: GymOSTheme.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: GymOSTheme.textMuted),
    filled: true,
    fillColor: GymOSTheme.surfaceBase,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide.none,
    ),
  );
}

class _ExerciseGuide {
  const _ExerciseGuide({
    required this.name,
    required this.muscle,
    required this.equipment,
    required this.difficulty,
    required this.explanation,
    required this.steps,
    required this.tips,
    required this.icon,
  });

  final String name;
  final String muscle;
  final String equipment;
  final String difficulty;
  final String explanation;
  final List<String> steps;
  final String tips;
  final IconData icon;
}

class _ExerciseGuideSheet extends StatefulWidget {
  const _ExerciseGuideSheet({required this.exercise});

  final _ExerciseGuide exercise;

  @override
  State<_ExerciseGuideSheet> createState() => _ExerciseGuideSheetState();
}

class _ExerciseGuideSheetState extends State<_ExerciseGuideSheet> {
  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: GymOSTheme.textMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const SizedBox(height: 20),
            Text(
              exercise.name,
              style: const TextStyle(
                color: GymOSTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _tag(exercise.muscle, GymOSTheme.orangeElectric),
                _tag(exercise.difficulty, GymOSTheme.violetElectric),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '¿QUÉ TRABAJA?',
              style: TextStyle(
                color: GymOSTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.explanation,
              style: const TextStyle(
                color: GymOSTheme.textPrimary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'TÉCNICA PASO A PASO',
              style: TextStyle(
                color: GymOSTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            ...exercise.steps.indexed.map(
              (item) => _step(item.$1 + 1, item.$2),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: GymOSTheme.violetElectric.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: GymOSTheme.violetElectric.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    color: GymOSTheme.violetElectric,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      exercise.tips,
                      style: const TextStyle(
                        color: GymOSTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) => Chip(
    label: Text(text),
    backgroundColor: color.withValues(alpha: 0.15),
    labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
    side: BorderSide.none,
  );

  Widget _step(int number, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: GymOSTheme.orangeElectric,
          child: Text(
            '$number',
            style: const TextStyle(
              color: GymOSTheme.bgMain,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: GymOSTheme.textPrimary, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

// ==========================================
// PANTALLA DETALLE: EDITOR DE ENTRENAMIENTO
// ==========================================
class RoutineDetailScreen extends StatelessWidget {
  final Map<String, dynamic> routine;

  const RoutineDetailScreen({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    final savedSettings = routine['exerciseSettings'];
    final settings = savedSettings is Map
        ? savedSettings.map(
            (key, value) => MapEntry(
              key.toString(),
              Map<String, String>.from(value as Map),
            ),
          )
        : <String, Map<String, String>>{};
    final exercises = settings.entries.map((entry) {
      final values = entry.value;
      final sets = values['sets'] ?? '3';
      final reps = values['reps'] ?? '10';
      final weight = values['weight'] ?? '0';
      return {
        'name': entry.key,
        'sets': '$sets × $reps',
        'weight': '$weight kg',
      };
    }).toList();

    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      appBar: AppBar(
        backgroundColor: GymOSTheme.bgMain,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: GymOSTheme.textPrimary,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: GymOSTheme.orangeElectric,
              size: 20,
            ),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edita la rutina desde el menú de Rutinas'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y Métricas de Rendimiento
              Text(
                (routine['title'] as String? ?? 'Rutina').toUpperCase(),
                style: const TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),

              // Ficha de Estadísticas Históricas
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GymOSTheme.surfaceBase,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ÚLTIMA SESIÓN',
                          style: TextStyle(
                            color: GymOSTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '12 septiembre',
                          style: TextStyle(
                            color: GymOSTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'MEJOR VOLUMEN',
                          style: TextStyle(
                            color: GymOSTheme.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '8,420 kg',
                          style: TextStyle(
                            color: GymOSTheme.orangeElectric,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'ESTRUCTURA DE EJERCICIOS',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Lista Editor/Desglose
              Expanded(
                child: exercises.isEmpty
                    ? const Center(
                        child: Text(
                          'Esta rutina todavía no tiene ejercicios guardados.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: GymOSTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final ex = exercises[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: GymOSTheme.surfaceElevated.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.03),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: GymOSTheme.surfaceBase,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: GymOSTheme.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ex['name']!,
                                        style: const TextStyle(
                                          color: GymOSTheme.textPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        ex['sets']!,
                                        style: const TextStyle(
                                          color: GymOSTheme.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  ex['weight']!,
                                  style: const TextStyle(
                                    color: GymOSTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Botón Iniciar directamente esta rutina
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GymOSTheme.orangeElectric,
                    foregroundColor: GymOSTheme.bgMain,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Edita los ejercicios desde el menú de Rutinas',
                      ),
                    ),
                  ),
                  child: const Text(
                    'INICIAR RUTINA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
