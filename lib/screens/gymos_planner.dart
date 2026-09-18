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
      title: 'GymOS Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: GymOSTheme.bgMain,
      ),
      home: const PlannerMainNavigation(),
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

  // Colores de Estado del Planificador
  static const Color orangeElectric = Color(0xFFFF6B1A); // Entrenamiento
  static const Color violetElectric = Color(0xFF8B5CF6); // Cardio / Especial
  static const Color blueStatus = Color(0xFF3B82F6); // Descanso
  static const Color textMuted = Color(0xFF4B5563); // No disponible / Omitido
}

// ==========================================
// NAVEGACIÓN Y CONTENEDOR PRINCIPAL
// ==========================================
class PlannerMainNavigation extends StatefulWidget {
  const PlannerMainNavigation({super.key});

  @override
  State<PlannerMainNavigation> createState() => _PlannerMainNavigationState();
}

class _PlannerMainNavigationState extends State<PlannerMainNavigation> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymOSTheme.bgMain,
      appBar: AppBar(
        backgroundColor: GymOSTheme.bgMain,
        elevation: 0,
        title: const Text(
          'PLANIFICACIÓN',
          style: TextStyle(
            color: GymOSTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        leading: Navigator.canPop(context)
            ? const BackButton(color: GymOSTheme.textPrimary)
            : null,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: GymOSTheme.surfaceBase,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildSegmentButton('CALENDARIO', 0),
                _buildSegmentButton('DIVISIÓN SEMANAL', 1),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _tabIndex == 0
            ? const CalendarPlannerScreen()
            : const WeeklySplitScreen(),
      ),
    );
  }

  Widget _buildSegmentButton(String label, int index) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? GymOSTheme.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: Colors.white.withValues(alpha: 0.08))
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? GymOSTheme.textPrimary
                  : GymOSTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// PANTALLA A: CALENDARIO (SEPTIEMBRE 2026)
// ==========================================
enum DayStatus { workout, rest, cardio, unavailable, completed, skipped }

class CalendarPlannerScreen extends StatefulWidget {
  const CalendarPlannerScreen({super.key});

  @override
  State<CalendarPlannerScreen> createState() => _CalendarPlannerScreenState();
}

class _CalendarPlannerScreenState extends State<CalendarPlannerScreen> {
  // Mapa Muestra de Estados para Septiembre 2026
  final Map<int, DayStatus> _monthData = {
    1: DayStatus.completed,
    2: DayStatus.completed,
    3: DayStatus.rest,
    4: DayStatus.completed,
    5: DayStatus.cardio,
    6: DayStatus.skipped,
    7: DayStatus.completed,
    14: DayStatus.completed,
    18: DayStatus.workout, // 18 de Septiembre (Seleccionado)
    19: DayStatus.rest,
    20: DayStatus.workout,
    21: DayStatus.workout,
    22: DayStatus.cardio,
    28: DayStatus.unavailable,
  };

  void _showWorkoutDetailsBottomSheet(int day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GymOSTheme.surfaceBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicator drag bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GymOSTheme.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$day SEPTIEMBRE 2026',
                    style: const TextStyle(
                      color: GymOSTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
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
                      'Programado',
                      style: TextStyle(
                        color: GymOSTheme.orangeElectric,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'PECHO + TRÍCEPS',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '5 ejercicios  •  18 series',
                style: TextStyle(color: GymOSTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 28),
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'VER ENTRENAMIENTO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInWeek = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Mes Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Septiembre 2026',
                style: TextStyle(
                  color: GymOSTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                color: GymOSTheme.textSecondary,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Días de la Semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: daysInWeek
                .map(
                  (day) => SizedBox(
                    width: 32,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: GymOSTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Grilla del Calendario (Septiembre 2026 empieza en Martes -> Offset de 1)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 30 + 1, // 30 Días + 1 día de desfase inicial
              itemBuilder: (context, index) {
                if (index < 1) return const SizedBox.shrink(); // Offset inicial

                final dayNumber = index;
                final status = _monthData[dayNumber];
                final isSelectedDay = dayNumber == 18;

                return GestureDetector(
                  onTap: () => _showWorkoutDetailsBottomSheet(dayNumber),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelectedDay
                          ? GymOSTheme.orangeElectric.withValues(alpha: 0.15)
                          : GymOSTheme.surfaceBase,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelectedDay
                            ? GymOSTheme.orangeElectric
                            : Colors.white.withValues(alpha: 0.04),
                        width: isSelectedDay ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: isSelectedDay
                                ? GymOSTheme.orangeElectric
                                : GymOSTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildStatusDot(status),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Leyenda discreta de estados
          _buildLegend(),
          SizedBox(height: 16 + MediaQuery.of(context).viewPadding.bottom),
        ],
      ),
    );
  }

  Widget _buildStatusDot(DayStatus? status) {
    if (status == null) return const SizedBox(height: 4);

    Color dotColor;
    switch (status) {
      case DayStatus.completed:
        dotColor = Colors.white;
        break;
      case DayStatus.workout:
        dotColor = GymOSTheme.orangeElectric;
        break;
      case DayStatus.cardio:
        dotColor = GymOSTheme.violetElectric;
        break;
      case DayStatus.rest:
        dotColor = GymOSTheme.blueStatus;
        break;
      case DayStatus.skipped:
      case DayStatus.unavailable:
        dotColor = GymOSTheme.textMuted;
        break;
    }

    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _LegendItem(color: GymOSTheme.orangeElectric, label: 'Entrenar'),
        _LegendItem(color: GymOSTheme.blueStatus, label: 'Descanso'),
        _LegendItem(color: GymOSTheme.violetElectric, label: 'Cardio'),
        _LegendItem(color: GymOSTheme.textMuted, label: 'Omitido'),
      ],
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
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: GymOSTheme.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}

// ==========================================
// PANTALLA B: DIVISIÓN SEMANAL (WEEKLY SPLIT)
// ==========================================
class WeeklySplitItem {
  final String day;
  final String title;
  final bool isRest;

  WeeklySplitItem({
    required this.day,
    required this.title,
    this.isRest = false,
  });
}

class WeeklySplitScreen extends StatefulWidget {
  const WeeklySplitScreen({super.key});

  @override
  State<WeeklySplitScreen> createState() => _WeeklySplitScreenState();
}

class _WeeklySplitScreenState extends State<WeeklySplitScreen> {
  final List<WeeklySplitItem> _schedule = [
    WeeklySplitItem(day: 'LUNES', title: 'Pecho + Tríceps'),
    WeeklySplitItem(day: 'MARTES', title: 'Espalda + Bíceps'),
    WeeklySplitItem(day: 'MIÉRCOLES', title: 'Descanso', isRest: true),
    WeeklySplitItem(day: 'JUEVES', title: 'Piernas'),
    WeeklySplitItem(day: 'VIERNES', title: 'Hombros + Brazos'),
    WeeklySplitItem(day: 'SÁBADO', title: 'Cardio'),
    WeeklySplitItem(day: 'DOMINGO', title: 'Descanso', isRest: true),
  ];

  @override
  Widget build(BuildContext context) {
    final routines = RoutineStore.instance.routines;
    final schedule = _schedule.map((item) {
      final day = item.day.substring(0, 3);
      final routine = routines.cast<Map<String, dynamic>?>().firstWhere(
        (routine) =>
            routine!['days'] is List && (routine['days'] as List).contains(day),
        orElse: () => null,
      );
      return routine == null
          ? item
          : WeeklySplitItem(
              day: item.day,
              title: routine['title'] as String? ?? item.title,
              isRest: false,
            );
    }).toList();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        16 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Reorderable ListView
          Expanded(
            child: ReorderableListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: schedule.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _schedule.removeAt(oldIndex);
                  _schedule.insert(newIndex, item);
                });
              },
              proxyDecorator: (child, index, animation) => child,
              itemBuilder: (context, index) {
                final item = schedule[index];
                return Container(
                  key: ValueKey(item.day + item.title),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: item.isRest
                        ? GymOSTheme.surfaceElevated.withValues(alpha: 0.3)
                        : GymOSTheme.surfaceBase,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: item.isRest
                          ? Colors.transparent
                          : Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.drag_indicator_rounded,
                        color: GymOSTheme.textMuted,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 80,
                        child: Text(
                          item.day,
                          style: TextStyle(
                            color: item.isRest
                                ? GymOSTheme.textSecondary
                                : GymOSTheme.orangeElectric,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: item.isRest
                                ? GymOSTheme.textSecondary
                                : GymOSTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: item.isRest
                                ? FontWeight.w500
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        item.isRest
                            ? Icons.bedtime_outlined
                            : Icons.chevron_right_rounded,
                        color: GymOSTheme.textMuted,
                        size: 18,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Botones de Adición
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
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
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona un día para agregarlo al plan'),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    '+ Agregar día',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GymOSTheme.textSecondary,
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Selecciona un día para marcarlo como descanso',
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.bedtime_outlined, size: 16),
                  label: const Text(
                    '+ Día descanso',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
