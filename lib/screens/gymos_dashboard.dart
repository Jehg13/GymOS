import 'package:flutter/material.dart';

import '../data/app_preferences.dart';
import '../data/routine_store.dart';
import 'gymos_active_workout.dart';
import 'gymos_profile.dart';
import 'gymos_progress.dart';
import 'gymos_routines.dart';
import 'gymos_workout_history.dart';
import 'gymos_body_evolution.dart';
import 'gymos_achievements.dart';

void main() {
  runApp(const GymOSApp());
}

class GymOSApp extends StatelessWidget {
  const GymOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymOS Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const DashboardScreen(),
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
}

// ==========================================
// DASHBOARD PRINCIPAL
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onLogout});

  final ValueChanged<BuildContext>? onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      body: _buildCurrentSection(),

      // NAVEGACIÓN INFERIOR
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentNavIndex) {
      case 1:
        return const ScheduledWorkoutScreen();
      case 2:
        return const RoutinesMainScreen();
      case 3:
        return const ProgressScreen();
      case 4:
        return ProfileScreen(onLogout: widget.onLogout);
      default:
        return AnimatedBuilder(
          animation: RoutineStore.instance,
          builder: (context, _) => _buildHome(),
        );
    }
  }

  Widget _buildHome() {
    final today = _dayLabel(DateTime.now().weekday);
    final todayRoutines = RoutineStore.instance.forDay(today);
    final history = RoutineStore.instance.workoutHistory;
    final sessions = history.length;
    final totalMinutes = history.fold<int>(
      0,
      (total, session) => total + ((session['duration'] as int?) ?? 0),
    );

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildDynamicHero(today, todayRoutines),
            const SizedBox(height: 18),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildSectionTitle('TU ACTIVIDAD', 'Esta semana'),
            const SizedBox(height: 12),
            _buildActivityCard(sessions, totalMinutes),
            const SizedBox(height: 24),
            _buildSectionTitle('MÉTRICAS EN VIVO', 'Desde tu historial'),
            const SizedBox(height: 12),
            _buildDynamicMetrics(sessions, totalMinutes),
            const SizedBox(height: 24),
            _buildSectionTitle('TU SEMANA', 'Consistencia'),
            const SizedBox(height: 12),
            _buildWeekOverview(today),
            const SizedBox(height: 24),
            _buildSectionTitle('SIGUIENTE OBJETIVO', 'Mantén el foco'),
            const SizedBox(height: 12),
            _buildGoalCard(sessions),
            const SizedBox(height: 24),
            _buildSectionTitle('DESCUBRE MÁS', 'Todo tu progreso'),
            const SizedBox(height: 12),
            _buildDiscoveryGrid(),
          ],
        ),
      ),
    );
  }

  String _dayLabel(int weekday) =>
      const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][weekday - 1];

  Widget _buildSectionTitle(String title, String trailing) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: GymOSTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      Text(
        trailing,
        style: const TextStyle(
          color: GymOSTheme.orangeElectric,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  Widget _buildDynamicHero(
    String today,
    List<Map<String, dynamic>> todayRoutines,
  ) {
    final routine = todayRoutines.isEmpty ? null : todayRoutines.first;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B1A), Color(0xFF9B42F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: GymOSTheme.orangeElectric.withValues(alpha: 0.22),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 7),
              Text(
                today == _dayLabel(DateTime.now().weekday) ? 'HOY' : today,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              const Spacer(),
              Text(
                todayRoutines.isEmpty ? 'RECUPERACIÓN' : 'PLAN LISTO',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            routine?['title'] as String? ??
                'Enfócate en ${AppPreferences.instance.profileGoal.toLowerCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            routine == null
                ? '${AppPreferences.instance.profileEquipment} · '
                      'Plan adaptado a tu objetivo'
                : '${routine['exercises'] ?? 0} ejercicios · ${routine['duration'] ?? '45 min'}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: GymOSTheme.bgMain,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: routine == null
                  ? () => setState(() => _currentNavIndex = 2)
                  : () => _confirmStart(routine),
              icon: Icon(
                routine == null ? Icons.add_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(
                routine == null ? 'ASIGNAR RUTINA' : 'COMENZAR AHORA',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() => Row(
    children: [
      _quickAction(
        'Rutinas',
        Icons.view_list_rounded,
        () => setState(() => _currentNavIndex = 2),
      ),
      _quickAction(
        'Progreso',
        Icons.insights_rounded,
        () => setState(() => _currentNavIndex = 3),
      ),
      _quickAction(
        'Historial',
        Icons.history_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
        ),
      ),
      _quickAction(
        'Logros',
        Icons.emoji_events_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AchievementsScreen()),
        ),
      ),
    ],
  );

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) =>
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 7),
          child: Material(
            color: GymOSTheme.surfaceBase,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Column(
                  children: [
                    Icon(icon, color: GymOSTheme.orangeElectric, size: 21),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        color: GymOSTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildActivityCard(int sessions, int totalMinutes) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: GymOSTheme.surfaceBase,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 62,
          height: 62,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: (sessions / 5).clamp(0.0, 1.0),
                strokeWidth: 6,
                backgroundColor: GymOSTheme.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation(
                  GymOSTheme.orangeElectric,
                ),
              ),
              Text(
                '$sessions',
                style: const TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entrenamientos completados',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$totalMinutes minutos acumulados · Meta semanal: 5 sesiones',
                style: const TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildDynamicMetrics(int sessions, int totalMinutes) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 2.05,
    children: [
      _buildMetricItem('SESIONES', '$sessions', Icons.fitness_center),
      _buildMetricItem('TIEMPO', '${totalMinutes}m', Icons.timer_outlined),
      _buildMetricItem(
        'RUTINAS',
        '${RoutineStore.instance.routines.length}',
        Icons.assignment_outlined,
      ),
      _buildMetricItem(
        'RACHA',
        '${sessions > 0 ? sessions : 0} días',
        Icons.local_fire_department_outlined,
      ),
    ],
  );

  Widget _buildWeekOverview(String today) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: GymOSTheme.surfaceBase,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _WeekDot(day: 'L', active: true),
        _WeekDot(day: 'M', active: true),
        _WeekDot(day: 'X', active: false),
        _WeekDot(day: 'J', active: true),
        _WeekDot(day: 'V', active: false),
        _WeekDot(day: 'S', active: false),
        _WeekDot(day: 'D', active: false),
      ],
    ),
  );

  Widget _buildGoalCard(int sessions) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: GymOSTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: GymOSTheme.violetElectric.withValues(alpha: 0.28),
      ),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.track_changes_rounded,
          color: GymOSTheme.violetElectric,
          size: 30,
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completa 5 sesiones esta semana',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'La constancia construye resultados.',
                style: TextStyle(color: GymOSTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Text(
          '$sessions/5',
          style: const TextStyle(
            color: GymOSTheme.violetElectric,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    ),
  );

  Widget _buildDiscoveryGrid() => Row(
    children: [
      _discoveryCard(
        'Evolución',
        Icons.photo_library_outlined,
        const Color(0xFF10B981),
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BodyEvolutionScreen()),
          );
        },
      ),
      const SizedBox(width: 10),
      _discoveryCard(
        'Récords',
        Icons.emoji_events_outlined,
        GymOSTheme.violetElectric,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
          );
        },
      ),
    ],
  );

  Widget _discoveryCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) => Expanded(
    child: Material(
      color: GymOSTheme.surfaceBase,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Icon(icon, color: color, size: 25),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _confirmStart(Map<String, dynamic> routine) async {
    final start = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GymOSTheme.surfaceElevated,
        title: const Text(
          '¿Listo para entrenar?',
          style: TextStyle(color: GymOSTheme.textPrimary),
        ),
        content: Text(
          'Vas a iniciar ${routine['title'] ?? 'esta rutina'}. El cronómetro comenzará al entrar.',
          style: const TextStyle(color: GymOSTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GymOSTheme.orangeElectric,
              foregroundColor: GymOSTheme.bgMain,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Iniciar rutina'),
          ),
        ],
      ),
    );
    if (start != true || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(routine: routine)),
    );
  }

  // --- COMPONENTES DEL DASHBOARD ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Buenos días, Jesús',
              style: TextStyle(
                color: GymOSTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Viernes, 18 de septiembre',
              style: TextStyle(
                color: GymOSTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: GymOSTheme.surfaceBase,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: GymOSTheme.textPrimary,
                  size: 20,
                ),
                onPressed: widget.onLogout == null
                    ? null
                    : () => widget.onLogout!(context),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: GymOSTheme.surfaceElevated,
              child: const Text(
                'J',
                style: TextStyle(
                  color: GymOSTheme.orangeElectric,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildWorkoutHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GymOSTheme.orangeElectric.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GymOSTheme.orangeElectric.withValues(alpha: 0.08),
            blurRadius: 24,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GymOSTheme.orangeElectric.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'HOY',
                  style: TextStyle(
                    color: GymOSTheme.orangeElectric,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                '5 ejercicios  •  18 series',
                style: TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'PECHO + TRÍCEPS',
            style: TextStyle(
              color: GymOSTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
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
              onPressed: () => setState(() => _currentNavIndex = 1),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text(
                'COMENZAR ENTRENAMIENTO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildWeeklyProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'PROGRESO SEMANAL',
              style: TextStyle(
                color: GymOSTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '4 / 5 entrenamientos',
              style: TextStyle(
                color: GymOSTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 4 / 5,
            minHeight: 6,
            backgroundColor: GymOSTheme.surfaceElevated,
            valueColor: const AlwaysStoppedAnimation<Color>(
              GymOSTheme.orangeElectric,
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildMetricItem('VOLUMEN', '8,420 kg', Icons.fitness_center),
        _buildMetricItem('TIEMPO', '4h 32m', Icons.timer_outlined),
        _buildMetricItem('PRs', '3', Icons.emoji_events_outlined),
        _buildMetricItem(
          'RACHA',
          '18 días',
          Icons.local_fire_department_outlined,
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Icon(icon, color: GymOSTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: GymOSTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
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
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPRHighlightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: GymOSTheme.violetElectric.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GymOSTheme.violetElectric.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: GymOSTheme.violetElectric,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'NUEVO RÉCORD',
                style: TextStyle(
                  color: GymOSTheme.violetElectric,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Press banca',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            '82.5 kg × 10',
            style: TextStyle(
              color: GymOSTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildStrengthChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROGRESO DE FUERZA (ÚLTIMAS SEMANAS)',
            style: TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(8, (i) {
                final heights = [
                  28.0,
                  34.0,
                  32.0,
                  42.0,
                  40.0,
                  48.0,
                  52.0,
                  58.0,
                ];
                final isLast = i == 7;
                return Container(
                  width: 14,
                  height: heights[i],
                  decoration: BoxDecoration(
                    color: isLast
                        ? GymOSTheme.orangeElectric
                        : GymOSTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildNextDayRestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: GymOSTheme.surfaceElevated.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.bedtime_outlined,
            color: GymOSTheme.textSecondary,
            size: 18,
          ),
          SizedBox(width: 12),
          Text(
            'Mañana — Descanso',
            style: TextStyle(
              color: GymOSTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Text(
            'Recuperación pasiva',
            style: TextStyle(color: GymOSTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: GymOSTheme.bgMain,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
        backgroundColor: GymOSTheme.bgMain,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: GymOSTheme.orangeElectric,
        unselectedItemColor: GymOSTheme.textSecondary,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'Entrenar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted_rounded),
            label: 'Rutinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_rounded),
            label: 'Progreso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class ScheduledWorkoutScreen extends StatefulWidget {
  const ScheduledWorkoutScreen({super.key});

  @override
  State<ScheduledWorkoutScreen> createState() => _ScheduledWorkoutScreenState();
}

class _ScheduledWorkoutScreenState extends State<ScheduledWorkoutScreen> {
  static const _days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  late String _selectedDay;

  String get _today {
    final weekday = DateTime.now().weekday;
    return _days[weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _today;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: RoutineStore.instance,
      builder: (context, _) {
        final routines = RoutineStore.instance.forDay(_selectedDay);
        return Scaffold(
          backgroundColor: GymOSTheme.bgMain,
          appBar: AppBar(
            backgroundColor: GymOSTheme.bgMain,
            elevation: 0,
            title: const Text(
              'Entrenar',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: routines.isEmpty
                  ? ListView(
                      children: [
                        _WorkoutHero(routineCount: routines.length),
                        _WeekDaySelector(
                          days: _days,
                          selectedDay: _selectedDay,
                          today: _today,
                          onSelected: (day) =>
                              setState(() => _selectedDay = day),
                        ),
                        _EmptyTrainingDay(day: _selectedDay),
                      ],
                    )
                  : ListView(
                      children: [
                        _WorkoutHero(routineCount: routines.length),
                        _WeekDaySelector(
                          days: _days,
                          selectedDay: _selectedDay,
                          today: _today,
                          onSelected: (day) =>
                              setState(() => _selectedDay = day),
                        ),
                        ...routines.map(
                          (routine) => _RoutineTrainingCard(
                            routine: routine,
                            onTap: () => _confirmStartRoutine(routine),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmStartRoutine(Map<String, dynamic> routine) async {
    final start = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: GymOSTheme.surfaceElevated,
        title: const Text(
          '¿Listo para entrenar?',
          style: TextStyle(color: GymOSTheme.textPrimary),
        ),
        content: Text(
          'Vas a iniciar ${routine['title'] ?? 'esta rutina'}.',
          style: const TextStyle(color: GymOSTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: GymOSTheme.orangeElectric,
              foregroundColor: GymOSTheme.bgMain,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Iniciar rutina'),
          ),
        ],
      ),
    );
    if (start != true || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(routine: routine)),
    );
  }
}

class _WorkoutHero extends StatelessWidget {
  const _WorkoutHero({required this.routineCount});
  final int routineCount;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B1A), Color(0xFFB83BFF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TU PLAN DE HOY',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Listo para superar\ntu mejor versión?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              '$routineCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              routineCount == 1 ? 'rutina' : 'rutinas',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    ),
  );
}

class _WeekDaySelector extends StatelessWidget {
  const _WeekDaySelector({
    required this.days,
    required this.selectedDay,
    required this.today,
    required this.onSelected,
  });
  final List<String> days;
  final String selectedDay;
  final String today;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (day) => GestureDetector(
              onTap: () => onSelected(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 39,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: day == selectedDay
                      ? GymOSTheme.orangeElectric
                      : GymOSTheme.surfaceBase,
                  borderRadius: BorderRadius.circular(13),
                  border: day == today
                      ? Border.all(color: GymOSTheme.orangeElectric)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        color: day == selectedDay
                            ? GymOSTheme.bgMain
                            : GymOSTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Icon(
                      day == today ? Icons.circle : Icons.circle_outlined,
                      size: 7,
                      color: day == selectedDay
                          ? GymOSTheme.bgMain
                          : GymOSTheme.textSecondary.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({required this.day, required this.active});
  final String day;
  final bool active;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        day,
        style: const TextStyle(
          color: GymOSTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          color: active
              ? GymOSTheme.orangeElectric
              : GymOSTheme.surfaceElevated,
          shape: BoxShape.circle,
        ),
        child: Icon(
          active ? Icons.check_rounded : Icons.remove_rounded,
          color: active ? GymOSTheme.bgMain : GymOSTheme.textSecondary,
          size: 15,
        ),
      ),
    ],
  );
}

class _RoutineTrainingCard extends StatelessWidget {
  const _RoutineTrainingCard({required this.routine, required this.onTap});

  final Map<String, dynamic> routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: GymOSTheme.surfaceElevated,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: GymOSTheme.orangeElectric,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: GymOSTheme.bgMain,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine['title'] as String? ?? 'Rutina',
                      style: const TextStyle(
                        color: GymOSTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${routine['exercises'] ?? 0} ejercicios · ${routine['duration'] ?? '45 min'}',
                      style: const TextStyle(color: GymOSTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: GymOSTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTrainingDay extends StatelessWidget {
  const _EmptyTrainingDay({required this.day});
  final String day;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.event_available_rounded,
            color: GymOSTheme.orangeElectric,
            size: 58,
          ),
          const SizedBox(height: 16),
          Text(
            'Día de recuperación · $day',
            style: const TextStyle(
              color: GymOSTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Asigna una rutina a este día desde Rutinas.',
            style: TextStyle(color: GymOSTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
