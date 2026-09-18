import 'dart:async';
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
      title: 'GymOS Active Workout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const ActiveWorkoutScreen(),
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
// PANTALLA: ENTRENAMIENTO ACTIVO
// ==========================================
class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key, this.routine});

  final Map<String, dynamic>? routine;

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late final List<String> _exerciseNames;
  int _currentExercise = 0;
  int _elapsedSeconds = 0;
  Timer? _elapsedTimer;

  // Estado de las series
  final List<Map<String, dynamic>> _sets = [
    {
      'setNumber': 1,
      'prev': '77.5 kg × 9',
      'weight': 80.0,
      'reps': 10,
      'rir': 1,
      'completed': true,
    },
    {
      'setNumber': 2,
      'prev': '77.5 kg × 9',
      'weight': 80.0,
      'reps': 10,
      'rir': 1,
      'completed': true,
    },
    {
      'setNumber': 3,
      'prev': '77.5 kg × 8',
      'weight': 80.0,
      'reps': 10,
      'rir': 1,
      'completed': false,
    },
    {
      'setNumber': 4,
      'prev': '77.5 kg × 8',
      'weight': 80.0,
      'reps': 8,
      'rir': 0,
      'completed': false,
    },
  ];

  // Estado del temporizador de descanso
  bool _isResting = false;
  int _restSecondsRemaining = 92; // 01:32
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
    final saved = widget.routine?['exerciseSettings'];
    if (saved is Map && saved.isNotEmpty) {
      _exerciseNames = saved.keys.map((key) => key.toString()).toList();
      final first = Map<String, dynamic>.from(
        saved[_exerciseNames.first] as Map,
      );
      final count = int.tryParse('${first['sets']}') ?? 4;
      final reps = int.tryParse('${first['reps']}') ?? 10;
      final weight = double.tryParse('${first['weight']}') ?? 0;
      _sets
        ..clear()
        ..addAll(
          List.generate(
            count,
            (index) => {
              'setNumber': index + 1,
              'prev': 'Sin registro',
              'weight': weight,
              'reps': reps,
              'rir': 1,
              'completed': false,
            },
          ),
        );
    } else {
      _exerciseNames = ['Press banca'];
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _isResting = true;
      _restSecondsRemaining = 92;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecondsRemaining > 0) {
        setState(() => _restSecondsRemaining--);
      } else {
        _stopRestTimer();
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    if (mounted) setState(() => _isResting = false);
  }

  void _addRestTime(int seconds) {
    setState(() => _restSecondsRemaining += seconds);
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  int get _completedSets =>
      _sets.where((item) => item['completed'] == true).length;

  double get _sessionVolume => _sets
      .where((item) => item['completed'] == true)
      .fold<double>(
        0,
        (total, item) =>
            total +
            ((item['weight'] as num?)?.toDouble() ?? 0) *
                ((item['reps'] as num?)?.toDouble() ?? 0),
      );

  String get _routineTitle =>
      widget.routine?['title'] as String? ?? 'Entrenamiento libre';

  void _nextExercise() {
    if (_currentExercise >= _exerciseNames.length - 1) {
      _finishWorkout();
      return;
    }
    setState(() {
      _currentExercise++;
      _loadExerciseSets();
    });
  }

  void _loadExerciseSets() {
    final saved = widget.routine?['exerciseSettings'];
    final values = saved is Map
        ? Map<String, dynamic>.from(
            saved[_exerciseNames[_currentExercise]] as Map,
          )
        : <String, dynamic>{};
    final count = int.tryParse('${values['sets']}') ?? 4;
    final reps = int.tryParse('${values['reps']}') ?? 10;
    final weight = double.tryParse('${values['weight']}') ?? 0;
    _sets
      ..clear()
      ..addAll(
        List.generate(
          count,
          (index) => {
            'setNumber': index + 1,
            'prev': 'Sin registro',
            'weight': weight,
            'reps': reps,
            'rir': 1,
            'completed': false,
          },
        ),
      );
  }

  Future<void> _finishWorkout() async {
    _stopRestTimer();
    final duration = _elapsedSeconds ~/ 60;
    if (!mounted) return;
    final finish = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GymOSTheme.surfaceElevated,
        title: const Text(
          'Entrenamiento completado',
          style: TextStyle(color: GymOSTheme.textPrimary),
        ),
        content: Text(
          'Registraste $_completedSets series de $_routineTitle en $duration min.',
          style: const TextStyle(color: GymOSTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Seguir'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GymOSTheme.orangeElectric,
              foregroundColor: GymOSTheme.bgMain,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
    if (finish == true && mounted) Navigator.pop(context);
    if (finish == true) {
      RoutineStore.instance.addWorkoutHistory({
        'title': _routineTitle,
        'sets': _completedSets,
        'duration': duration,
        'volume': _sessionVolume,
        'muscleGroups': widget.routine?['muscleGroups'] ?? const <String>[],
        'date': _formatDate(DateTime.now()),
      });
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  void dispose() {
    _restTimer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      body: SafeArea(
        child: Stack(
          children: [
            // Cuerpos de la pantalla (One-Hand Ergonomics: Espaciado cómodo arriba)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildHeader(),
                  const SizedBox(height: 20),

                  // Título de Ejercicio Actual
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _exerciseNames[_currentExercise].toUpperCase(),
                        style: TextStyle(
                          color: GymOSTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GymOSTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Ejercicio ${_currentExercise + 1} de ${_exerciseNames.length}',
                          style: TextStyle(
                            color: GymOSTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Lista de Series interactiva
                  _buildProgressStrip(),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _sets.length,
                      itemBuilder: (context, index) =>
                          _buildSetRow(_sets[index], index),
                    ),
                  ),

                  // Acciones inferiores fijas
                  _buildBottomActions(),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // TEMPORIZADOR DE DESCANSO EMERGENTE (FLOATING SHEET)
            if (_isResting) _buildRestTimerOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Volver',
            onPressed: _confirmExit,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: GymOSTheme.textPrimary,
              size: 19,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _routineTitle,
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Progreso: $_completedSets / ${_sets.length} series',
                style: TextStyle(
                  color: GymOSTheme.orangeElectric,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: GymOSTheme.orangeElectric.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  color: GymOSTheme.orangeElectric,
                  size: 16,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(_elapsedSeconds),
                  style: const TextStyle(
                    color: GymOSTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: _finishWorkout,
            child: const Text(
              'FINALIZAR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GymOSTheme.surfaceBase,
        title: const Text(
          '¿Salir del entrenamiento?',
          style: TextStyle(color: GymOSTheme.textPrimary),
        ),
        content: const Text(
          'Tu progreso de esta sesión no se guardará.',
          style: TextStyle(color: GymOSTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Continuar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (shouldExit == true && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildProgressStrip() {
    final progress = _sets.isEmpty ? 0.0 : _completedSets / _sets.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GymOSTheme.orangeElectric.withValues(alpha: 0.18),
            GymOSTheme.violetElectric.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GymOSTheme.orangeElectric.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: GymOSTheme.orangeElectric,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Mantén el ritmo',
                  style: TextStyle(
                    color: GymOSTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: GymOSTheme.orangeElectric,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _sessionStat(
                Icons.timer_outlined,
                _formatTime(_elapsedSeconds),
                'TIEMPO',
              ),
              _sessionStat(
                Icons.monitor_weight_outlined,
                '${_sessionVolume.toStringAsFixed(0)} kg',
                'VOLUMEN',
              ),
              _sessionStat(
                Icons.check_circle_outline_rounded,
                '$_completedSets/${_sets.length}',
                'SERIES',
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(
                GymOSTheme.orangeElectric,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionStat(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: GymOSTheme.textSecondary, size: 15),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(Map<String, dynamic> setItem, int index) {
    final isDone = setItem['completed'] as bool;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone
            ? GymOSTheme.orangeElectric.withValues(alpha: 0.08)
            : GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDone
              ? GymOSTheme.orangeElectric.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Número de Serie / Check
          GestureDetector(
            onTap: () {
              setState(() {
                setItem['completed'] = !isDone;
                if (setItem['completed']) {
                  _startRestTimer();
                }
              });
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone
                    ? GymOSTheme.orangeElectric
                    : GymOSTheme.surfaceElevated,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(
                        Icons.check_rounded,
                        color: GymOSTheme.bgMain,
                        size: 24,
                      )
                    : Text(
                        '${setItem['setNumber']}',
                        style: const TextStyle(
                          color: GymOSTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Campos de Edición Grandes
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildValueAdjuster('PESO', '${setItem['weight']} kg'),
                _buildValueAdjuster('REPS', '${setItem['reps']}'),
                _buildValueAdjuster('RIR', '${setItem['rir']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueAdjuster(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: GymOSTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: GymOSTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Column(
      children: [
        if (_exerciseNames.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (var index = 0; index < _exerciseNames.length; index++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: ChoiceChip(
                        label: Text('${index + 1}'),
                        selected: index == _currentExercise,
                        selectedColor: GymOSTheme.orangeElectric,
                        backgroundColor: GymOSTheme.surfaceBase,
                        labelStyle: TextStyle(
                          color: index == _currentExercise
                              ? GymOSTheme.bgMain
                              : GymOSTheme.textSecondary,
                          fontWeight: FontWeight.w800,
                        ),
                        onSelected: (_) =>
                            setState(() => _currentExercise = index),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: GymOSTheme.surfaceElevated,
              foregroundColor: GymOSTheme.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _nextExercise,
            icon: const Icon(
              Icons.skip_next_rounded,
              size: 22,
              color: GymOSTheme.orangeElectric,
            ),
            label: Text(
              _currentExercise == _exerciseNames.length - 1
                  ? 'FINALIZAR ENTRENAMIENTO'
                  : 'SIGUIENTE EJERCICIO',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // OVERLAY DEL CRONÓMETRO DE DESCANSO
  Widget _buildRestTimerOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GymOSTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GymOSTheme.orangeElectric, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TIEMPO DE DESCANSO',
                  style: TextStyle(
                    color: GymOSTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                GestureDetector(
                  onTap: _stopRestTimer,
                  child: const Text(
                    'Saltar',
                    style: TextStyle(
                      color: GymOSTheme.orangeElectric,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Contador Principal
            Text(
              _formatTime(_restSecondsRemaining),
              style: const TextStyle(
                color: GymOSTheme.textPrimary,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
              ),
            ),

            const SizedBox(height: 16),

            // Botones de ajuste de tiempo de un toque
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GymOSTheme.textPrimary,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _addRestTime(30),
                    child: const Text(
                      '+30s',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GymOSTheme.textPrimary,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _addRestTime(60),
                    child: const Text(
                      '+1m',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
